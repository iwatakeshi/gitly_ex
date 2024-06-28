defmodule GitlyTaskBuilderTest do
  use ExUnit.Case
  import Mox

  setup :verify_on_exit!

  describe "online (using real INet implementation)" do
    setup do
      previous_net_module = Application.get_env(:gitly_ex, :net_module)
      Application.put_env(:gitly_ex, :net_module, Gitly.Utils.Net.INet)

      on_exit(fn ->
        Application.put_env(:gitly_ex, :net_module, previous_net_module)
      end)
    end

    test "build_task_order/1 returns a local task" do
      tasks = Gitly.Task.Builder.build_task_order(url: "", path: "path", cache: true)
      assert length(tasks) == 1
      assert Enum.at(tasks, 0).label == :local
    end

    test "build_task_order/1 returns a remote task" do
      tasks = Gitly.Task.Builder.build_task_order(url: "url", path: "path", force: true)
      assert length(tasks) == 1
      assert Enum.at(tasks, 0).label == :remote
    end

    test "build_task_order/1 returns a local and remote task" do
      tasks = Gitly.Task.Builder.build_task_order(url: "url", path: "path")
      assert length(tasks) == 2
      assert Enum.at(tasks, 0).label == :local
      assert Enum.at(tasks, 1).label == :remote
    end
  end

  describe "offline (using mock)" do
    setup do
      Mox.stub(Gitly.Utils.NetMock, :is_online?, fn -> false end)
      Mox.stub(Gitly.Utils.NetMock, :is_offline?, fn -> true end)

      previous_net_module = Application.get_env(:gitly_ex, :net_module)
      Application.put_env(:gitly_ex, :net_module, Gitly.Utils.NetMock)

      on_exit(fn ->
        Application.put_env(:gitly_ex, :net_module, previous_net_module)
      end)
    end

    test "build_task_order/1 returns only a local task" do
      tasks = Gitly.Task.Builder.build_task_order(url: "url", path: "path")
      assert length(tasks) == 1
      assert Enum.at(tasks, 0).label == :local
    end

    test "build_task_order/1 returns no tasks when force: true and no local path" do
      tasks = Gitly.Task.Builder.build_task_order(url: "url", path: "", force: true)
      assert Enum.empty?(tasks)
    end
  end
end
