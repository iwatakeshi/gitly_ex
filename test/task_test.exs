defmodule GitlyTaskTest do
  use ExUnit.Case

  test "run" do
    task = Gitly.Task.new(:local, fn -> 1 end)
    assert Gitly.Task.run(task).result == 1
  end

  test "async" do
    task = Gitly.Task.new(:local, fn -> 1 end)
    assert Gitly.Task.run(task).result == 1
  end

  test "update_error" do
    task = Gitly.Task.new(:local, fn -> 1 end)
    task = Gitly.Task.update_error(task, "error")
    assert task.error == "error"
  end

  test "update_result" do
    task = Gitly.Task.new(:local, fn -> 1 end)
    task = Gitly.Task.update_result(task, 2)
    assert task.result == 2
  end

  test "error?" do
    task = Gitly.Task.new(:local, fn -> :error end)
    assert task |> Gitly.Task.run() |> Gitly.Task.error?() == true

    task = Gitly.Task.new(:local, fn -> false end)
    assert task |> Gitly.Task.run() |> Gitly.Task.error?() == false

    task2 = Gitly.Task.new(:local, fn -> {:error, {:not_found, 404} } end)
    assert task2 |> Gitly.Task.run() |> Gitly.Task.error?() == true
  end

  test "success?" do
    task = Gitly.Task.new(:local, fn -> true end)
    assert task |> Gitly.Task.run() |> Gitly.Task.success?() == true
  end


  test "run_all_tasks" do
    tasks = Gitly.Task.from_list(
      [
        one: fn -> 1 end,
        two: fn -> 2 end,
      ]
    )

    result = Gitly.Task.run_all_tasks(tasks)

    assert result == %{error: [], result: [1, 2]}
  end

  test "run_until_error" do
    tasks = Gitly.Task.from_list(
      [
        one: fn -> 1 end,
        two: fn -> {:error, "error"} end,
        three: fn -> 3 end,
      ]
    )

    result = Gitly.Task.run_until_error(tasks)

    assert result == %{error: ["error"], result: [1]}
  end
end
