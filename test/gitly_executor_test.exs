defmodule GitlyExecutorTest do
  use ExUnit.Case
  doctest Gitly.Executor

  test "execute" do
    assert Gitly.Executor.execute([fn -> false end, fn -> true end]) == true
  end
end
