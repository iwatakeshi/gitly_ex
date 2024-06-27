defmodule Gitly.Utils.NetTest do
  use ExUnit.Case, async: true
  import Mox

  setup :verify_on_exit!

  test "is_offline?/0 returns true when mocked to be offline" do
    Gitly.Utils.NetMock
    |> expect(:is_offline?, fn -> true end)

    assert Gitly.Utils.NetMock.is_offline?() == true
  end

  test "is_offline?/0 returns false when mocked to be online" do
    Gitly.Utils.NetMock
    |> expect(:is_offline?, fn -> false end)

    assert Gitly.Utils.NetMock.is_offline?() == false
  end

  test "is_online?/0 returns true when mocked to be online" do
    Gitly.Utils.NetMock
    |> expect(:is_online?, fn -> true end)

    assert Gitly.Utils.NetMock.is_online?() == true
  end

  test "is_online?/0 returns false when mocked to be offline" do
    Gitly.Utils.NetMock
    |> expect(:is_online?, fn -> false end)

    assert Gitly.Utils.NetMock.is_online?() == false
  end
end
