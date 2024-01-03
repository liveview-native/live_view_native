defmodule LiveViewNative.Component do
  import LiveViewNative.Utils, only: [
    stringify_format: 1
  ]

  defmacro __using__(opts) do
    format = opts[:format]
    fallback_template_path =
      __CALLER__.file
      |> Path.dirname()
      |> Path.join(stringify_format(format))

    case LiveViewNative.fetch_plugin(format) do
      {:ok, plugin} ->
        quote do
          use unquote(plugin.component())
          Module.register_attribute(__MODULE__, :native_opts, persist: true)
          Module.put_attribute(__MODULE__, :native_opts, %{
            format: unquote(opts[:format]),
            layout: unquote(opts[:layout]),
            template_path: unquote(opts[:template_path] || fallback_template_path)
          })

          @before_compile LiveViewNative.Renderer
        end

      :error ->
        IO.warn("tried to load LiveViewNative plugin for format #{inspect(format)} but none was found")

        []
    end
  end

  defmacro embed_sigil(modifiers, plugin) do
    quote do
      defmacro sigil_LVN({:<<>>, meta, [expr]}, modifiers)
        when modifiers in [[] | unquote(modifiers)] do

        unless Macro.Env.has_var?(__CALLER__, {:assigns, nil}) do
          raise "~LVN requires a variable named \"assigns\" to exist and be set to a map"
        end

        debug_annotations? = Module.get_attribute(__CALLER__.module, :__debug_annotations__)
        modifier = LiveViewNative.Component.normalize_modifier(modifiers)

        options = [
          engine: Phoenix.LiveView.TagEngine,
          file: __CALLER__.file,
          line: __CALLER__.line + 1,
          caller: __CALLER__,
          indentation: meta[:indentation] || 0,
          source: expr,
          tag_handler: unquote(plugin).tag_handler(modifier),
          annotate_tagged_content:
            debug_annotations? && (&LiveViewNative.Engine.annotate_tagged_content/1)
        ]

        EEx.compile_string(expr, options)
      end
    end
  end

  def normalize_modifier([]), do: nil
  def normalize_modifier(modifier) when is_list(modifier) do
    modifier
    |> List.to_string()
    |> String.to_atom()
  end
end