defmodule HydepwnsLiveview.MixProject do
  use Mix.Project

  def project do
    [
      app: :hydepwns_liveview,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "coveralls.github": :test,
        dialyzer: :dev
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {HydepwnsLiveview.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:raxol, "~> 0.4.0"},
      {:phoenix, "~> 1.7.20"},
      {:phoenix_ecto, "~> 4.5"},
      {:ecto_sql, "~> 3.11"},
      {:postgrex, ">= 0.20.0"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_html_helpers, "~> 1.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.0"},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.1.1",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      {:swoosh, "~> 1.5"},
      {:finch, "~> 0.13"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.26"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.1.1"},
      {:bandit, "~> 1.5"},

      # Add CSS processing
      {:dart_sass, "~> 0.7", runtime: Mix.env() == :dev},

      # Add code quality tools
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},

      # Testing tools
      {:mox, "~> 1.0", only: :test},
      {:wallaby, "~> 0.30.3", only: :test, runtime: false},

      # Add UUID generation
      {:uuid, "~> 1.1"},

      # Add Inflex for pluralization
      {:inflex, "~> 2.0"},

      # Documentation
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:httpoison, "~> 1.8"},

      # Add test coverage and static analysis
      {:excoveralls, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.3", only: [:dev], runtime: false}

      # Authentication - Uncomment to add authentication
      # {:phx_gen_auth, "~> 0.7.1", only: [:dev], runtime: false},
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["cmd npm --prefix assets run build", "test"],
      "assets.setup": ["esbuild.install --if-missing", "sass.install --if-missing"],
      "assets.build": ["esbuild hydepwns_liveview", "sass default"],
      "assets.deploy": [
        "esbuild hydepwns_liveview --minify",
        "sass default --no-source-map --style=compressed",
        "phx.digest"
      ]
    ]
  end
end
