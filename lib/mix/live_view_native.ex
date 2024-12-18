defmodule Mix.LiveViewNative do

  import Mix.LiveViewNative.Context, only: [
    compile_string: 1
  ]

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
            format = Atom.to_string(client.format)

            Map.put(plugins, format, client)
          else
            plugins
          end
        end)
        |> Map.merge(plugins)
      end)

    Map.merge(found_plugins, config_plugins)
  end

  def detect_necessary_deps() do
    deps = [
      :live_view_native_stylesheet,
      :live_view_native_live_form
    ]

    installed_deps = Mix.Project.deps_tree() |> Map.keys()

    deps
    |> Enum.reject(fn(dep) -> dep in installed_deps end)
    |> case do
      [] -> :noop
      deps ->
        msg = """
        <%= IO.ANSI.red() %><%= IO.ANSI.bright() %>The following dependencies are missing from your application:<%= IO.ANSI.reset() %>
        <%= for dep <- deps do %>
        * <%= dep %><% end %>

        These are necessary for LiveView Native that you must install before continuing.
        """
        |> compile_string()

        raise msg
    end
  end
end
