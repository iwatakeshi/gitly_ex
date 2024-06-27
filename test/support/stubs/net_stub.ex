defmodule Gitly.Utils.Net.Stub do
  @moduledoc """
  A module to check if the user is online or offline.
  """

  @behaviour Gitly.Utils.Net.Behavior

  @impl Gitly.Utils.Net.Behavior
  def is_offline?() do
    false
  end

  @impl Gitly.Utils.Net.Behavior
  def is_online?() do
    true
  end
end
