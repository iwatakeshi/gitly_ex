defmodule Gitly.Parser do
  @moduledoc """
    A module to parses a binary string and returns a metadata map.
  """

  @doc """
    Parses a binary string and returns a metadata map.

    The following strings are valid:
    * owner/repo
    * https://host.com/owner/repo
    * https://host.com/owner/repo.git
    * host.com/owner/repo
    * host:owner/repo

    `parse/1` returns a map with the following keys:
    * `:host` - the host of the repository
    * `:owner` - the owner of the repository
    * `:repo` - the repository name

    `parse/2` will take a binary string and a map of options. The options are:
    * `:host` - the host of the repository
    * `:ref` - the ref of the repository

    By default, the host is `github.com` and the ref is `main`.

    ## Examples

        iex> Gitly.Parser.parse("iwatakeshi/gitly")
        {:ok,  %{host: "github.com", owner: "iwatakeshi", repo: "gitly", ref: "main" }}

        iex> Gitly.Parser.parse("https://github.com/iwatakeshi/gitly")
        {:ok,  %{host: "github.com", owner: "iwatakeshi", repo: "gitly", ref: "main" }}

        iex> Gitly.Parser.parse("github.com/iwatakeshi/gitly")
        {:ok,  %{host: "github.com", owner: "iwatakeshi", repo: "gitly", ref: "main" }}

        iex> Gitly.Parser.parse("iwatakeshi/gitly", %{host: "github.com", ref: "main"})
        {:ok,  %{host: "github.com", owner: "iwatakeshi", repo: "gitly", ref: "main" }}

        iex> Gitly.Parser.parse("iwatakeshi/gitly", %{host: "github.com", ref: "main"})
        {:ok,  %{host: "github.com", owner: "iwatakeshi", repo: "gitly", ref: "main" }}

        iex> Gitly.Parser.parse("blah")
        {:error, %{}, "Invalid URL"}
  """
  @spec parse(binary) :: {:ok, map} | {:error, map, String.t()}
  def parse(str) when is_binary(str) do
    parse(str, %{})
  end

  @spec parse(binary, map) :: {:ok, map} | {:error, map, String.t()}
  def parse(str, opts)
      when is_binary(str) and is_map(opts) do
    cond do
      is_valid_absolute_url?(str) -> {:ok, parse_absolute_url(str, opts)}
      is_valid_protocolless_url?(str) -> {:ok, parse_absolute_url("https://#{str}", opts)}
      is_valid_shorthand_url?(str) -> {:ok, parse_shorthand_url(str, opts)}
      true -> {:error, %{}, "Invalid URL"}
    end
  end

  defp parse_absolute_url(str, opts) do
    str
    |> remove_http()
    |> remove_git_extension()
    |> String.split("/")
    |> case do
      [host, owner, repo] ->
        Map.put(opts, :host, host)
        |> Map.put(:owner, owner)
        |> Map.put(:repo, repo)
        |> Map.put(:ref, opts[:ref] || "main")

      _ ->
        {:error, "Invalid URL"}
    end
  end

  defp parse_shorthand_url(str, opts) do
    [owner, repo] = String.split(str, "/")

    Map.put(opts, :host, "github.com")
    |> Map.put(:owner, owner)
    |> Map.put(:repo, repo)
    |> Map.put(:ref, opts[:ref] || "main")
  end

  @doc """
    Checks if the input is a valid absolute URL.

    Note that this is different from `is_absolute_url?/1` because it checks if the URL is valid.
  """
  @spec is_valid_absolute_url?(binary()) :: boolean()
  def is_valid_absolute_url?(str) do
    parts =
      str
      |> remove_http()
      |> String.split("/")

    cond do
      length(parts) == 3 and
        is_absolute_url?(str) and not has_ref_in_url?(str) ->
        true

      # doesn't match any of the conditions
      true ->
        false
    end
  end

  @doc """
    Checks if the input is a valid shorthand URL.

    Note that this is different from `is_shorthand_url?/1` because it checks if the URL is valid.
  """
  @spec is_valid_shorthand_url?(binary()) :: boolean()
  def is_valid_shorthand_url?(str) do
    length(String.split(str, "/")) == 2 and
      is_shorthand_url?(str)
  end

  @doc """
    Checks if the input is a valid protocolless URL.

    Note that this is different from `is_protocolless_url?/1` because it checks if the URL is valid.
  """
  @spec is_valid_protocolless_url?(binary()) :: boolean()
  def is_valid_protocolless_url?(str) do
    length(String.split(str, "/")) == 3 and
      is_protocolless_url?(str)
  end

  @doc """
    Checks if the input is an absolute URL.
  """
  @spec is_absolute_url?(binary()) :: boolean()
  def is_absolute_url?(str) do
    Regex.match?(~r/^https?:\/\/.+?\..+/, str) and
      not has_ref_in_url?(str)
  end

  @doc """
    Checks if the input is a shorthand URL.
  """
  @spec is_shorthand_url?(binary()) :: boolean()
  def is_shorthand_url?(str) do
    Regex.match?(~r/^[^\/]+\/[^\/]+$/, str) and
      not has_ref_in_url?(str)
  end

  @doc """
    Checks if the input is a protocolless URL.
  """
  @spec is_protocolless_url?(binary()) :: boolean()
  def is_protocolless_url?(str) do
    not is_shorthand_url?(str) and
      not has_protocol?(str) and
      not has_ref_in_url?(str)
  end

  defp has_ref_in_url?(str) do
    Regex.match?(~r/#.+$/, str)
  end

  defp has_protocol?(str) do
    Regex.match?(~r/^https?:\/\//, str)
  end

  defp remove_http(str) do
    Regex.replace(~r/^https?:\/\//, str, "")
  end

  defp remove_git_extension(str) do
    Regex.replace(~r/\.git$/, str, "")
  end
end
