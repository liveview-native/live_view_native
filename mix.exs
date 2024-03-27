defmodule LiveViewNative.MixProject do
  use Mix.Project

  @version "0.3.0-alpha.3"
  @source_url "https://github.com/liveview-native/live_view_native"

  def project do
    [
      app: :live_view_native,
      version: @version,
      elixir: "~> 1.15",
      description: description(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      elixirc_paths: elixirc_paths(Mix.env()),
      docs: docs(),
      aliases: aliases()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end


  defp aliases do
    [
      docs: ["ex_doc_guides", "docs"]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix, "~> 1.7.0"},
      {:phoenix_view, "~> 2.0"},
      {:phoenix_live_view, "~> 0.20.10"},
      {:phoenix_live_reload, "~> 1.4", only: :test},
      {:phoenix_template, "~> 1.0.4"},
      {:phoenix_html, "~> 3.3 or ~> 4.0 or ~> 4.1"},
      {:floki, ">= 0.30.0", only: :test},
      {:plug, "~> 1.15"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},
      {:ex_doc, "~> 0.24", only: :dev, runtime: false},
      {:makeup_eex, ">= 0.1.1", only: :dev, runtime: false},
      {:owl, "~> 0.8", runtime: false},
      {:deep_merge, "~> 1.0"},
      {:live_view_native_test, github: "liveview-native/live_view_native_test", tag: "v0.3.0-alpha.4", only: :test}
    ]
  end

  defp docs do
    [
      extras: extras(),
      groups_for_extras: [
        "Livebooks": ~r/ex_doc_notebooks/
      ],
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
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

  defp description, do: "LiveView Native"

  defp extras do
    [
      "guides/ex_doc_notebooks/getting-started.md",
      "guides/ex_doc_notebooks/create-a-swiftui-application.md",
      "guides/ex_doc_notebooks/common-swiftui-views.md",
      "guides/ex_doc_notebooks/interactive-swiftui-views.md",
      "guides/ex_doc_notebooks/stylesheets.md",
      "guides/ex_doc_notebooks/native-navigation.md",
      "guides/ex_doc_notebooks/forms-and-validation.md"
    ]
  end


  defp package do
    %{
      maintainers: ["Brian Cardarella"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Built by DockYard, Expert Elixir & Phoenix Consultants" => "https://dockyard.com/phoenix-consulting"
      }
    }
  end
end
