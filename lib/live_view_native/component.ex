defmodule LiveViewNative.Component do
  defmacro __using__(opts) do
    %{module: module} = __CALLER__
    format = opts[:format]

    Module.put_attribute(module, :native_opts, %{
      as: opts[:as],
      format: format,
      layout: opts[:layout],
      root: opts[:root]
    })

    declarative_opts = Keyword.drop(opts, [:as, :format, :layout, :root])

    case LiveViewNative.fetch_plugin(format) do
      {:ok, plugin} ->
        quote do
          import Phoenix.LiveView.Helpers
          import Kernel, except: [def: 2, defp: 2]
          import Phoenix.Component, except: [embed_templates: 1, embed_templates: 2]
          import Phoenix.Component.Declarative
          require Phoenix.Template
  
          for {prefix_match, value} <- Phoenix.Component.Declarative.__setup__(__MODULE__, unquote(declarative_opts)) do
            @doc false
            def __global__?(prefix_match), do: value
          end

          use unquote(plugin.component)
          import LiveViewNative.Renderer, only: [
            delegate_to_target: 1,
            delegate_to_target: 2,
            embed_templates: 1,
            embed_templates: 2
          ]

          if (unquote(opts[:as])) do
            @before_compile LiveViewNative.Renderer
          end
          @before_compile LiveViewNative.Component
        end

      :error ->
        IO.warn("tried to load LiveViewNative plugin for format #{inspect(format)} but none was found")

        []
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      delegate_to_target :render, supress_warning: true
    end
  end

  defmacro sigil_LVN({:<<>>, meta, [expr]}, _modifiers) do
    unless Macro.Env.has_var?(__CALLER__, {:assigns, nil}) do
      raise "~LVN requires a variable named \"assigns\" to exist and be set to a map"
    end

    debug_annotations? = Module.get_attribute(__CALLER__.module, :__debug_annotations__)

    options = [
      engine: Phoenix.LiveView.TagEngine,
      file: __CALLER__.file,
      line: __CALLER__.line + 1,
      caller: __CALLER__,
      indentation: meta[:indentation] || 0,
      source: expr,
      tag_handler: LiveViewNative.TagEngine,
      annotate_tagged_content:
        debug_annotations? && (&LiveViewNative.Engine.annotate_tagged_content/1)
    ]

    EEx.compile_string(expr, options)
  end
end