defmodule LiveViewNative do
  def plugin_for(format) when is_atom(format) do
    format
    |> Atom.to_string()
    |> plugin_for()
  end

  def plugin_for(format) when is_binary(format) do
    Map.get(plugins(), format)
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
