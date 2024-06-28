defmodule GitlyUtilsArchiveTypeTest do
  use ExUnit.Case

  test "valid?" do
    assert Gitly.Utils.Archive.Type.valid?("file.zip") == true
    assert Gitly.Utils.Archive.Type.valid?("file.tar") == true
    assert Gitly.Utils.Archive.Type.valid?("file.tar.gz") == true
    assert Gitly.Utils.Archive.Type.valid?("file.tgz") == true
    assert Gitly.Utils.Archive.Type.valid?("file.tar.bz2") == true
    assert Gitly.Utils.Archive.Type.valid?("file.tar.xz") == true
    assert Gitly.Utils.Archive.Type.valid?("file") == false

    assert Gitly.Utils.Archive.Type.valid?(".zip") == true
  end

  test "from_path" do
    assert Gitly.Utils.Archive.Type.from_path("file.zip") == :zip
    assert Gitly.Utils.Archive.Type.from_path("file.tar") == :tar
    assert Gitly.Utils.Archive.Type.from_path("file.tar.gz") == :tar_gz
    assert Gitly.Utils.Archive.Type.from_path("file.tgz") == :tgz
    assert Gitly.Utils.Archive.Type.from_path("file.tar.bz2") == :tar_bz2
    assert Gitly.Utils.Archive.Type.from_path("file.tar.xz") == :tar_xz
    assert Gitly.Utils.Archive.Type.from_path("file") == :unknown
  end

  test "from_string/1" do
    assert Gitly.Utils.Archive.Type.from_string(".zip") == :zip
    assert Gitly.Utils.Archive.Type.from_string(".tar") == :tar
    assert Gitly.Utils.Archive.Type.from_string(".tar.gz") == :tar_gz
    assert Gitly.Utils.Archive.Type.from_string(".tgz") == :tgz
    assert Gitly.Utils.Archive.Type.from_string(".tar.bz2") == :tar_bz2
    assert Gitly.Utils.Archive.Type.from_string(".tar.xz") == :tar_xz
    assert Gitly.Utils.Archive.Type.from_string(".unknown") == :unknown
    assert Gitly.Utils.Archive.Type.from_string("unknown") == :unknown
  end

  test "from_string/2 with dot disabled" do
    assert Gitly.Utils.Archive.Type.from_string("zip", false) == :zip
    assert Gitly.Utils.Archive.Type.from_string("tar", false) == :tar
    assert Gitly.Utils.Archive.Type.from_string("tar.gz", false) == :tar_gz
    assert Gitly.Utils.Archive.Type.from_string("tgz", false) == :tgz
    assert Gitly.Utils.Archive.Type.from_string("tar.bz2", false) == :tar_bz2
    assert Gitly.Utils.Archive.Type.from_string("tar.xz", false) == :tar_xz
    assert Gitly.Utils.Archive.Type.from_string("unknown", false) == :unknown
  end

  test "from_type/1" do
    assert Gitly.Utils.Archive.Type.from_type(:zip) == ".zip"
    assert Gitly.Utils.Archive.Type.from_type(:tar) == ".tar"
    assert Gitly.Utils.Archive.Type.from_type(:tar_gz) == ".tar.gz"
    assert Gitly.Utils.Archive.Type.from_type(:tgz) == ".tgz"
    assert Gitly.Utils.Archive.Type.from_type(:tar_bz2) == ".tar.bz2"
    assert Gitly.Utils.Archive.Type.from_type(:tar_xz) == ".tar.xz"
    assert Gitly.Utils.Archive.Type.from_type(:unknown) == :unknown
    assert Gitly.Utils.Archive.Type.from_type(:test) == :unknown
  end

  test "from_type/2 with dot disabled" do
    assert Gitly.Utils.Archive.Type.from_type(:zip, false) == "zip"
    assert Gitly.Utils.Archive.Type.from_type(:tar, false) == "tar"
    assert Gitly.Utils.Archive.Type.from_type(:tar_gz, false) == "tar.gz"
    assert Gitly.Utils.Archive.Type.from_type(:tgz, false) == "tgz"
    assert Gitly.Utils.Archive.Type.from_type(:tar_bz2, false) == "tar.bz2"
    assert Gitly.Utils.Archive.Type.from_type(:tar_xz, false) == "tar.xz"
    assert Gitly.Utils.Archive.Type.from_type(:unknown, false) == :unknown
  end

  test "ensure_leading_dot" do
    assert Gitly.Utils.Archive.Type.ensure_leading_dot(".zip") == ".zip"
    assert Gitly.Utils.Archive.Type.ensure_leading_dot("zip") == ".zip"
  end

  test "trim_leading_dot" do
    assert Gitly.Utils.Archive.Type.trim_leading_dot(".zip") == "zip"
    assert Gitly.Utils.Archive.Type.trim_leading_dot("zip") == "zip"
  end

  test "trim_extension" do
    assert Gitly.Utils.Archive.Type.trim_extension("file.zip") == "file"
    assert Gitly.Utils.Archive.Type.trim_extension("file.tar") == "file"
    assert Gitly.Utils.Archive.Type.trim_extension("file.tar.gz") == "file"
    assert Gitly.Utils.Archive.Type.trim_extension("file.tgz") == "file"
    assert Gitly.Utils.Archive.Type.trim_extension("file.tar.bz2") == "file"
    assert Gitly.Utils.Archive.Type.trim_extension("file.tar.xz") == "file"
    assert Gitly.Utils.Archive.Type.trim_extension("file") == "file"
  end
end
