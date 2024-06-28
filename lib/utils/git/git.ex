defmodule Gitly.Utils.Git do
  @moduledoc """
  A module to create repository URLs.

  This module provides functionality to generate repository URLs based on
  provided information such as host, owner, and repository name.
  """

  @doc """
  Creates a repository URL.

  ## Parameters

    * `repo_info` - A map containing repository information. It must include:
      * `:host` - The host domain (e.g., "github.com")
      * `:owner` - The repository owner or organization name
      * `:repo` - The repository name
    * `suffix` - A boolean indicating whether to append ".git" to the URL (default: false)

  ## Returns

    * A string containing the constructed repository URL.

  ## Examples

      iex> repo_info = %{host: "github.com", owner: "elixir-lang", repo: "elixir"}
      iex> Gitly.Utils.Git.create_repo_url(repo_info)
      "https://github.com/elixir-lang/elixir"

      iex> repo_info = %{host: "gitlab.com", owner: "gitlab-org", repo: "gitlab"}
      iex> Gitly.Utils.Git.create_repo_url(repo_info, true)
      "https://gitlab.com/gitlab-org/gitlab.git"
  """
  @spec create_repo_url(map(), boolean()) :: String.t()
  def create_repo_url(%{host: host, owner: owner, repo: repo}, suffix \\ false) do
    if suffix do
      "https://#{host}/#{owner}/#{repo}.git"
    else
      "https://#{host}/#{owner}/#{repo}"
    end
  end
end
