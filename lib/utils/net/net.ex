defmodule Gitly.Utils.Net do
  @behaviour Gitly.Utils.Net.Behavior
  @moduledoc """
  A module to check if the user is online or offline.
  """

  @doc """
  Checks if the user is offline.

  ## Examples

      iex> Gitly.Utils.Net.is_offline?
      false
  """
  @impl true
  @spec is_offline?() :: boolean()
  def is_offline? do
    case :inet.getaddr(~c"www.google.com", :inet) do
      {:ok, _} -> false
      {:error, _} -> true
    end
  end

  @doc """
  Checks if the user is online.

  ## Examples

      iex> Gitly.Utils.Net.is_online?
      true
  """
  @impl true
  @spec is_online?() :: boolean()
  def is_online?, do: not is_offline?()
end
