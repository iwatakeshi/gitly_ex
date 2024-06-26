defmodule Gitly.Utils.Git do

  @moduledoc """
  A module to create a repository URL.
  """

  @doc """
  Create a repository URL.
  """
  @spec create_repo_url(map(), boolean()) :: String.t()
  def create_repo_url(%{ host: host, owner: owner, repo: repo, }, suffix \\ false) do
    if suffix do
      "https://#{host}/#{owner}/#{repo}.git"
    else
      "https://#{host}/#{owner}/#{repo}"
    end
  end

end
