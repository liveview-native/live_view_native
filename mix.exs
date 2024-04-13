defmodule LiveViewNative.MixProject do
  use Mix.Project

  @version "0.3.0-beta.1"
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
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
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
      {:live_view_native_test, github: "liveview-native/live_view_native_test", tag: "v0.3.0", only: :test}
    ]
  end

  defp docs do
    [
      extras: ["README.md"],
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}"
    ]
  end

  defp description, do: "LiveView Native"

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
