defmodule LiveViewNative.LiveView do
  import LiveViewNative.Utils, only: [normalize_format: 1]

  defmacro __using__(opts) do
    quote do
      on_mount {LiveViewNative.ContentNegotiator, :call}
      @native_opts unquote(opts)
      @before_compile LiveViewNative.LiveView
    end
  end

  defmacro __before_compile__(%{module: module} = env) do
    formats = LiveViewNative.available_formats()
    opts = Module.get_attribute(module, :native_opts)

    cond do
      Keyword.keyword?(opts) ->
        {layouts, render_withs} =
          Enum.reduce(opts, {%{}, %{}}, fn({format, render_module}, {layouts, render_withs}) ->
            format = normalize_format(format)
            render_with = Function.capture(render_module, :render, 1)

            case Code.ensure_compiled(render_module) do
              {:module, render_module} ->
                layout =
                  :attributes
                  |> render_module.__info__()
                  |> Keyword.get(:liveview_native_opts)
                  |> normalize_layout_opts(env)

                {Map.put(layouts, format, layout), Map.put(render_withs, format, render_with)}
              {:error, :unavailable} ->
                layout =
                  render_module
                  |> Module.get_attribute(:liveview_native_opts)
                  |> normalize_layout_opts(env)

                {Map.put(layouts, format, layout), Map.put(render_withs, format, render_with)}

              {:error, :nofile} -> {layouts, render_withs}
            end
          end)

        quote do
          def __native__() do
            %{
              formats: unquote(formats),
              layouts: unquote(Macro.escape(layouts)),
              render_with: unquote(Macro.escape(render_withs))
            }
          end
        end

      true ->
        raise "options for LiveViewNative.LiveView defined in #{module} must be a keyword list of `{format, render_module}` such as `swiftui: MyAppWeb.SwiftUI.HomeLive`"
    end
  end

  defp normalize_layout_opts(nil, _env), do: false
  defp normalize_layout_opts([opts], env) when is_map(opts) do
    normalize_layout_opts(opts, env)
  end
  defp normalize_layout_opts(opts, %{module: module} = env) when is_map(opts) do
    case Map.fetch(opts, :layout) do
      {:ok, {module, template}} -> {module, template}
      {:ok, false} -> false
      {:ok, other} -> raise "layout opts defined in `#{module}` must be either `{module, template}` or `false`. Got: #{inspect(other)}"
      :error ->
        IO.warn("no layout defined, defaulting to `false`", Macro.Env.stacktrace(env))

        false
    end
  end

end
