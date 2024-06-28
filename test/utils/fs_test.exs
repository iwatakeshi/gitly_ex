defmodule GitlyUtilsFSTest do
  use ExUnit.Case
  alias Gitly.Utils.FS

  @fixture_dir Path.join(__DIR__, "fixtures")
  @test_dir Path.join(@fixture_dir, "fs_test")
  @fs_test_file_a Path.join(@test_dir, "a/fs_test.txt")
  @fs_test_file_b Path.join(@test_dir, "b/fs_test.txt")

  setup_all do
    # Create a specific directory for this test module
    File.mkdir_p!(@test_dir)

    on_exit(fn ->
      # Clean up only the directory specific to this test module
      File.rm_rf!(@test_dir)
    end)

    :ok
  end

  setup do
    # Create directories for each test
    File.mkdir_p!(Path.dirname(@fs_test_file_a))
    File.mkdir_p!(Path.dirname(@fs_test_file_b))

    # Make sure the file exists before each test
    File.write!(@fs_test_file_a, "")

    on_exit(fn ->
      # Clean up files after each test
      File.rm(@fs_test_file_a)
      File.rm(@fs_test_file_b)
    end)

    :ok
  end

  test "ensure_dir_exists/1 creates directory when it does not exist" do
    path = Path.join(@test_dir, "a/new_dir")

    refute File.exists?(path)
    assert FS.ensure_dir_exists(path) == :ok
  end

  test "ensure_dir_exists/1 does not create directory when it exists" do
    path = Path.join(@test_dir, "a/existing_dir")
    File.mkdir_p!(path)

    assert File.exists?(path)
    assert FS.ensure_dir_exists(path) == :ok
    assert File.exists?(path)
  end

  test "root_path/0 returns root path" do
    assert FS.root_path() == Path.join(System.user_home!(), ".gitly")
  end

  test "move/2 moves file" do
    assert File.exists?(@fs_test_file_a)
    refute File.exists?(@fs_test_file_b)

    assert {:ok, _} = FS.move(@fs_test_file_a, @fs_test_file_b)
    assert File.exists?(@fs_test_file_b)
  end

  test "move/2 returns error when file does not exist" do
    source = Path.join(@test_dir, "a/non_existent.txt")
    dest = Path.join(@test_dir, "b/non_existent.txt")

    assert {:error, _} = FS.move(source, dest)
  end

  test "maybe_move/3 moves file when destination does not exist" do
    assert {:ok, _} = FS.maybe_move(@fs_test_file_a, @fs_test_file_b, true)
    assert File.exists?(@fs_test_file_b)
  end

  test "maybe_move/3 does not move file when destination exists" do
    File.write!(@fs_test_file_b, "existing content")

    assert {:ok, _} = FS.maybe_move(@fs_test_file_a, @fs_test_file_b, false)
    assert File.exists?(@fs_test_file_b)
    assert File.read!(@fs_test_file_b) == "existing content"
  end

  test "maybe_rm_rf/2 removes file when condition is true" do
    path = Path.join(@test_dir, "a/to_remove.txt")
    File.write!(path, "")

    assert File.exists?(path)
    assert {:ok, _} = FS.maybe_rm_rf(path, true)
    refute File.exists?(path)
  end

  test "maybe_rm_rf/2 does not remove file when condition is false" do
    path = Path.join(@test_dir, "a/not_to_remove.txt")
    File.write!(path, "")

    assert File.exists?(path)
    assert {:ok, _} = FS.maybe_rm_rf(path, false)
    assert File.exists?(path)
  end

  test "rm?/1 returns false when file does not exist" do
    path = Path.join(@test_dir, "a/non_existent.txt")
    refute FS.rm?(path)
  end

  test "rm?/1 returns true when file exists" do
    assert FS.rm?(@fs_test_file_a)
  end

  test "rm?/1 returns false for special paths" do
    refute FS.rm?(".")
    refute FS.rm?("~")
    refute FS.rm?("..")
  end
end
