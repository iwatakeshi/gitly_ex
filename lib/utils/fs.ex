defmodule Gitly.Utils.FS do
  @unix_root  [
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

  @spec ensure_dir_exists(Path.t()) :: :ok | {:error, File.posix()}
  def ensure_dir_exists(path), do: path |> Path.dirname() |> File.mkdir_p()

  def root_path(), do: Path.join(System.user_home!(), ".gitly")

  @spec move(Path.t(), Path.t()) :: {:ok, Path.t()} | {:error, String.t()}
  def move(source, dest) do
    case File.rename(source, dest) do
      :ok -> {:ok, dest}
      {:error, reason} -> {:error, "Failed to move: #{inspect(reason)}"}
    end
  end

  @spec maybe_move(Path.t(), Path.t(), boolean()) :: {:ok, Path.t()} | {:error, String.t()}
  def maybe_move(source, dest, condition) when is_boolean(condition) do
    if condition == true, do: move(source, dest), else: {:ok, dest}
  end

  @spec maybe_rm_rf(Path.t(), boolean()) :: {:ok, Path.t()} | {:error, String.t()}
  def maybe_rm_rf(path, condition) when is_boolean(condition) do
    if condition == true do
      case File.rm_rf(path) do
        {:ok, _} -> {:ok, path}
        {:error, reason, _} -> {:error, "Failed to remove: #{inspect(reason)}"}
      end
    end

    {:ok, path}
  end

  def rm?(dest),
    do:
      dest not in (@unix_root ++ @windows_root ++ [".."]) and
        File.exists?(dest)
end
