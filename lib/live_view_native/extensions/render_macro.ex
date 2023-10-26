defmodule LiveViewNative.Extensions.RenderMacro do
  @moduledoc false

  @doc """
  This macro enables custom render macros for LiveView Native platforms.
  Each platform library can define its own custom render macro, typically
  a sigil (i.e. `~SWIFTUI`, `~JETPACK` etc.) as part of its implementation
  of `LiveViewNativePlatform.Kit.compile/1`.
  """
  defmacro __using__(opts \\ []) do
    quote bind_quoted: [
            render_macro: opts[:render_macro],
            platform_id: opts[:platform_id],
            stylesheet: opts[:stylesheet]
          ] do
      require EEx

      defmacro unquote(:"#{render_macro}")({:<<>>, meta, [expr]}, _modifiers) do
        unless Macro.Env.has_var?(__CALLER__, {:assigns, nil}) do
          raise "#{unquote(render_macro)} requires a variable named \"assigns\" to exist and be set to a map"
        end

        with %{} = platforms <- LiveViewNative.platforms(),
             %LiveViewNativePlatform.Env{} = context <- Map.get(platforms, unquote(platform_id)),
             platform_module <- Module.concat(__ENV__.module, context.template_namespace) do
          base_opts = [
            caller: __CALLER__,
            engine: Phoenix.LiveView.TagEngine,
            file: __CALLER__.file,
            indentation: meta[:indentation] || 0,
            line: __CALLER__.line + 1,
            stylesheet: unquote(stylesheet),
            tag_handler: LiveViewNative.TagEngine
          ]

          expr = LiveViewNative.Templates.precompile(expr, unquote(platform_id), base_opts)
          eex_opts = Keyword.put(base_opts, :source, expr)

          EEx.compile_string(expr, eex_opts)
        end
      end
    end
  end
end
