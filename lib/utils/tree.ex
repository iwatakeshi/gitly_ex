# Credits: https://github.com/kddnewton/tree/blob/main/tree.exs
defmodule Gitly.Utils.Tree do
  def walk(directory, prefix \\ ""), do: walk(%{dirs: 0, files: 0}, directory, prefix)

  def walk(counts = %{dirs: wdirs, files: wfiles}, directory, prefix) do
    filepaths = directory |> File.ls |> filter |> Enum.sort |> Enum.with_index

    Enum.reduce(filepaths, %{dirs: wdirs + 1, files: wfiles}, fn({filepath, index}, %{dirs: cdirs, files: cfiles}) ->
      new_prefix = output(prefix, filepath, index, filepaths |> Enum.count)

      %{dirs: dirs, files: files} = walk_file(counts, Path.join(directory, filepath), new_prefix)
      %{dirs: cdirs + dirs, files: cfiles + files}
    end)
  end

  defp filter({:ok, filepaths}), do: filepaths |> Enum.reject(&hidden?/1)

  defp hidden?(filepath), do: filepath |> String.slice(0, 1) == "."

  defp output(prefix, filepath, index, total) when index == total - 1 do
    IO.puts("#{prefix}└── #{filepath}")
    "#{prefix}    "
  end

  defp output(prefix, filepath, _index, _total) do
    IO.puts("#{prefix}├── #{filepath}")
    "#{prefix}│   "
  end

  defp walk_file(counts = %{dirs: dirs, files: files}, filepath, prefix) do
    if filepath |> File.dir? do
      walk(counts, filepath, prefix)
    else
      %{dirs: dirs, files: files + 1}
    end
  end
end
