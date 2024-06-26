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
        {:error, "Invalid URL"}
  """
  @spec parse(binary) :: {:ok, map} | {:error,  String.t()}
  def parse(str) when is_binary(str) do
    parse(str, %{})
  end

  @spec parse(binary, map) :: {:ok, map} | {:error, String.t()}
  def parse(str, opts)
      when is_binary(str) and is_map(opts) do
    cond do
      # If the URL is an absolute URL
      Regex.match?(~r/^https?:\/\//, str) ->
        parse_absolute_url(str, opts)

      # If the URL is an URL without a protocol
      Regex.match?(~r/^[^\/]+\.[^\/]+\/.+/, str) ->
        parse_absolute_url(str, opts)

      # If the URL is a shorthand URL
      true ->
        parse_shorthand_url(str, opts)
    end
  end

  defp parse_absolute_url(str, opts) do
    str
    |> remove_http()
    |> remove_git_extension()
    |> split()
    |> case do
      [host | rest] when length(rest) >= 2 ->
        repo = List.last(rest)
        owner_group_path = rest |> Enum.drop(-1) |> Enum.join("/")

        result =
          Map.put(opts, :host, host)
          |> Map.put(:owner, owner_group_path)
          |> Map.put(:repo, repo)
          |> Map.put(:ref, opts[:ref] || "main")

        {:ok, result}

      _ ->
        {:error, "Invalid URL"}
    end
  end

  defp parse_shorthand_url(str, opts) do
    parts = String.split(str, "/")

    case parts do
      [owner | rest] when length(rest) >= 1 ->
        repo = Enum.join(rest, "/")

        result =
          Map.put(opts, :host, "github.com")
          |> Map.put(:owner, opts[:owner] || owner)
          |> Map.put(:repo, repo)
          |> Map.put(:ref, opts[:ref] || "main")

        {:ok, result}

      _ ->
        {:error, "Invalid URL"}
    end
  end

  defp remove_http(str) do
    Regex.replace(~r/^https?:\/\//, str, "")
  end

  defp remove_git_extension(str) do
    Regex.replace(~r/\.git$/, str, "")
  end

  defp split(str), do: String.split(str, "/")
end
