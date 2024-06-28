defmodule Gitly.Utils.Git.Provider do
  alias Gitly.Utils.Archive.Type, as: ArchiveType

  @moduledoc """
  A module to handle Git provider operations.

  This module provides functionality to identify Git providers and build
  archive URLs for different Git hosting services.
  """

  @type host() :: :github | :gitlab | :bitbucket | :unknown

  @doc """
  Returns the host type based on the given string.

  ## Parameters

    * `string` - A string containing the host name or URL.

  ## Returns

    * The host type as an atom (`:github`, `:gitlab`, `:bitbucket`, or `:unknown`).

  ## Examples

      iex> Gitly.Utils.Git.Provider.from_string("github.com")
      :github

      iex> Gitly.Utils.Git.Provider.from_string("gitlab")
      :gitlab

      iex> Gitly.Utils.Git.Provider.from_string("example.com")
      :unknown
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

  ## Parameters

    * `provider` - The host type (`:github`, `:gitlab`, `:bitbucket`, or `:unknown`).
    * `input` - A map containing repository information. It must include:
      * `:owner` - The repository owner or organization name.
      * `:repo` - The repository name.
      * `:ref` - The reference (branch, tag, or commit).
    * `format` - The desired archive format (e.g., "zip", "tar.gz").

  ## Returns

    * A string containing the constructed URL for the archive.
    * `:error` if the provider is unknown.

  ## Examples

      iex> input = %{owner: "elixir-lang", repo: "elixir", ref: "main"}
      iex> Gitly.Utils.Git.Provider.build_url(:github, input, "zip")
      "https://github.com/elixir-lang/elixir/archive/main.zip"

      iex> input = %{owner: "gitlab-org", repo: "gitlab", ref: "master"}
      iex> Gitly.Utils.Git.Provider.build_url(:gitlab, input, "tar.gz")
      "https://gitlab.com/gitlab-org/gitlab/-/archive/master/gitlab-master.tar.gz"

      iex> input = %{owner: "atlassian", repo: "bitbucket", ref: "main"}
      iex> Gitly.Utils.Git.Provider.build_url(:bitbucket, input, "tar.gz")
      "https://bitbucket.org/atlassian/bitbucket/get/main.tar.gz"

      iex> Gitly.Utils.Git.Provider.build_url(:unknown, %{}, "zip")
      :error
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
