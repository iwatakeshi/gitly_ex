defmodule GitlyParserTest do
  use ExUnit.Case
  doctest Gitly.Parser

  test "parses a shorthand URL" do
    assert Gitly.Parser.parse("iwatakeshi/gitly") ==
             {:ok,
              %{
                host: "github.com",
                owner: "iwatakeshi",
                repo: "gitly",
                ref: "main"
              }}

    # Gitlab sub groups and projects
    assert Gitly.Parser.parse("gitlab.com/group/subgroup/project") ==
             {:ok,
              %{
                host: "gitlab.com",
                owner: "group/subgroup",
                repo: "project",
                ref: "main"
              }}
  end

  test "parses an absolute URL" do
    assert Gitly.Parser.parse("https://github.com/iwatakeshi/gitly") ==
             {:ok,
              %{
                host: "github.com",
                owner: "iwatakeshi",
                repo: "gitly",
                ref: "main"
              }}

    # Gitlab sub groups and projects
    assert Gitly.Parser.parse("https://gitlab.com/group/subgroup/project") ==
             {:ok,
              %{
                host: "gitlab.com",
                owner: "group/subgroup",
                repo: "project",
                ref: "main"
              }}
  end

  test "parses a protocolless URL" do
    assert Gitly.Parser.parse("github.com/iwatakeshi/gitly") ==
             {:ok,
              %{
                host: "github.com",
                owner: "iwatakeshi",
                repo: "gitly",
                ref: "main"
              }}

    # Gitlab sub groups and projects
    assert Gitly.Parser.parse("gitlab.com/group/subgroup/project") ==
             {:ok,
              %{
                host: "gitlab.com",
                owner: "group/subgroup",
                repo: "project",
                ref: "main"
              }}
  end

  test "parses a shorthand URL with options" do
    assert Gitly.Parser.parse("iwatakeshi/gitly", %{host: "github.com", ref: "main"}) ==
             {:ok,
              %{
                host: "github.com",
                owner: "iwatakeshi",
                repo: "gitly",
                ref: "main"
              }}

    # Gitlab sub groups and projects
    assert Gitly.Parser.parse("gitlab.com/group/subgroup/project", %{
             host: "gitlab.com",
             ref: "main"
           }) ==
             {:ok,
              %{
                host: "gitlab.com",
                owner: "group/subgroup",
                repo: "project",
                ref: "main"
              }}
  end
end
