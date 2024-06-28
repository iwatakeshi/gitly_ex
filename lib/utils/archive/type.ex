defmodule Gitly.Utils.Archive.Type do
  @moduledoc """
  A module to handle archive types.

  This module provides functions to work with various archive formats,
  including zip, tar, tar.gz, tgz, tar.bz2, and tar.xz.
  """

  @archive_extension_types %{
    ".zip" => :zip,
    ".tar" => :tar,
    ".tar.gz" => :tar_gz,
    ".tgz" => :tgz,
    ".tar.bz2" => :tar_bz2,
    ".tar.xz" => :tar_xz
  }

  @dotless_archive_extension_types %{
    "zip" => :zip,
    "tar" => :tar,
    "tar.gz" => :tar_gz,
    "tgz" => :tgz,
    "tar.bz2" => :tar_bz2,
    "tar.xz" => :tar_xz
  }

  @type ext :: :zip | :tar | :tar_gz | :tgz | :tar_bz2 | :tar_xz

  @doc """
  Checks if the given path is a valid archive.

  ## Parameters

    * `path` - The file path to check.

  ## Returns

    * `true` if the path ends with a valid archive extension, `false` otherwise.

  ## Examples

      iex> Gitly.Utils.Archive.Type.valid?("example.zip")
      true

      iex> Gitly.Utils.Archive.Type.valid?("example.txt")
      false
  """
  @spec valid?(Path.t()) :: boolean()
  def valid?(path),
    do: Enum.any?(@archive_extension_types, fn {ext, _} -> String.ends_with?(path, ext) end)

  @doc """
  Returns the archive type as an atom from the given path.

  ## Parameters

    * `path` - The file path to check.

  ## Returns

    * The archive type as an atom (`:zip`, `:tar`, etc.) or `:unknown` if not recognized.

  ## Examples

      iex> Gitly.Utils.Archive.Type.from_path("example.tar.gz")
      :tar_gz

      iex> Gitly.Utils.Archive.Type.from_path("example.txt")
      :unknown
  """
  @spec from_path(Path.t()) :: ext() | :unknown
  def from_path(path) do
    Enum.find_value(@archive_extension_types, :unknown, fn {ext, type} ->
      if String.ends_with?(path, ext), do: type
    end)
  end

  @doc """
  Returns the archive type as an atom from the given string.

  ## Parameters

    * `string` - The string representing the archive extension.
    * `dot` - Whether the string includes a leading dot (default: true).

  ## Returns

    * The archive type as an atom (`:zip`, `:tar`, etc.) or `:unknown` if not recognized.

  ## Examples

      iex> Gitly.Utils.Archive.Type.from_string(".zip")
      :zip

      iex> Gitly.Utils.Archive.Type.from_string("tar.gz", false)
      :tar_gz

      iex> Gitly.Utils.Archive.Type.from_string("rar")
      :unknown
  """
  @spec from_string(binary(), boolean()) :: ext() | :unknown
  def from_string(string, dot \\ true),
    do:
      if(dot,
        do: Map.get(@archive_extension_types, string, :unknown),
        else: Map.get(@dotless_archive_extension_types, string, :unknown)
      )

  @doc """
  Returns the archive type as a string from the given type.

  ## Parameters

    * `type` - The archive type as an atom.
    * `dot` - Whether to include a leading dot in the result (default: true).

  ## Returns

    * The archive extension as a string or `:unknown` if not recognized.

  ## Examples

      iex> Gitly.Utils.Archive.Type.from_type(:zip)
      ".zip"

      iex> Gitly.Utils.Archive.Type.from_type(:tar_gz, false)
      "tar.gz"

      iex> Gitly.Utils.Archive.Type.from_type(:unknown)
      :unknown
  """
  @spec from_type(ext(), boolean()) :: binary() | :unknown
  def from_type(type, dot \\ true)
  def from_type(:unknown, _dot), do: :unknown

  def from_type(type, dot) when is_atom(type) do
    case Enum.find(@archive_extension_types, fn {_ext, t} -> t == type end) do
      {ext, _} -> if dot, do: ext, else: String.trim_leading(ext, ".")
      nil -> :unknown
    end
  end

  @doc """
  Ensures the given extension has a leading dot.

  ## Parameters

    * `ext` - The extension string.

  ## Returns

    * The extension string with a leading dot.

  ## Examples

      iex> Gitly.Utils.Archive.Type.ensure_leading_dot("zip")
      ".zip"

      iex> Gitly.Utils.Archive.Type.ensure_leading_dot(".tar.gz")
      ".tar.gz"
  """
  @spec ensure_leading_dot(binary()) :: binary()
  def ensure_leading_dot(ext),
    do: if(String.starts_with?(ext, "."), do: ext, else: ".#{ext}")

  @doc """
  Removes the leading dot from the given extension.

  ## Parameters

    * `ext` - The extension string.

  ## Returns

    * The extension string without a leading dot.

  ## Examples

      iex> Gitly.Utils.Archive.Type.trim_leading_dot(".zip")
      "zip"

      iex> Gitly.Utils.Archive.Type.trim_leading_dot("tar.gz")
      "tar.gz"
  """
  @spec trim_leading_dot(binary()) :: binary()
  def trim_leading_dot(ext),
    do: if(String.starts_with?(ext, "."), do: String.trim_leading(ext, "."), else: ext)

  @doc """
  Removes the archive extension from the given path.

  ## Parameters

    * `path` - The file path.

  ## Returns

    * The path without the archive extension.

  ## Examples

      iex> Gitly.Utils.Archive.Type.trim_extension("example.tar.gz")
      "example"

      iex> Gitly.Utils.Archive.Type.trim_extension("example.txt")
      "example.txt"
  """
  @spec trim_extension(Path.t()) :: Path.t()
  def trim_extension(path) do
    regex = ~r/\.(zip|tar|tar\.gz|tgz|tar\.bz2|tar\.xz)$/
    if Regex.match?(regex, path), do: Regex.replace(regex, path, ""), else: path
  end
end
