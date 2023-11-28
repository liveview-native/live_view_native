defmodule LiveViewNative.Extensions.InlineRender do
  @moduledoc false

  @doc """
  This macro enables inline-rendering of templates for any LiveView Native
  platform. Using this macro causes a module to inherit a `LVN/2` sigil that
  can be used to render templates inline by suffixing it with the platform's
  `platform_id`:

  ```elixir
  defmodule MyAppWeb.HelloLive do
    use Phoenix.LiveView
    use LiveViewNative.LiveView

    @impl true
    def render(%{platform_id: :swiftui} = assigns) do
      ~LVN\"\"\"
      <Text modifiers={@native |> foreground_style(primary: {:color, :mint})}>
        Hello from iOS!
      </Text>
      \"\"\"swiftui
    end

    def render(assigns) do
      ~H\"\"\"
      <div>Hello from the web!</div>
      \"\"\"
    end
  end
  ```
  """
  defmacro __using__(opts \\ []) do
    quote bind_quoted: [
            platform_id: opts[:platform_id],
            stylesheet: opts[:stylesheet]
          ], location: :keep do
      require EEx

      defmacro sigil_LVN({:<<>>, meta, [expr]}, modifiers) do
        unless Macro.Env.has_var?(__CALLER__, {:assigns, nil}) do
          raise "~LVN requires a variable named \"assigns\" to exist and be set to a map"
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
