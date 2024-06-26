defmodule Gitly.Utils.FS do
  def find_root_dir(path) do
    case File.ls(path) do
      {:ok, [single_item]} ->
        if File.dir?(Path.join(path, single_item)), do: {:ok, single_item}, else: {:ok, "."}

      {:ok, _} ->
        {:ok, "."}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec ensure_file_exists(Path.t()) :: :ok | {:error, File.posix()}
  def ensure_file_exists(path),
    do:
      if(File.exists?(path),
        do: :ok,
        else: File.mkdir_p(Path.dirname(path))
      )

  def root_path(), do: Path.join(System.user_home!(), ".gitly")

  @spec copy(Path.t(), Path.t()) :: {:ok, Path.t()} | {:error, String.t()}
  def copy(source, dest) do
    case File.cp_r(source, dest) do
      {:ok, _} -> {:ok, dest}
      {:error, reason, _} -> {:error, "Failed to copy: #{inspect(reason)}"}
    end
  end

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

  def rm?(dest), do: dest not in [".", "~"] and File.exists?(dest)
end
