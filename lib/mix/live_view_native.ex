defmodule Mix.LiveViewNative do
  def plugins() do
    config_plugins = LiveViewNative.plugins()

    found_plugins =
      Mix.Project.deps_tree()
      |> Enum.filter(fn({_app, deps}) -> Enum.member?(deps, :live_view_native) end)
      |> Enum.reduce(%{}, fn({app, _deps}, plugins) ->
        spec = Application.spec(app)
        Enum.reduce(spec[:modules], %{}, fn(module, plugins) ->
          if Code.ensure_loaded?(module) && Kernel.function_exported?(module, :__lvn_client__, 0) do
            client = struct(module)
            Map.put(plugins, client.format, client)
          else
            plugins
          end
        end)
        |> Map.merge(plugins)
      end)

    Map.merge(found_plugins, config_plugins)
  end
end
