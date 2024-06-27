defmodule Gitly.Utils.Net do
  @moduledoc """
  A module to check if the user is online or offline.
  """

  defp net_module, do: Application.get_env(:gitly, :net_module)

  @doc """
  Checks if the user is offline.
  """
  def is_offline? do
    net_module().is_offline?
  end

  @doc """
  Checks if the user is online.
  """
  def is_online? do
    net_module().is_online?
  end

end

defmodule Gitly.Utils.Net.INet do
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
