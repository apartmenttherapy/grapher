defmodule Grapher.Mixfile do
  use Mix.Project

  def project do
    [
      app: :grapher,
      version: "0.7.2",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env),
      start_permanent: Mix.env == :prod,
      dialyzer: [plt_add_deps: :transitive, ignore_warnings: "dialyzer.ignore-warnings"],
      description: description(),
      package: package(),
      deps: deps()
    ] ++ doc_config() ++ coveralls_config()
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Grapher, []},
      start_phases: [{:setup, []}],
      extra_applications: [:logger],
      env: [transport: HTTPoison]
    ]
  end

  defp coveralls_config do
    [
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, ">= 0.0.0", only: [:dev, :test]},
      {:dialyxir, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:excoveralls, ">= 0.0.0", only: [:test]},
      {:httpoison, ">= 0.0.0"},
      {:poison, ">= 0.0.0"}
    ]
  end

  defp description do
    "A GraphQL client written in Elixir, providing document storage, management of multiple schemas and facilities for HTTP based schema auth."
  end

  defp doc_config do
    [
      name: "Grapher",
      source_url: "https://github.com/apartmenttherapy/grapher",
      docs: [extras: ["README.md"]]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp package do
    [
      licenses: ["LGPLv3"],
      maintainers: ["Glen Holcomb"],
      links: %{"GitHub" => "https://github.com/apartmenttherapy/grapher"},
      source_url: "https://github.com/apartmenttherapy/grapher"
    ]
  end
end
