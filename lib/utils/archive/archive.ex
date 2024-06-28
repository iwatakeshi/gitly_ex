defmodule Gitly.Utils.Archive do
  alias Gitly.Utils.Archive.Type, as: ArchiveType
  alias Gitly.Utils.Archive.Extractor, as: Extractor
  alias Gitly.Utils.Git.Provider, as: GitProvider
  alias Gitly.Utils.FS, as: FS

  @moduledoc """
  A module to handle archive operations.

  This module provides functionality for building archive URLs, creating archive paths,
  downloading archives, and extracting them.
  """

  @doc """
  Builds an archive URL based on the given input.

  ## Parameters

    * `input` - A map containing archive information (must include `:host`).
    * `format` - The desired archive format (default: `:tar_gz`).

  ## Returns

    * A string containing the built URL, or `{:error, reason}` if the operation fails.

  ## Examples

      iex> input = %{host: "github.com", owner: "elixir-lang", repo: "elixir", ref: "main"}
      iex> Gitly.Utils.Archive.build_archive_url(input)
      "https://github.com/elixir-lang/elixir/archive/main.tar.gz"
  """
  @spec build_archive_url(map(), ArchiveType.ext()) :: {:error, String.t()} | String.t()
  def build_archive_url(%{host: host} = input, format \\ :tar_gz) do
    with type <- GitProvider.from_string(host),
         ext <- ArchiveType.from_type(format),
         url <- GitProvider.build_url(type, input, ext) do
      url
    end
  end

  @doc """
  Creates an archive path based on the given input.

  ## Parameters

    * `input` - A map containing archive information (must include `:host`, `:owner`, `:repo`, and `:ref`).
    * `opts` - A keyword list of options:
      * `:root` - The root path (default: result of `FS.root_path()`).
      * `:format` - The archive format (default: `:tar_gz`).

  ## Returns

    * A string containing the created archive path.

  ## Examples

      iex> input = %{host: "github.com", owner: "elixir-lang", repo: "elixir", ref: "main"}
      iex> Gitly.Utils.Archive.create_archive_path(input, root: "/tmp")
      "/tmp/github/elixir-lang/elixir/main.tar.gz"
  """
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

  @doc """
  Downloads an archive from the given URL and saves it to the given path.

  ## Parameters

    * `url` - The URL of the archive to download.
    * `path` - The local path where the archive should be saved.
    * `opts` - A keyword list of options:
      * `:retry` - The retry strategy (default: `:transient`).

  ## Returns

    * `{:ok, path}` if the download was successful.
    * `{:error, reason}` if the download failed.

  ## Examples

      iex> Gitly.Utils.Archive.download("https://example.com/archive.zip", "/tmp/archive.zip")
      {:ok, "/tmp/archive.zip"}
  """
  @spec download(String.t(), Path.t(), Keyword.t()) :: {:ok, Path.t()} | {:error, String.t()}
  def download(url, path, opts \\ []) do
    retry = Keyword.get(opts, :retry, :transient)
    try do
      with true <- Gitly.Utils.Net.is_online?(),
          :ok <- FS.ensure_dir_exists(path),
           opts =[
            into: stream_to_file!(path),
            redirect_log_level: false,
            compressed: true,
            decode_body: false,
            retry: retry
          ],
           %Req.Response{status: 200} <- Req.get!(url, opts) do
        {:ok, path}
      else
        %Req.Response{status: code} ->
          File.rm(path)
          {:error, "Failed to download archive: #{code}"}

        {:error, reason} ->
          {:error, reason}

        false ->
          {:error, "Failed to download archive: offline"}
      end
    rescue
      e in RuntimeError -> {:error, e.message}
      e -> {:error, "Failed to download archive: #{inspect(e)}"}
    end
  end

  @doc """
  Extracts an archive from the given file path to the given destination.

  ## Parameters

    * `file_path` - The path to the archive file.
    * `dest` - The destination directory where the archive should be extracted.
    * `opts` - A keyword list of options:
      * `:force` - Whether to force extraction even if the destination exists (default: `false`).
      * `:overwrite` - Whether to overwrite existing files (default: `false`).

  ## Returns

    * `{:ok, dest}` if the extraction was successful.
    * `{:error, reason}` if the extraction failed.

  ## Examples

      iex> Gitly.Utils.Archive.extract("/tmp/archive.zip", "/tmp/extracted")
      {:ok, "/tmp/extracted"}
  """
  @spec extract(Path.t(), Path.t(), Gitly.opts()) :: {:ok, Path.t()} | {:error, String.t()}
  def extract(file_path, dest, opts \\ []) do
    force = Keyword.get(opts, :force, false)
    overwrite = Keyword.get(opts, :overwrite, false)

    with {:ok, temp_dir} <- Briefly.create(directory: true),
         {:ok, _} <- Extractor.extract(file_path, temp_dir),
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

  # Private functions

  @doc false
  defp stream_to_file!(file_path) do
    if File.dir?(file_path) do
      raise "Cannot open directory as file: #{file_path}"
    end

    case File.open(file_path, [:write, :binary]) do
      {:ok, file} ->
        fn
          {:data, data}, acc ->
            IO.binwrite(file, data)
            {:cont, acc}

          :done, acc ->
            File.close(file)
            {:cont, acc}

          _, _ ->
            File.close(file)
            {:halt, :error}
        end

      {:error, reason} ->
        raise "Failed to open file #{file_path}: #{inspect(reason)}"
    end
  end
end
