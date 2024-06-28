defmodule Gitly.Utils.FS do
  @moduledoc """
  A module for file system operations.

  This module provides utility functions for common file system operations
  such as ensuring directories exist, moving files, and removing directories.
  """

  @unix_root [
    ".",
    "~",
    "/",
    "/usr",
    "/usr/local",
    "/var",
    "/var/tmp",
    "/tmp",
    "/opt",
    "/opt/local"
  ]

  @windows_root [
    "C:/",
    "D:/",
    "E:/",
    "F:/",
    "G:/",
    "H:/",
    "I:/",
    "J:/",
    "K:/",
    "L:/",
    "M:/",
    "N:/",
    "O:/",
    "P:/",
    "Q:/",
    "R:/",
    "S:/",
    "T:/",
    "U:/",
    "V:/",
    "W:/",
    "X:/",
    "Y:/",
    "Z:/"
  ]

  @doc """
  Ensures that the directory for the given path exists.

  Creates all necessary parent directories if they don't exist.

  ## Parameters

    * `path` - The path for which to ensure the directory exists.

  ## Returns

    * `:ok` if successful.
    * `{:error, reason}` if an error occurs.

  ## Examples

      iex> Gitly.Utils.FS.ensure_dir_exists("/tmp/new_dir/file.txt")
      :ok
  """
  @spec ensure_dir_exists(Path.t()) :: :ok | {:error, File.posix()}
  def ensure_dir_exists(path), do: path |> Path.dirname() |> File.mkdir_p()

  @doc """
  Returns the root path for Gitly.

  ## Returns

    * The path to the Gitly root directory.

  ## Examples

      iex> Gitly.Utils.FS.root_path()
      "/home/user/.gitly"
  """
  @spec root_path() :: Path.t()
  def root_path(), do: Path.join(System.user_home!(), ".gitly")

  @doc """
  Moves a file or directory from source to destination.

  ## Parameters

    * `source` - The source path.
    * `dest` - The destination path.

  ## Returns

    * `{:ok, dest}` if successful.
    * `{:error, reason}` if an error occurs.

  ## Examples

      iex> Gitly.Utils.FS.move("/tmp/source", "/tmp/dest")
      {:ok, "/tmp/dest"}
  """
  @spec move(Path.t(), Path.t()) :: {:ok, Path.t()} | {:error, String.t()}
  def move(source, dest) do
    case File.rename(source, dest) do
      :ok -> {:ok, dest}
      {:error, reason} -> {:error, "Failed to move: #{inspect(reason)}"}
    end
  end

  @doc """
  Conditionally moves a file or directory.

  ## Parameters

    * `source` - The source path.
    * `dest` - The destination path.
    * `condition` - Boolean condition determining whether to move.

  ## Returns

    * `{:ok, dest}` if moved or if condition is false.
    * `{:error, reason}` if an error occurs during move.

  ## Examples

      iex> Gitly.Utils.FS.maybe_move("/tmp/source", "/tmp/dest", true)
      {:ok, "/tmp/dest"}

      iex> Gitly.Utils.FS.maybe_move("/tmp/source", "/tmp/dest", false)
      {:ok, "/tmp/dest"}
  """
  @spec maybe_move(Path.t(), Path.t(), boolean()) :: {:ok, Path.t()} | {:error, String.t()}
  def maybe_move(source, dest, condition) when is_boolean(condition) do
    if condition, do: move(source, dest), else: {:ok, dest}
  end

  @doc """
  Conditionally removes a directory and all its contents.

  ## Parameters

    * `path` - The path to remove.
    * `condition` - Boolean condition determining whether to remove.

  ## Returns

    * `{:ok, path}` if removed or if condition is false.
    * `{:error, reason}` if an error occurs during removal.

  ## Examples

      iex> Gitly.Utils.FS.maybe_rm_rf("/tmp/to_remove", true)
      {:ok, "/tmp/to_remove"}

      iex> Gitly.Utils.FS.maybe_rm_rf("/tmp/to_keep", false)
      {:ok, "/tmp/to_keep"}
  """
  @spec maybe_rm_rf(Path.t(), boolean()) :: {:ok, Path.t()} | {:error, String.t()}
  def maybe_rm_rf(path, condition) when is_boolean(condition) do
    if condition do
      case File.rm_rf(path) do
        {:ok, _} -> {:ok, path}
        {:error, reason, _} -> {:error, "Failed to remove: #{inspect(reason)}"}
      end
    else
      {:ok, path}
    end
  end

  @doc """
  Checks if a path is safe to remove.

  Prevents removal of important system directories and non-existent paths.

  ## Parameters

    * `dest` - The path to check.

  ## Returns

    * `true` if the path is safe to remove.
    * `false` otherwise.

  ## Examples

      iex> Gitly.Utils.FS.rm?("/tmp/safe_to_remove")
      true

      iex> Gitly.Utils.FS.rm?("/")
      false
  """
  @spec rm?(Path.t()) :: boolean()
  def rm?(dest),
    do:
      dest not in (@unix_root ++ @windows_root ++ [".."]) and
        File.exists?(dest)
end
