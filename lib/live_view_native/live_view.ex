defmodule LiveViewNative.LiveView do
  @moduledoc """
  Use this module within a LiveView to delegate rendering requests
  from a native client to a format specific rendering component.

  All event handling should remain in the LiveView, all rendering
  concerns for a given format will be delegated to the component.

  Please refer to `LiveViewNative.Component` for more information
  on rendering components.
  """
  import LiveViewNative.Utils, only: [
    normalize_layouts: 1,
    stringify_format: 1
  ]

  @doc """
  Uses LiveView Native in the current module for rendering delegation

      defmodule MyAppWeb.HomeLive do
        use MyAppWeb, :live_view
        use LiveViewNative,
          formats: [:swiftui, :jetpack],
          layouts: [
            swiftui: {MyAppWeb.Layouts.SwiftUI, :app},
            jetpack: {MyAppWeb.Layouts.Jetpack, :app}
          ]
      end

  ## Options
      * `:formats` - the formats this LiveView will delegate to
      a render component. For example, specifying `formats: [:swiftui, jetpack]`
      for a LiveView named `MyAppWeb.HomeLive` will
      invoke `MyAppWeb.HomeLive.SwiftUI` and `MyAppWeb.HomeLivew.Jetpack` when
      respectively rendering each format. The appended module suffix
      is taken from the `:module_suffix` value on each registered LiveView Native
      plugin.

    * `:layouts` - which layouts to render for each format,
      for example: `[swiftui: {MyAppWeb.Layouts.SwiftUI, :app}]`
  """
  defmacro __using__(opts) do
    quote do
      on_mount {LiveViewNative.ContentNegotiator, :call}
      @native_opts unquote(opts)
      @before_compile LiveViewNative.LiveView
    end
  end

  @doc false
  defmacro __before_compile__(%{module: module} = env) do
    opts = Module.get_attribute(module, :native_opts)
    formats = opts[:formats]
    fallback_layouts = normalize_layouts(opts[:layouts])

    cond do
      Keyword.keyword?(opts) ->
        {layouts, render_withs} =
          Enum.reduce(formats, {%{}, %{}}, fn(format, {layouts, render_withs}) ->
            case LiveViewNative.fetch_plugin(format) do
              {:ok, plugin} ->
                render_module = Module.concat(module, plugin.module_suffix)
                fallback_layout = fallback_layouts[format]
                render_with = Function.capture(render_module, :render, 1)

                layout =
                  module
                  |> Module.get_attribute(:native_opts)
                  |> Keyword.get(format)
                  |> normalize_layout_opts(fallback_layout, env)

                format = stringify_format(format)
                {Map.put(layouts, format, layout), Map.put(render_withs, format, render_with)}

              :error ->
                IO.warn("no LiveViewNative plugin for #{inspect(format)} found", Macro.Env.stacktrace(env))
                {layouts, render_withs}
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

  defp normalize_layout_opts(nil, nil, _env), do: false
  defp normalize_layout_opts(nil, fallback_layout, _env), do: fallback_layout
  defp normalize_layout_opts(opts, fallback_layout, %{module: module} = env) when is_map(opts) do
    case {Map.fetch(opts, :layout), fallback_layout} do
      {{:ok, {module, template}}, _} -> {module, template}
      {{:ok, false}, _} -> false
      {{:ok, nil}, nil} -> false
      {{:ok, nil}, fallback_layout} -> fallback_layout
      {{:ok, other}, _} -> raise "layout opts defined in `#{module}` must be either `{module, template}` or `false`. Got: #{inspect(other)}"
      {:error, nil} ->
        IO.warn("no layout or default layout defined, defaulting to `false`", Macro.Env.stacktrace(env))

        false
      {:error, fallback_layout} -> fallback_layout
    end
  end

end
