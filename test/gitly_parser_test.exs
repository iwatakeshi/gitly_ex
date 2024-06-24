defmodule GitlyParserTest do
  use ExUnit.Case
  doctest Gitly.Parser

  test "is_absolute_url? returns true if the URL is absolute" do
    assert Gitly.Parser.is_absolute_url?("https://github.com") == true
    assert Gitly.Parser.is_absolute_url?("http://github") == false
  end

  test "is_protocolless_url? returns true if the URL is protocolless" do
    assert Gitly.Parser.is_protocolless_url?("github.com") == true
    assert Gitly.Parser.is_protocolless_url?("http://github.com") == false
  end

  test "is_shorthand_url? returns true if the URL is shorthand" do
    assert Gitly.Parser.is_shorthand_url?("iwatakeshi/gitly") == true
    assert Gitly.Parser.is_shorthand_url?("github.com/iwatakeshi/gitly") == false
  end

  test "is_valid_absolute_url? returns true if the URL is valid" do
    assert Gitly.Parser.is_valid_absolute_url?("https://github.com/iwatakeshi/gitly") == true
    assert Gitly.Parser.is_valid_absolute_url?("https://github.com") == false
  end

  test "is_valid_protocolless_url? returns true if the URL is valid" do
    assert Gitly.Parser.is_valid_protocolless_url?("github.com/iwatakeshi/gitly") == true
    assert Gitly.Parser.is_valid_protocolless_url?("github.com") == false
  end

  test "is_valid_shorthand_url? returns true if the URL is valid" do
    assert Gitly.Parser.is_valid_shorthand_url?("iwatakeshi/gitly") == true
    assert Gitly.Parser.is_valid_shorthand_url?("github.com/iwatakeshi/gitly") == false
  end

  test "parses a shorthand URL" do
    assert Gitly.Parser.parse("iwatakeshi/gitly") == {:ok, %{
      host: "github.com",
      owner: "iwatakeshi",
      repo: "gitly",
      ref: "main"
    }}
  end

  test "parses an absolute URL" do
    assert Gitly.Parser.parse("https://github.com/iwatakeshi/gitly") == {:ok, %{
      host: "github.com",
      owner: "iwatakeshi",
      repo: "gitly",
      ref: "main"
    }}
  end

  test "parses a protocolless URL" do
    assert Gitly.Parser.parse("github.com/iwatakeshi/gitly") == {:ok, %{
      host: "github.com",
      owner: "iwatakeshi",
      repo: "gitly",
      ref: "main"
    }}
  end

  test "parses a shorthand URL with options" do
    assert Gitly.Parser.parse("iwatakeshi/gitly", %{host: "github.com", ref: "main"}) == {:ok, %{
      host: "github.com",
      owner: "iwatakeshi",
      repo: "gitly",
      ref: "main"
    }}
  end
end
