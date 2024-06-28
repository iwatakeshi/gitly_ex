defmodule GitlyUtilsGitProviderTest do
  use ExUnit.Case

  test "from_string" do
    assert Gitly.Utils.Git.Provider.from_string("github.com") == :github
    assert Gitly.Utils.Git.Provider.from_string("github") == :github
    assert Gitly.Utils.Git.Provider.from_string("gitlab.com") == :gitlab
    assert Gitly.Utils.Git.Provider.from_string("gitlab") == :gitlab
    assert Gitly.Utils.Git.Provider.from_string("bitbucket.org") == :bitbucket
    assert Gitly.Utils.Git.Provider.from_string("bitbucket") == :bitbucket
    assert Gitly.Utils.Git.Provider.from_string("unknown") == :unknown
  end

  test "build_url" do
    assert Gitly.Utils.Git.Provider.build_url(
             :github,
             %{owner: "owner", repo: "repo", ref: "ref"},
             ".tar.gz"
           ) ==
             "https://github.com/owner/repo/archive/ref.tar.gz"

    assert Gitly.Utils.Git.Provider.build_url(
             :gitlab,
             %{owner: "owner", repo: "repo", ref: "ref"},
             ".tar.gz"
           ) ==
             "https://gitlab.com/owner/repo/-/archive/ref/repo-ref.tar.gz"

    assert Gitly.Utils.Git.Provider.build_url(
             :bitbucket,
             %{owner: "owner", repo: "repo", ref: "ref"},
             ".tar.gz"
           ) ==
             "https://bitbucket.org/owner/repo/get/ref.tar.gz"

    assert Gitly.Utils.Git.Provider.build_url(:unknown, %{}, ".tar.gz") == :error
  end
end
