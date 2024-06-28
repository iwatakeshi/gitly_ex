defmodule GitlyTest do
  use ExUnit.Case
  import Mox

  @fixtures_dir Path.join(__DIR__, "fixtures")
  @gitly_dir Path.join(@fixtures_dir, "gitly_test")
  @test_repo "iwatakeshi/gitly_ex"

  setup do
    File.mkdir_p!(@gitly_dir)
    on_exit(fn -> File.rm_rf!(@gitly_dir) end)
  end

  setup :verify_on_exit!

  describe "online" do
    @describetag :gitly_online
    setup do
      previous_net_module = Application.get_env(:gitly, :net_module)
      Application.put_env(:gitly, :net_module, Gitly.Utils.Net.INet)

      on_exit(fn ->
        Application.put_env(:gitly, :net_module, previous_net_module)
      end)
    end

    test "gitly/2 downloads and extracts a repository" do
      {:ok, path} = Gitly.gitly(@test_repo, root: Path.join(@gitly_dir, ["online", "1"]))
      assert File.exists?(path)
      assert File.dir?(path)
      assert File.exists?(Path.join(path, "README.md"))

      on_exit(fn -> File.rm_rf!(path) end)
    end

    test "gitly/2 with force option re-downloads the repository" do
      root_dir = Path.join(@gitly_dir, ["online", "2"])
      {:ok, path1} = Gitly.gitly(@test_repo, root: root_dir)
      File.write!(Path.join(path1, "test_file.txt"), "test content")

      {:ok, path2} = Gitly.gitly(@test_repo, root: root_dir, force: true)
      assert path1 == path2
      refute File.exists?(Path.join(path2, "test_file.txt"))

      on_exit(fn -> File.rm_rf!(path1) end)
    end

    test "gitly/2 with non-existent repository returns error" do
      assert {:error, _} = Gitly.gitly("non/existent", root: @gitly_dir)
    end

    test "gitly/3 downloads and extracts a repository using a different ref" do
      {:ok, path} =
        Gitly.gitly("iwatakeshi/gitly",
          ref: "master",
          root: Path.join(@gitly_dir, ["online", "3"])
        )

      assert File.exists?(path)
      assert File.dir?(path)
      assert File.exists?(Path.join(path, "README.md"))

      on_exit(fn -> File.rm_rf!(path) end)
    end
  end

  describe "offline" do
    @describetag :gitly_offline
    setup do
      Mox.stub(Gitly.Utils.NetMock, :is_online?, fn -> false end)
      Mox.stub(Gitly.Utils.NetMock, :is_offline?, fn -> true end)

      previous_net_module = Application.get_env(:gitly, :net_module)
      Application.put_env(:gitly, :net_module, Gitly.Utils.NetMock)

      on_exit(fn ->
        Application.put_env(:gitly, :net_module, previous_net_module)
      end)
    end

    test "gitly/2 uses cached repository when offline" do
      root_dir = Path.join(@gitly_dir, ["offline", "1"])
      # First, download the repository while online
      Application.put_env(:gitly, :net_module, Gitly.Utils.Net.INet)
      {:ok, online_path} = Gitly.gitly(@test_repo, root: root_dir)
      Application.put_env(:gitly, :net_module, Gitly.Utils.NetMock)

      # Now try to get it while offline
      {:ok, offline_path} = Gitly.gitly(@test_repo, root: root_dir)
      assert online_path == offline_path
      assert File.exists?(offline_path)

      on_exit(fn -> File.rm_rf!(online_path) end)
    end

    test "gitly/2 returns error when repository is not cached and offline" do
      assert {:error, _} = Gitly.gitly("uncached/repo", root: @gitly_dir)
    end

    test "gitly/2 with force option returns error when offline" do
      # Req.Test.stub(ReqStub, fn conn ->
      #   Req.Test.transport_error(conn, :econnrefused)
      # end)
      # Req.Test.expect(ReqStub, &Req.Test.transport_error(&1, :econnrefused))
      assert Gitly.Utils.NetMock.is_offline?()
      assert {:error, _} = Gitly.gitly(@test_repo, root: @gitly_dir, force: true)
    end
  end
end
