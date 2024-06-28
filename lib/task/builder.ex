defmodule Gitly.Task.Builder do
  alias Gitly.Utils.Archive, as: ArchiveUtils
  alias Gitly.Utils.Net, as: NetUtils

  @moduledoc """
  A module to build a task order.
  """

  @doc """
  Builds a task order based on the given options.
  """
  @type build_task_order_opts() :: [
          url: String.t(),
          path: String.t(),
          force: boolean(),
          cache: boolean()
        ]
  @spec build_task_order(build_task_order_opts()) :: [%Gitly.Task{}]

  def build_task_order(opts) do
    url = Keyword.get(opts, :url, "")
    path = Keyword.get(opts, :path, "")
    force = Keyword.get(opts, :force, false)
    cache = Keyword.get(opts, :cache, false)

    cond do
      force && url != "" && path != "" ->
        [build_task(:remote, %{url: url, path: path})]

      cache && path != "" ->
        [build_task(:local, %{path: path})]

      url != "" && path != "" && NetUtils.is_online?() ->
        [
          build_task(:local, %{path: path}),
          build_task(:remote, %{url: url, path: path})
        ]

      url != "" && path != "" && NetUtils.is_offline?() ->
        [build_task(:local, %{path: path})]

      true ->
        []
    end
  end

  @spec build_task(:local, map()) :: %Gitly.Task{}
  defp build_task(:local, %{path: path}) do
    Gitly.Task.new(:local, fn ->
      if File.exists?(path), do: path, else: {:error, "Archive does not exist"}
    end)
  end

  @spec build_task(:remote, map()) :: %Gitly.Task{}
  defp build_task(:remote, %{url: url, path: path}) do
    Gitly.Task.new(:remote, fn -> ArchiveUtils.download(url, path) end)
  end
end
