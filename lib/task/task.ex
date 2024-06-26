defmodule Gitly.Task do
  @moduledoc """
  A struct to represent a task.
  """
  defstruct [:label, :task, :error, :result]

  def new(label, task), do: %__MODULE__{label: label, task: task, error: nil}

  @spec run(%Gitly.Task{}, number()) :: %Gitly.Task{}
  def run(%__MODULE__{task: t} = task, timeout \\ 5000) do
    try do
      result = Task.async(t) |> Task.await(timeout)

      cond do
        is_error_result?(result) ->
          %__MODULE__{task | error: handle_error_result(result)}

        true ->
          %__MODULE__{task | result: result}
      end
    catch
      _ -> %__MODULE__{task | error: "Task failed"}
    end
  end

  def update_error(%__MODULE__{error: _} = t, error), do: %__MODULE__{t | error: error}
  def update_result(%__MODULE__{result: _} = t, result), do: %__MODULE__{t | result: result}

  def error?(%__MODULE__{error: nil}), do: false
  def error?(%__MODULE__{error: _}), do: true

  def success?(%__MODULE__{result: nil}), do: false
  def success?(%__MODULE__{result: _}), do: true

  def from_list(list) do
    Enum.map(list, fn {label, task} -> new(label, task) end)
  end

  @doc """
  Run all tasks asynchronously.
  """
  @spec run_all_tasks([%__MODULE__{}]) :: map()
  def run_all_tasks(tasks) do
    tasks
    |> Enum.map(&__MODULE__.run/1)
    |> Enum.reduce(%{error: [], result: []}, fn task, acc ->
      case task.error do
        nil -> Map.update!(acc, :result, &[task.result | &1])
        error -> Map.update!(acc, :error, &[error | &1])
      end
    end)
    |> Map.update!(:result, &Enum.reverse/1)
    |> Map.update!(:error, &Enum.reverse/1)
  end

  @doc """
  Run tasks one by one and stop when a task succeeds.
  """
  @spec run_until_success([%__MODULE__{}], number()) :: map()
  def run_until_success(tasks, timeout \\ 5000) do
    Enum.reduce_while(tasks, %{result: [], error: []}, fn task, acc ->
      case __MODULE__.run(task, timeout) do
        %__MODULE__{error: nil, result: result} ->
          {:halt, Map.update!(acc, :result, &[result | &1])}

        %__MODULE__{error: error} ->
          {:cont, Map.update!(acc, :error, &[error | &1])}
      end
    end)
    |> Map.update!(:result, &Enum.reverse/1)
    |> Map.update!(:error, &Enum.reverse/1)
  end

  @doc """
  Run all tasks but stop when an error occurs.
  """
  @spec run_until_error([%__MODULE__{}], number()) :: map()
  def run_until_error(tasks, timeout \\ 5000) do
    Enum.reduce_while(tasks, %{result: [], error: []}, fn task, acc ->
      case __MODULE__.run(task, timeout) do
        %__MODULE__{error: nil, result: result} ->
          {:cont, Map.update!(acc, :result, &[result | &1])}

        %__MODULE__{error: error} ->
          {:halt, Map.update!(acc, :error, &[error | &1])}
      end
    end)
    |> Map.update!(:result, &Enum.reverse/1)
    |> Map.update!(:error, &Enum.reverse/1)
  end

  defp is_error_result?(result) when is_map(result), do: Map.has_key?(result, :error)
  defp is_error_result?(result) when is_list(result), do: Keyword.has_key?(result, :error)
  defp is_error_result?(result) when is_tuple(result), do: elem(result, 0) == :error
  defp is_error_result?(:error), do: true
  defp is_error_result?(_), do: false

  defp handle_error_result(result) when is_map(result), do: result[:error]
  defp handle_error_result(result) when is_list(result), do: result[:error]
  defp handle_error_result(result) when is_tuple(result), do: elem(result, 1)
  defp handle_error_result(:error), do: "Task failed"
  defp handle_error_result(_), do: "Task failed"
end
