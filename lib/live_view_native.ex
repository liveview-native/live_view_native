defmodule LiveViewNative do
  import LiveViewNative.Utils, only: [stringify_format: 1]

  defmacro __using__(config) do
    quote bind_quoted: [config: config] do
      defstruct format: config[:format],
        component: config[:component],
        module_suffix: config[:module_suffix],
        template_engine: config[:template_engine],
        tag_handler: config[:tag_handler],
        stylesheet_rules_parser: config[:stylesheet_rules_parser]
    end
  end

  def fetch_plugin(format) do
    Map.fetch(plugins(), stringify_format(format))
  end

  def plugins() do
    case Application.fetch_env(:live_view_native, :plugins_map) do
      {:ok, plugins} -> plugins
      :error ->
        plugins =
          Application.fetch_env(:live_view_native, :plugins)
          |> case do
            {:ok, plugins} ->
              require IEx
              IEx.pry()
              Enum.map(plugins, &struct(&1))
            :error -> []
          end
          |> Enum.into(%{}, &({Atom.to_string(&1.format), &1}))

        :ok = Application.put_env(:live_view_native, :plugins_map, plugins)
        plugins
    end
  end

  def available_formats() do
    case Application.fetch_env(:live_view_native, :plugins) do
      {:ok, plugins} ->
        Enum.map(plugins, &(&1.format))
      :error ->
        IO.warn("No LiveView Native plugins registered")

        []
    end
  end
end
