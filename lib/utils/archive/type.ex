defmodule Gitly.Utils.Archive.Type do

  @moduledoc """
  A module to handle archive types.
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

  @spec valid?(Path.t()) :: boolean()
  def valid?(path),
    do: Enum.any?(@archive_extension_types, fn {ext, _} -> String.ends_with?(path, ext) end)

  @spec from_path(Path.t()) :: ext() | :unknown
  def from_path(path) do
    Enum.find_value(@archive_extension_types, :unknown, fn {ext, type} ->
      if String.ends_with?(path, ext), do: type
    end)
  end

  @spec from_string(binary(), boolean()) :: ext() | :unknown
  def from_string(string, dot \\ true),
    do:
      if(dot,
        do: Map.get(@archive_extension_types, string, :unknown),
        else: Map.get(@dotless_archive_extension_types, string, :unknown)
      )

  @spec from_type(ext(), boolean()) :: binary() | :unknown
  def from_type(type, dot \\ true)
  def from_type(:unknown, _dot), do: :unknown

  def from_type(type, dot) when is_atom(type) do
    case Enum.find(@archive_extension_types, fn {_ext, t} -> t == type end) do
      {ext, _} -> if dot, do: ext, else: String.trim_leading(ext, ".")
      nil -> :unknown
    end
  end

  def ensure_leading_dot(ext),
    do: if(String.starts_with?(ext, "."), do: ext, else: ".#{ext}")

  def trim_leading_dot(ext),
    do: if(String.starts_with?(ext, "."), do: String.trim_leading(ext, "."), else: ext)

  def trim_extension(path) do
    regex = ~r/\.(zip|tar|tar\.gz|tgz|tar\.bz2|tar\.xz)$/
    cond do
      Regex.match?(regex, path) -> Regex.replace(regex, path, "")
      true -> path
    end
  end
end
