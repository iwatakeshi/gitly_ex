defmodule Gitly.Executor do
  @moduledoc """
    A module to execute tasks recursively until one returns a truthy value or all tasks are exhausted.
  """

  @doc """
    Executes a list of tasks recursively until one returns a truthy value or all tasks are exhausted.

    ## Examples

        iex> Gitly.Executor.execute([fn -> false end, fn -> true end])
        true
  """
  def execute(tasks) when is_list(tasks) and length(tasks) > 0 do
    # Start the first task
    task = hd(tasks)
    Task.async(task)
    |> Task.await()
    |> case do
      # If the task returns a truthy value, we stop and return that value.
      result when result not in [nil, false] -> result
      # If the task returns a falsy value, we proceed to the next task.
      _ -> execute(tl(tasks))
    end
  end

  def execute([]), do: nil # or false, depending on your needs
end
