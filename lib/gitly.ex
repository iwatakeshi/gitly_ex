defmodule Gitly do
  @moduledoc """
  A module for downloading and extracting Git repositories.

  This module provides functionality to download repositories from various Git hosting services,
  extract them, and manage the process with various options for caching, retrying, and formatting.
  """

  alias Gitly.Parser
  alias Gitly.Utils.Archive, as: ArchiveUtils
  alias Gitly.Utils.Git, as: GitUtils

  @type retry_fun :: (Req.Request.t(), Req.Response.t() | Exception.t() ->
                        boolean() | {:delay, non_neg_integer()} | nil)
  @type retry_delay_fun :: (non_neg_integer() -> non_neg_integer())
  @type opts() :: [
          force: boolean(),
          cache: boolean(),
          overwrite: boolean(),
          retry: :safe_transient | :transient | retry_fun() | false,
          retry_delay: retry_delay_fun(),
          retry_log_level: atom() | false,
          max_retries: non_neg_integer(),
          ref: String.t(),
          root: Path.t(),
          format: :zip | :tar | :tar_gz | :tgz
        ]

  @doc """
  Downloads a repository and returns the path to the extracted archive.

  ## Parameters

    * `repository` - The repository identifier (e.g., "username/repo").
    * `opts` - A keyword list of options (see "Options" section).

  ## Options

    * `:force` - If true, force the download of the archive.
    * `:cache` - If true, use the local cache to download the archive.
    * `:overwrite` - If true, overwrite existing files when extracting the archive.
    * `:retry` - Retry options for Req. See https://hexdocs.pm/req/Req.Steps.html#retry/1-request-options
    * `:retry_delay` - Function to determine delay between retries. Default is exponential backoff.
    * `:retry_log_level` - The log level for retry logs. Set to false to disable logging.
    * `:max_retries` - The maximum number of retries before giving up.
    * `:ref` - The ref to download from the repository.
    * `:root` - The root path to store the archive.
    * `:format` - The format of the archive (:zip, :tar, :tar_gz, or :tgz).

  ## Returns

    * `{:ok, path}` where `path` is the location of the extracted repository.
    * `{:error, reason}` if the operation fails.

  ## Examples

      iex> Gitly.gitly("iwatakeshi/gitly")
      {:ok, "/path/to/extracted/repo"}
  """
  @spec gitly(binary(), opts()) :: {:ok, Path.t()} | {:error, String.t()}
  def gitly(repository, opts \\ []) do
    with {:ok, source} <- download(repository, opts),
         {:ok, dest} <- extract(source, opts) do
      {:ok, dest}

      with {:ok, result} <- File.ls(dest) do
        case result do
          [dir] -> {:ok, Path.join(dest, dir)}
          _ -> {:ok, dest}
        end
      else
        # coveralls-ignore-next-line
        {:error, reason} -> {:error, reason}
      end
    else
      # coveralls-ignore-next-line
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Downloads a repository and returns the path to the archive.

  ## Parameters

    * `repository` - The repository identifier (e.g., "username/repo").
    * `opts` - A keyword list of options (see "Options" section in `gitly/2`).

  ## Returns

    * `{:ok, path}` where `path` is the location of the downloaded archive.
    * `{:error, reason}` if the download fails.

  ## Examples

      iex> Gitly.download("iwatakeshi/gitly")
      {:ok, "/path/to/downloaded/archive.zip"}
  """
  @spec download(binary(), opts()) :: {:error, any()} | {:ok, binary()}
  def download(repository, opts \\ []) do
    with {:ok, result} <- Parser.parse(repository, Enum.into(opts, %{})),
         url <- ArchiveUtils.build_archive_url(result),
         path <- build_archive_path(result, opts),
         task_opts <- Keyword.merge([url: url, path: path], opts),
         tasks <- Gitly.Task.Builder.build_task_order(task_opts),
         result <- Gitly.Task.run_until_success(tasks) do
      case result do
        %{error: [], result: [_]} -> {:ok, path}
        %{error: [_], result: [_]} -> {:ok, path}
        %{error: errors, result: []} -> {:error, errors}
      end
    else
      # coveralls-ignore-next-line
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Extracts an archive to a given destination.

  ## Parameters

    * `path` - The path to the archive file.
    * `opts` - A keyword list of options (see "Options" section in `gitly/2`).

  ## Returns

    * `{:ok, path}` where `path` is the location of the extracted contents.
    * `{:error, reason}` if the extraction fails.

  ## Examples

      iex> Gitly.extract("/path/to/archive.zip")
      {:ok, "/path/to/extracted/contents"}
  """
  @spec extract(Path.t(), opts()) :: {:ok, Path.t()} | {:error, String.t()}
  def extract(path, opts) when is_binary(path) and is_list(opts),
    # coveralls-ignore-next-line
    do: ArchiveUtils.extract(path, ArchiveUtils.Type.trim_extension(path), opts)

  @doc """
  Extracts an archive to a specified destination.

  ## Parameters

    * `path` - The path to the archive file.
    * `dest` - The destination path for extraction.
    * `opts` - A keyword list of options (see "Options" section in `gitly/2`).

  ## Returns

    * `{:ok, path}` where `path` is the location of the extracted contents.
    * `{:error, reason}` if the extraction fails.

  ## Examples

      iex> Gitly.extract("/path/to/archive.zip", "/path/to/destination")
      {:ok, "/path/to/destination"}
  """
  @spec extract(Path.t(), Path.t(), opts()) :: {:ok, Path.t()} | {:error, String.t()}
  def extract(path, dest, opts),
    # coveralls-ignore-next-line
    do: ArchiveUtils.extract(path, dest, opts)

  @doc false
  @spec build_archive_path(map(), opts()) :: Path.t()
  defp build_archive_path(input, opts),
    do:
      input
      |> GitUtils.create_repo_url()
      |> URI.parse()
      |> Map.merge(input)
      |> ArchiveUtils.create_archive_path(opts)
end
