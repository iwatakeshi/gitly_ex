defmodule GitlyUtilsNetTest do
  use ExUnit.Case
  import Mox

  setup :verify_on_exit!

  test "is_offline?/0 returns true when offline" do
    Gitly.Utils.NetMock
    |> expect(:is_offline?, fn -> true end)

    assert Gitly.Utils.Net.is_offline?() == true
  end

  test "is_online?/0 returns true when online" do
    Gitly.Utils.NetMock
    |> expect(:is_online?, fn -> true end)

    assert Gitly.Utils.Net.is_online?() == true
  end

  describe "actual implementation" do
    setup do
      previous_net_module = Application.get_env(:gitly, :net_module)
      Application.put_env(:gitly, :net_module, Gitly.Utils.Net.INet)

      on_exit(fn ->
        Application.put_env(:gitly, :net_module, previous_net_module)
      end)
    end

    test "is_online?/0 returns boolean" do
      result = Gitly.Utils.Net.is_online?()
      assert is_boolean(result)
    end

    test "is_offline?/0 returns boolean" do
      result = Gitly.Utils.Net.is_offline?()
      assert is_boolean(result)
    end
  end
end
