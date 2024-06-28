defmodule Gitly.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/iwatakeshi/gitly_ex"

  def(project) do
    [
      name: "gitly",
      app: :gitly,
      version: @version,
      source_url: @source_url,
      description: description(),
      package: package(),
      elixir: "~> 1.17",
      elixirc_paths: elixirc_paths(Mix.env()),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "test.watch": :test
      ],
      docs: [
        main: "readme",
        source_url: @source_url,
        source_ref: "v#{@version}",
        extras: ["README.md", "LICENSE", "CHANGELOG.md"],
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :inets, :ssl]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:req, "~> 0.5.0"},
      {:briefly, "~> 0.5.1"},
      {:mox, "~> 1.1", only: :test},
      {:excoveralls, "~> 0.18.1", only: :test},
      {:plug, "~> 1.16", only: :test},
      {:ex_doc, "~> 0.34.1", only: :dev, runtime: false},
      {:mix_test_watch, "~> 1.2", only: [:dev, :test], runtime: false},
      {:git_ops, "~> 2.6.1", only: :dev }
    ]
  end

  defp description do
    "An Elixir library for easily downloading and extracting Git repositories from various hosting services."
  end

  defp package do
    [
      name: "gitly",
      files: ["lib", "mix.exs", "mix.lock", "README.md", "LICENSE", "CHANGELOG.md"],
      maintainers: ["iwatakeshi"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url
      }
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(:dev), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
