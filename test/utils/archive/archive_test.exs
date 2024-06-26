defmodule GitlyUtilsArchiveTest do
  use ExUnit.Case

  @current_directory __DIR__
  @url "https://github.com/iwatakeshi/gitly/archive/master.tar.gz"

  test "create_archive_path" do
    input = %{host: "github", owner: "owner", repo: "repo", ref: "ref"}
    home_dir = System.user_home!()

    assert Gitly.Utils.Archive.create_archive_path(input) ==
             Path.join(home_dir, ".gitly/github/owner/repo/ref.tar.gz")

    opts = [root: "/tmp", format: :tgz]

    assert Gitly.Utils.Archive.create_archive_path(input, opts) ==
             Path.join("/tmp", "github/owner/repo/ref.tgz")
  end

  test "download" do
    # Test successful download
    working_path = Path.join([@current_directory, "fixtures", "download", "master.tar.gz"])

    assert {:ok, _} = Gitly.Utils.Archive.download(@url, working_path)
    assert File.exists?(working_path)

    # Test failed download
    non_working_url = "https://github.com/iwatakeshi/gitly/archive/main.tar.gz"
    non_working_path = Path.join([@current_directory, "fixtures", "download", "main.tar.gz"])

    assert {:error, reason} = Gitly.Utils.Archive.download(non_working_url, non_working_path)
    assert reason == "Failed to download archive: 404"
    assert not File.exists?(non_working_path)

    on_exit(fn ->
      File.rm(working_path)
      File.rm(non_working_path)
    end)
  end

  test "extract/2" do
    # Download the archive

    path = Path.join([@current_directory, "fixtures", "extract", "master.tar.gz"])
    assert {:ok, _} = Gitly.Utils.Archive.download(@url, path)

    # Test successful extraction
    working_path = path
    working_dest = Path.join([@current_directory, "fixtures", "extract", "master"])
    working_extracted_path = Path.join(working_dest, "gitly-master")

    assert {:ok, _} = Gitly.Utils.Archive.extract(working_path, working_dest)
    assert File.exists?(working_extracted_path)
    assert File.dir?(working_extracted_path)
    assert File.exists?(Path.join(working_extracted_path, "README.md"))

    # Test failed extraction
    non_working_path = Path.join([@current_directory, "fixtures", "extract", "main.tar.gz"])
    non_working_dest = Path.join([@current_directory, "fixtures", "extract", "main"])

    assert {:error, _} = Gitly.Utils.Archive.extract(non_working_path, non_working_dest)
    assert not File.exists?(Path.join(non_working_dest, "gitly-main"))

    on_exit(fn ->
      File.rm_rf(working_dest)
      File.rm_rf(non_working_dest)
      File.rm_rf(working_extracted_path)
      File.rm_rf(path)
    end)
  end

  test "extract/3" do
    # Download the archive

    source = Path.join([@current_directory, "fixtures", "extract", "master.tar.gz"])
    assert {:ok, _} = Gitly.Utils.Archive.download(@url, source)

    dest = Path.join([@current_directory, "fixtures", "extract", "master"])
    extracted_path = Path.join(dest, "gitly-master")
    # Extract it once
    assert {:ok, _} = Gitly.Utils.Archive.extract(source, dest)


    assert {:ok, _} = Gitly.Utils.Archive.extract(source, dest, force: true)
    assert File.exists?(Path.join(dest, "gitly-master"))

    on_exit(fn ->
      File.rm_rf(dest)
      File.rm_rf(extracted_path)
      File.rm_rf(source)
    end)
  end
end
