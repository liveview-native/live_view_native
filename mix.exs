defmodule LiveViewNative.MixProject do
  use Mix.Project

  @version "0.2.0"

  def project do
    [
      app: :live_view_native,
      version: @version,
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
      docs: docs()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      extra_applications: [:logger]
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
      {:phoenix, "~> 1.7.0"},
      {:phoenix_view, "~> 2.0"},
      # {:phoenix_live_view, path: "../phoenix_live_view", override: true},
      {:phoenix_live_view, github: "phoenixframework/phoenix_live_view", ref: "476d1cd288474d7acb33424a74b304b4e9495ff1", override: true},
      {:phoenix_live_reload, "~> 1.4", only: :test},
      {:phoenix_template, "~> 1.0.4"},
      {:floki, ">= 0.30.0", only: :test},
      {:plug, "~> 1.15"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},
      {:ex_doc, "~> 0.24", only: :dev, runtime: false},
      {:makeup_eex, ">= 0.1.1", only: :dev, runtime: false},
      {:owl, "~> 0.8", runtime: false},
      {:deep_merge, "~> 1.0"},
      # {:live_view_native_test, path: "../live_view_native_test", only: :test}
      {:live_view_native_test, github: "liveview-native/live_view_native_test", only: :test}
    ]
  end

  defp docs do
    [
      source_ref: "v#{@version}",
      main: "overview",
      logo: "guides/assets/images/logo.png",
      assets: "guides/assets",
      extra_section: "GUIDES",
      extras: extras(),
      groups_for_extras: groups_for_extras(),
      groups_for_modules: groups_for_modules(),
      before_closing_body_tag: fn
        :html ->
          """
          <script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
          <script>mermaid.initialize({startOnLoad: true})</script>
          """
        _ -> ""
      end
    ]
  end

  defp extras do
    [
      "guides/introduction/overview.md",
      "guides/introduction/installation.md",
      "guides/introduction/your-first-native-liveview.md",
      "guides/introduction/troubleshooting.md",
      "guides/introduction/deployment.md",
      "guides/common-features/template-syntax.md",
      "guides/common-features/render-patterns.md",
      "guides/common-features/handling-events.md",
      "guides/ex_doc_notebooks/getting-started.md",
      "guides/ex_doc_notebooks/create-a-swiftui-application.md",
      "guides/ex_doc_notebooks/common-swiftui-views.md",
      "guides/ex_doc_notebooks/stylesheets.md",
      "guides/ex_doc_notebooks/interactive-swiftui-views.md",
      "guides/ex_doc_notebooks/native-navigation.md",
      "guides/ex_doc_notebooks/forms-and-validation.md"
    ]
  end

  defp groups_for_extras do
    [
      Introduction: ~r/guides\/introduction\/.?/,
      Guides: ~r/guides\/[^\/]+\.[md|livemd]/,
      "Interactive Guides": ~r/guides\/ex_doc_notebooks\/[^\/]+\.[md|livemd]/,
      "Common Features": ~r/guides\/common-features\/.?/
    ]
  end

  defp groups_for_modules do
    []
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get"],
      docs: ["ex_doc_guides", "docs"]
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
