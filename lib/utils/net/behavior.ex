defmodule Gitly.Utils.Net.Behavior do
  @moduledoc """
  A module to check if the user is online or offline.
  """

  @callback is_offline?() :: boolean()
  @callback is_online?() :: boolean()
end
