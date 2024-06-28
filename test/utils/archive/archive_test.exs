defmodule GitlyUtilsArchiveTest do
  use ExUnit.Case
  # import Mox

  @fixture_dir Path.join(__DIR__, "fixtures")
  @download_dir Path.join(@fixture_dir, "download")
  @extract_dir Path.join(@fixture_dir, "extract")

  @url "https://github.com/iwatakeshi/gitly/archive/master.tar.gz"

  setup do
    previous_net_module = Application.get_env(:gitly, :net_module)
    Application.put_env(:gitly, :net_module, Gitly.Utils.Net.INet)

    on_exit(fn ->
      Application.put_env(:gitly, :net_module, previous_net_module)
    end)
  end

  test "create_archive_path" do
    input = %{host: "github", owner: "owner", repo: "repo", ref: "ref"}
    home_dir = System.user_home!()

    assert Gitly.Utils.Archive.create_archive_path(input) ==
             Path.join(home_dir, ".gitly/github/owner/repo/ref.tar.gz")

    opts = [root: "/tmp", format: :tgz]

    assert Gitly.Utils.Archive.create_archive_path(input, opts) ==
             Path.join("/tmp", "github/owner/repo/ref.tgz")
  end

  test "build_archive_url" do
    input = %{host: "github", owner: "owner", repo: "repo", ref: "ref"}

    assert Gitly.Utils.Archive.build_archive_url(input) ==
             "https://github.com/owner/repo/archive/ref.tar.gz"
  end

  @tag :download
  test "download" do
    # Test successful download
    # dest = @download_dir
    working_file = Path.join([@download_dir, "master.tar.gz"])
    assert {:ok, _} = Gitly.Utils.Archive.download(@url, working_file)
    assert File.exists?(working_file)

    # Test failed download
    non_working_url = "https://github.com/iwatakeshi/gitly/archive/main.tar.gz"
    non_working_file = Path.join([@download_dir, "main.tar.gz"])

    assert {:error, reason} = Gitly.Utils.Archive.download(non_working_url, non_working_file)
    assert reason == "Failed to download archive: 404"
    assert not File.exists?(non_working_file)

    on_exit(fn ->
      File.rm_rf(working_file)
      File.rm_rf(non_working_file)
    end)
  end

  @tag :extract
  test "extract/2" do
    # Download the archive

    working_file = Path.join([@extract_dir, "master.tar.gz"])
    assert {:ok, _} = Gitly.Utils.Archive.download(@url, working_file)

    # Test successful extraction

    working_dest = Path.join([@extract_dir, "master"])
    working_extracted_path = Path.join(working_dest, "gitly-master")

    assert {:ok, _} = Gitly.Utils.Archive.extract(working_file, working_dest)
    assert File.exists?(working_extracted_path)
    assert File.dir?(working_extracted_path)
    assert File.exists?(Path.join(working_extracted_path, "README.md"))

    # Test failed extraction
    non_working_path = Path.join([@extract_dir, "main.tar.gz"])
    non_working_dest = Path.join([@extract_dir, "main"])

    assert {:error, _} = Gitly.Utils.Archive.extract(non_working_path, non_working_dest)
    assert not File.exists?(Path.join(non_working_dest, "gitly-main"))

    on_exit(fn ->
      File.rm_rf(working_dest)
      File.rm_rf(non_working_dest)
      File.rm_rf(working_extracted_path)
      File.rm_rf(working_file)
    end)
  end

  test "extract/3" do
    # Download the archive

    source = Path.join([@extract_dir, "master.tar.gz"])
    assert {:ok, _} = Gitly.Utils.Archive.download(@url, source)

    dest = Path.join([@extract_dir, "master"])
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

  test "extract/3 with overwrite" do
    # First download and extract a repo and the try to extract the same repo
    # with the overwrite option set to false

    # Download the archive
    source = Path.join([@extract_dir, "master.tar.gz"])
    assert {:ok, _} = Gitly.Utils.Archive.download(@url, source)

    dest = Path.join([@extract_dir, "master"])
    extracted_path = Path.join(dest, "gitly-master")

    # Extract it once
    assert {:ok, _} = Gitly.Utils.Archive.extract(source, dest)
    assert File.exists?(extracted_path)

    # Try to extract the same repo with the overwrite option set to false
    # It should return the existing extracted path
    assert {:ok, _} = Gitly.Utils.Archive.extract(source, dest, overwrite: false)

    assert {:ok, _} = Gitly.Utils.Archive.extract(source, dest, overwrite: true)

    on_exit(fn ->
      File.rm_rf(dest)
      File.rm_rf(extracted_path)
      File.rm_rf(source)
    end)
  end

  test "extract/3 (zip)" do
    # Download the archive
    zip_url = "https://github.com/iwatakeshi/gitly/archive/master.zip"
    source = Path.join([@extract_dir, "master.zip"])
    assert {:ok, _} = Gitly.Utils.Archive.download(zip_url, source)

    dest = Path.join([@extract_dir, "master"])
    extracted_path = Path.join(dest, "gitly-master")
    # Extract it once
    assert {:ok, _} = Gitly.Utils.Archive.extract(source, dest, format: :zip)

    assert {:ok, _} = Gitly.Utils.Archive.extract(source, dest, format: :zip, force: true)
    assert File.exists?(Path.join(dest, "gitly-master"))

    on_exit(fn ->
      File.rm_rf(dest)
      File.rm_rf(extracted_path)
      File.rm_rf(source)
    end)
  end

  test "extract/3 (tar)" do
    # Download the archive
    tar_url = "https://gitlab.com/gitlab-org/gitaly/-/archive/master/gitaly-master.tar"
    source = Path.join([@extract_dir, "master.tar"])
    assert {:ok, _} = Gitly.Utils.Archive.download(tar_url, source)

    dest = Path.join([@extract_dir, "main"])
    extracted_path = Path.join(dest, "gitaly-master")
    # Extract it once
    assert {:ok, _} = Gitly.Utils.Archive.extract(source, dest, format: :tar)

    assert {:ok, _} = Gitly.Utils.Archive.extract(source, dest, format: :tar, force: true)
    assert File.exists?(Path.join(dest, "gitaly-master"))

    on_exit(fn ->
      File.rm_rf(dest)
      File.rm_rf(extracted_path)
      File.rm_rf(source)
    end)
  end

  test "extract/3 (unknown)" do
    # No need to download
    assert {:error, _} = Gitly.Utils.Archive.extract("unknown", "unknown", format: :unknown)
  end
end
