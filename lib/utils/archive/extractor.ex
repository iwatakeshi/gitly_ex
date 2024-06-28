defmodule Gitly.Utils.Archive.Extractor do
  @moduledoc """
  Provides functionality to extract various types of archives.

  This module supports extracting ZIP, TAR, TAR.GZ, and TGZ archives.
  """

  alias Gitly.Utils.Archive.Type, as: ArchiveType

  @type extract_result :: {:ok, Path.t()} | {:error, String.t()}

  @doc """
  Extracts an archive to the given destination.

  ## Parameters

    * `path` - The path to the archive file.
    * `dest` - The destination directory where the archive should be extracted.

  ## Returns

    * `{:ok, dest}` if the extraction was successful.
    * `{:error, reason}` if the extraction failed or the archive type is unsupported.

  ## Examples

      iex> Gitly.Utils.Archive.Extractor.extract("example.zip", "/tmp/extract")
      {:ok, "/tmp/extract"}

      iex> Gitly.Utils.Archive.Extractor.extract("example.rar", "/tmp/extract")
      {:error, "Unsupported archive type"}
  """
  @spec extract(Path.t(), Path.t()) :: extract_result
  def extract(path, dest) do
    path
    |> ArchiveType.from_path()
    |> do_extract(path, dest)
  end

  @doc false
  @spec do_extract(ArchiveType.ext(), Path.t(), Path.t()) :: extract_result
  defp do_extract(:zip, path, dest), do: extract_zip(path, dest)
  defp do_extract(:tar, path, dest), do: extract_tar(path, dest, compressed: false)

  defp do_extract(type, path, dest) when type in [:tar_gz, :tgz],
    do: extract_tar(path, dest, compressed: true)

  defp do_extract(_, _, _), do: {:error, "Unsupported archive type"}

  @doc false
  @spec extract_zip(Path.t(), Path.t()) :: extract_result
  defp extract_zip(path, dest) do
    case :zip.extract(String.to_charlist(path), [{:cwd, String.to_charlist(dest)}]) do
      {:ok, _} -> {:ok, dest}
      {:error, reason} -> {:error, "Failed to extract ZIP: #{inspect(reason)}"}
    end
  end

  @doc false
  @spec extract_tar(Path.t(), Path.t(), keyword()) :: extract_result
  defp extract_tar(path, dest, opts) do
    tar_opts = [
      {:cwd, String.to_charlist(dest)} | if(opts[:compressed], do: [:compressed], else: [])
    ]

    case :erl_tar.extract(String.to_charlist(path), tar_opts) do
      :ok -> {:ok, dest}
      {:error, reason} -> {:error, "Failed to extract TAR: #{inspect(reason)}"}
    end
  end
end
