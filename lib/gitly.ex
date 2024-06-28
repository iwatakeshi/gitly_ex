defmodule Gitly do
  alias Gitly.Parser
  alias Gitly.Utils.Archive, as: ArchiveUtils
  alias Gitly.Utils.Git, as: GitUtils

  @type retry_fun :: (Req.Request.t(), Req.Response.t() | Exception.t() -> boolean() | {:delay, non_neg_integer()} | nil)
  @type retry_delay_fun :: (non_neg_integer() -> non_neg_integer())
  @type opts() :: [
          # If true, force the download of the archive.
          force: boolean(),
          # If true, use the local cache to download the archive.
          cache: boolean(),
          # If true, overwrite existing files when extracting the archive.
          overwrite: boolean(),
          # Retry options for Req. See https://hexdocs.pm/req/Req.Steps.html#retry/1-request-options
          retry: :safe_transient | :transient | retry_fun() | false,
          # If not set, which is the default, the retry delay is determined by the value of retry-delay header
          # on HTTP 429/503 responses. If the header is not set, the default delay follows a simple exponential backoff:
          # 1s, 2s, 4s, 8s, ...
          # It can also be set to a function that receives the retry count (starting at 0) and returns the delay,
          # the number of milliseconds to sleep before making another attempt.
          retry_delay: retry_delay_fun(),
          retry_log_level: atom() | false,
          max_retries: non_neg_integer(),
          # The ref to download from the repository.
          ref: String.t(),
          # The root path to store the archive.
          root: Path.t(),
          # The format of the archive.
          format: :zip | :tar | :tar_gz | :tgz
        ]

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
        {:error, reason} -> {:error, reason}
      end
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
         task_opts <- Keyword.merge([url: url, path: path], opts),
         tasks <- Gitly.Task.Builder.build_task_order(task_opts),
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
