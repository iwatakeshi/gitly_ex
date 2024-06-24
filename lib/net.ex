defmodule Gitly.Net do
  @moduledoc """
    A module to check if the user is online or offline.
  """

  @doc """
    Checks if the user is offline.

    ## Examples

        iex> Gitly.Net.is_offline?
        false
  """
  def is_offline? do
    case :inet.getaddr(~c"www.google.com", :inet) do
      {:ok, _} -> false
      {:error, _} -> true
    end
  end

  @doc """
    Checks if the user is online.

    ## Examples

        iex> Gitly.Net.is_online?
        true
  """
  def is_online?, do: not is_offline?()
end
