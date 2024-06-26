defmodule Gitly.Utils.Archive do
  alias Gitly.Utils.Archive.Type, as: ArchiveType
  alias Gitly.Utils.Archive.Extractor, as: Extractor
  alias Gitly.Utils.Git.Provider, as: GitProvider
  alias Gitly.Utils.FS, as: FS

  @moduledoc """
  A module to handle archive operations.
  """

  @doc """
  Builds an archive URL based on the given input.
  """
  @spec build_archive_url(map(), ArchiveType.ext()) :: {:error, String.t()} | String.t()
  def build_archive_url(%{host: host} = input, format \\ :tar_gz) do
    with type <- GitProvider.from_string(host),
         ext <- ArchiveType.from_type(format),
         url <- GitProvider.build_url(type, input, ext) do
      url
    end
  end

  @spec create_archive_path(map(), Gitly.opts()) :: Path.t()
  def create_archive_path(%{host: host, owner: owner, repo: repo, ref: ref}, opts \\ []) do
    with root <- Keyword.get(opts, :root, FS.root_path()),
         format <- Keyword.get(opts, :format, :tar_gz),
         provider = host |> String.split(".") |> List.first(),
         fmt = ArchiveType.from_type(format),
         archive_path = [root, provider, owner, repo, ref <> fmt] |> Path.join() |> Path.expand() do
      archive_path
    end
  end

  @spec download(String.t(), Path.t()) :: {:ok, Path.t()} | {:error, String.t()}
  def download(url, path) do
    try do
      with :ok <- FS.ensure_file_exists(path),
           opts = [into: stream_to_file!(path), redirect_log_level: false, decode_body: false],
           %Req.Response{status: 200} <- Req.get!(url, opts) do
        {:ok, path}
      else
        %Req.Response{status: code} ->
          File.rm(path)
          {:error, "Failed to download archive: #{code}"}

        {:error, reason} ->
          {:error, reason}
      end
    rescue
      e in RuntimeError -> {:error, e.message}
      e -> {:error, "Failed to download archive: #{inspect(e)}"}
    end
  end

  @spec extract(Path.t(), Path.t(), Gitly.opts()) :: {:ok, Path.t()} | {:error, String.t()}
  def extract(path, dest, opts \\ []) do
    force = Keyword.get(opts, :force, false)
    overwrite = Keyword.get(opts, :overwrite, false)
    with {:ok, temp_dir} <- Briefly.create(directory: true),
         {:ok, _} <- Extractor.extract(path, temp_dir),
        #  [extracted_dir] <- File.ls!(temp_dir),
         {:ok, _} <-
           FS.maybe_rm_rf(
             dest,
             FS.rm?(dest) and (force || overwrite)
           ),
         {:ok, _} <-
           FS.maybe_move(
             temp_dir,
             dest,
             not File.exists?(dest)
           ) do
      {:ok, dest}
    else
      {:error, reason} -> {:error, reason}
      _ -> {:error, "Failed to extract archive"}
    end
  after
    Briefly.cleanup()
  end


  defp stream_to_file!(path) do
    case File.open(path, [:write, :binary]) do
      {:ok, file} ->
        fn
          {:data, data}, acc ->
            IO.binwrite(file, data)
            {:cont, acc}

          :done, acc ->
            File.close(file)
            {:cont, acc}
        end

      {:error, reason} ->
        raise "Failed to open file #{path}: #{inspect(reason)}"
    end
  end
end
