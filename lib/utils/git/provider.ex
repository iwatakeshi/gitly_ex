defmodule Gitly.Utils.Git.Provider do
  alias Gitly.Utils.Archive.Type, as: ArchiveType

  @moduledoc """
  A module to handle Git provider operations.
  """

  @type host() :: :github | :gitlab | :bitbucket | :unknown

  @doc """
  Returns the host type based on the given string.
  """
  @spec from_string(String.t()) :: host()
  def from_string(string) do
    cond do
      Regex.match?(~r/github(\.com)?/, string) -> :github
      Regex.match?(~r/gitlab(\.com)?/, string) -> :gitlab
      Regex.match?(~r/bitbucket(\.org)?/, string) -> :bitbucket
      true -> :unknown
    end
  end

  @doc """
  Builds the URL for the given provider.
  """
  @spec build_url(host(), map(), String.t()) :: String.t() | :error
  def build_url(:github, %{owner: owner, repo: repo, ref: ref}, format) do
    "https://github.com/#{owner}/#{repo}/archive/#{ref}#{ArchiveType.ensure_leading_dot(format)}"
  end

  def build_url(:gitlab, %{owner: owner, repo: repo, ref: ref}, format) do
    "https://gitlab.com/#{owner}/#{repo}/-/archive/#{ref}/#{repo}-#{ref}#{ArchiveType.ensure_leading_dot(format)}"
  end

  def build_url(:bitbucket, %{owner: owner, repo: repo, ref: ref}, format) do
    "https://bitbucket.org/#{owner}/#{repo}/get/#{ref}#{ArchiveType.ensure_leading_dot(format)}"
  end

  def build_url(:unknown, _input, _format), do: :error
end
