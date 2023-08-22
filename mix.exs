defmodule LiveViewNative.MixProject do
  use Mix.Project

  def project do
    [
      app: :live_view_native,
      version: "0.0.9-rc.1",
      elixir: "~> 1.15",
      description: "Native platform implementations of the Phoenix LiveView protocol",
      package: package(),
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      consolidate_protocols: Mix.env() != :test,

      docs: [
        main: "about",
        extras: [
          "guides/introduction/about.md",
          "guides/introduction/installation.md",
          "guides/client-side-integration/change-events.md",
        ],
        groups_for_extras: [
          "Introduction": Path.wildcard("guides/introduction/*.md"),
          "Client-Side Integration": Path.wildcard("guides/client-side-integration/*.md")
        ]
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {LiveViewNative.Application, []},
      extra_applications: [:logger, :live_view_native_platform]
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
      {:phoenix, "~> 1.7"},
      {:phoenix_view, "~> 2.0"},
      {:phoenix_live_view, "~> 0.18.18 or ~> 0.19.0"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},
      {:floki, ">= 0.30.0", only: :test},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:makeup_eex, ">= 0.1.1", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:meeseeks, "~> 0.17.0"},
      {:live_view_native_platform, "~> 0.0.8-rc.1"}
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
      setup: ["deps.get"]
    ]
  end

  @source_url "https://github.com/liveview-native/live_view_native"

  # Hex package configuration
  defp package do
    %{
      maintainers: ["May Matyi"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url
      },
      source_url: @source_url
    }
  end
end
