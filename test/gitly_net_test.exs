defmodule GitlyNetTest do
  use ExUnit.Case
  doctest Gitly.Utils.Net

  test "is_offline? returns false if the user is offline" do
    assert Gitly.Utils.Net.is_offline?() == false
  end

  test "is_online? returns true if the user is online" do
    assert Gitly.Utils.Net.is_online?() == true
  end
end
