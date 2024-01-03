defmodule LiveViewNative do
  @callback format() :: atom
  @callback module_suffix() :: atom
  @callback template_engine() :: Macro.t()
  @callback tag_handler(target :: atom) :: module()
  @callback component() :: module()

  import LiveViewNative.Utils, only: [stringify_format: 1]

  def fetch_plugin(:html), do: {:ok, LiveViewNative.HTML}
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
            {:ok, plugins} -> plugins
            :error -> []
          end
          |> Enum.into(%{}, &({Atom.to_string(&1.format()), &1}))

        :ok = Application.put_env(:live_view_native, :plugins_map, plugins)
        plugins
    end
  end

  def available_formats() do
    case Application.fetch_env(:live_view_native, :plugins) do
      {:ok, plugins} ->
        Enum.map(plugins, &(&1.format()))
      :error ->
        IO.warn("No LiveView Native plugins registered")

        []
    end
  end
end
