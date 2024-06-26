defmodule Gitly do
  alias Gitly.Parser
  alias Gitly.Utils.Archive, as: ArchiveUtils
  alias Gitly.Utils.Git, as: GitUtils

  @type opts() :: [
    # If true, force the download of the archive.
    force: boolean(),
    # If true, use the local cache to download the archive.
    cache: boolean(),
    # If true, overwrite existing files when extracting the archive.
    overwrite: boolean(),
    # The ref to download from the repository.
    ref: String.t(),
    # The root path to store the archive.
    root: Path.t(),
    # The format of the archive.
    format: :zip  | :tar | :tar_gz | :tgz
  ]

  @spec gitly(binary(), opts()) :: {:ok, Path.t()} | {:error, String.t()}
  def gitly(repository, opts \\ []) do
    with {:ok, path1} <- download(repository, opts),
         {:ok, path2} <- extract(path1, opts) do
          {:ok, path2}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Downloads a repository and returns the path to the archive.
  """
  @spec download(binary(), opts()) :: {:error, any()} | {:ok, binary()}
  def download(repository, opts \\ []) do
    with {:ok, result} <- Parser.parse(repository, Enum.into(opts, %{})),
         url <- ArchiveUtils.build_archive_url(result),
         path <- build_archive_path(result, opts),
         tasks <- Gitly.Task.Builder.build_task_order({url, path}, opts),
         result <- Gitly.Task.run_until_success(tasks) do
      case result do
        %{error: [], result: [_]} -> {:ok, path}
        %{error: [_], result: [_]} -> {:ok, path}
        %{error: errors, result: []} -> {:error, errors}
      end
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @spec extract(Path.t(), opts()) :: {:ok, Path.t()} | {:error, String.t()}
  def extract(path, opts) when is_binary(path) and is_list(opts),
  do: ArchiveUtils.extract(path, ArchiveUtils.Type.trim_extension(path), opts)

  @doc """
  Extracts an archive to a given destination.
  """
  @spec extract(Path.t(), Path.t(), opts()) :: {:ok, Path.t()} | {:error, String.t()}
  def extract(path, dest, opts), do: ArchiveUtils.extract(path, dest, opts)

  @spec build_archive_path(map(), opts()) :: Path.t()
  defp build_archive_path(input, opts),
    do:
      input
      |> GitUtils.create_repo_url()
      |> URI.parse()
      |> Map.merge(input)
      |> ArchiveUtils.create_archive_path(opts)
end
