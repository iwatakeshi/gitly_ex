defmodule Gitly.Parser do
  @moduledoc """
  A module to parse repository URLs and return metadata.

  This module can handle various formats of repository URLs and convert them
  into a standardized metadata map.
  """

  @doc """
  Parses a binary string and returns a metadata map.

  The following strings are valid:
  * owner/repo
  * https://host.com/owner/repo
  * https://host.com/owner/repo.git
  * host.com/owner/repo
  * host:owner/repo

  ## Parameters

  * `str` - A binary string representing the repository URL.

  ## Returns

  * `{:ok, map}` where the map contains:
    * `:host` - the host of the repository
    * `:owner` - the owner of the repository
    * `:repo` - the repository name
    * `:ref` - the reference (default is "main")
  * `{:error, reason}` if the parsing fails.

  ## Examples

      iex> Gitly.Parser.parse("iwatakeshi/gitly")
      {:ok, %{host: "github.com", owner: "iwatakeshi", repo: "gitly", ref: "main"}}

      iex> Gitly.Parser.parse("https://github.com/iwatakeshi/gitly")
      {:ok, %{host: "github.com", owner: "iwatakeshi", repo: "gitly", ref: "main"}}

      iex> Gitly.Parser.parse("github.com/iwatakeshi/gitly")
      {:ok, %{host: "github.com", owner: "iwatakeshi", repo: "gitly", ref: "main"}}

      iex> Gitly.Parser.parse("github:iwatakeshi/gitly")
      {:ok, %{host: "github.com", owner: "iwatakeshi", repo: "gitly", ref: "main"}}

      iex> Gitly.Parser.parse("blah")
      {:error, "Invalid URL"}
  """
  @spec parse(binary) :: {:ok, map} | {:error, String.t()}
  def parse(str) when is_binary(str) do
    parse(str, %{})
  end

  @doc """
  Parses a binary string with additional options and returns a metadata map.

  This function is similar to `parse/1` but allows specifying additional options.

  ## Parameters

  * `str` - A binary string representing the repository URL.
  * `opts` - A map of options:
    * `:host` - the host of the repository (default is "github.com")
    * `:ref` - the ref of the repository (default is "main")

  ## Returns

  * `{:ok, map}` where the map contains the parsed metadata.
  * `{:error, reason}` if the parsing fails.

  ## Examples

      iex> Gitly.Parser.parse("iwatakeshi/gitly", %{host: "gitlab.com", ref: "develop"})
      {:ok, %{host: "gitlab.com", owner: "iwatakeshi", repo: "gitly", ref: "develop"}}
  """
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

      # If the URL is in the format host:owner/repo
      Regex.match?(~r/^[^:]+:.+\/.+/, str) ->
        parse_host_colon_url(str, opts)

      # If the URL is a shorthand URL
      true ->
        parse_shorthand_url(str, opts)
    end
  end

  @doc false
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

  @doc false
  defp parse_host_colon_url(str, opts) do
    case String.split(str, ":") do
      [host, owner_repo] ->
        case String.split(owner_repo, "/") do
          [owner, repo] ->
            result =
              Map.put(opts, :host, host <> ".com")
              |> Map.put(:owner, owner)
              |> Map.put(:repo, repo)
              |> Map.put(:ref, opts[:ref] || "main")

            {:ok, result}

          _ ->
            {:error, "Invalid URL"}
        end

      _ ->
        {:error, "Invalid URL"}
    end
  end

  @doc false
  defp parse_shorthand_url(str, opts) do
    parts = String.split(str, "/")

    case parts do
      [owner | rest] when length(rest) >= 1 ->
        repo = Enum.join(rest, "/")

        result =
          Map.put(opts, :host, opts[:host] || "github.com")
          |> Map.put(:owner, owner)
          |> Map.put(:repo, repo)
          |> Map.put(:ref, opts[:ref] || "main")

        {:ok, result}

      _ ->
        {:error, "Invalid URL"}
    end
  end

  @doc false
  defp remove_http(str) do
    Regex.replace(~r/^https?:\/\//, str, "")
  end

  @doc false
  defp remove_git_extension(str) do
    Regex.replace(~r/\.git$/, str, "")
  end

  @doc false
  defp split(str), do: String.split(str, "/")
end
