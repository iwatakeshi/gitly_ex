defmodule GitlyUtilsGit do
  use ExUnit.Case
  alias Gitly.Utils.Git

  test "create_repo_url/1" do
    assert Git.create_repo_url(%{host: "github.com", owner: "owner", repo: "repo"}) ==
             "https://github.com/owner/repo"
  end

  test "create_repo_url/2" do
    assert Git.create_repo_url(%{host: "github.com", owner: "owner", repo: "repo"}, true) ==
             "https://github.com/owner/repo.git"
  end
end
