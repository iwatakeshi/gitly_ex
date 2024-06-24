defmodule Gitly.Archive.Utils do

  def create_archive_url(%{host: host } = input, format \\ "tar.gz") do
    case host do
      ~r/github(\.com)?/ -> {:ok, create_github_url(input, format)}
      ~r/gitlab(\.com)?/ -> {:ok, create_gitlab_url(input, format)}
      ~r/bitbucket(\.org)?/ -> {:ok, create_bitbucket_url(input, format)}
      _ -> {:error, "Invalid host"}
    end
  end


  defp create_github_url(%{owner: owner, repo: repo, ref: ref}, format) do
    "https://github.com/#{owner}/#{repo}/archive/refs/heads/#{ref}" <> format
  end

  defp create_gitlab_url(%{owner: owner, repo: repo, ref: ref}, format) do
    "https://gitlab.com/#{owner}/#{repo}/-/archive/#{ref}/#{repo}-#{ref}" <> format
  end

  defp create_bitbucket_url(%{owner: owner, repo: repo, ref: ref}, format) do
    "https://bitbucket.org/#{owner}/#{repo}/get/#{ref}.#{format}"
  end
end
