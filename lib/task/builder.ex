defmodule Gitly.Task.Builder do
  alias Gitly.Utils.Archive, as: ArchiveUtils

  @moduledoc """
  A module to build a task order.
  """

  @doc """
  Builds a task order based on the given options.
  """
  @spec build_task_order({String.t(), Path.t()}, Keyword.t()) :: [%Gitly.Task{}]
  def build_task_order({url, path}, force: true),
    do: [build_task(:remote, %{url: url, path: path})]

  @spec build_task_order({String.t(), Path.t()}, Keyword.t()) :: [%Gitly.Task{}]
  def build_task_order({_, path}, cache: true),
    do: [build_task(:local, %{path: path})]

  @spec build_task_order({String.t(), Path.t()}, Keyword.t()) :: [%Gitly.Task{}]
  def build_task_order({url, path}, _),
    do:
      if(
        Gitly.Utils.Net.is_offline?(),
        do: [build_task(:local, %{path: path})],
        else: [
          build_task(:local, %{path: path}),
          build_task(:remote, %{url: url, path: path})
        ]
      )

  @spec build_task(:local, map()) :: %Gitly.Task{}
  defp build_task(:local, %{path: path}),
    do:
      Gitly.Task.new(:local, fn ->
        if File.exists?(path),
          do: path,
          else: {:error, "Archive does not exist"}
      end)

  @spec build_task(:remote, map()) :: %Gitly.Task{}
  defp build_task(:remote, %{url: url, path: path}),
    do: Gitly.Task.new(:remote, fn -> ArchiveUtils.download(url, path) end)
end
