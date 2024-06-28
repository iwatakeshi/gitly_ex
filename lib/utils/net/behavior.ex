defmodule Gitly.Utils.Net.Behavior do
  @moduledoc """
  Defines a behavior for checking network connectivity.

  This behavior specifies functions to determine if the system is online or offline.
  Modules implementing this behavior should provide concrete implementations
  for these functions.
  """

  @doc """
  Checks if the system is offline.

  Implementations should return `true` if the system is offline, `false` otherwise.
  """
  @callback is_offline?() :: boolean()

  @doc """
  Checks if the system is online.

  Implementations should return `true` if the system is online, `false` otherwise.
  """
  @callback is_online?() :: boolean()
end
