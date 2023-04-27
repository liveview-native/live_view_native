defmodule LiveViewNative.Extensions.InlineRender do
  @moduledoc """
  LiveView Native extension that enables inline-rendering of templates for LiveView
  Native platforms within a LiveView or Live Component. Using this macro causes
  a module to inherit a `Z/2` sigil that can be used to render templates inline
  by suffixing it with the platform's `platform_id`:

  ```elixir
  defmodule MyAppWeb.HelloLive do
    use Phoenix.LiveView
    use LiveViewNative.LiveView

    @impl true
    def render(%{platform_id: :swiftui} = assigns) do
      ~Z\"\"\"
      <Text modifiers={@native |> foreground_style(primary: {:color, :mint})}>
        Hello from iOS!
      </Text>
      \"\"\"ios
    end

    def render(assigns) do
      ~H\"\"\"
      <div>Hello from the web!</div>
      \"\"\"
    end
  end
  ```
  """
  defmacro __using__(_opts \\ []) do
    quote bind_quoted: [] do
      require EEx

      defmacro sigil_Z({:<<>>, meta, [expr]}, modifiers) do
        unless Macro.Env.has_var?(__CALLER__, {:assigns, nil}) do
          raise "~Z requires a variable named \"assigns\" to exist and be set to a map"
        end

        with %{} = platforms <- LiveViewNative.platforms(),
             %LiveViewNativePlatform.Context{} = context <- Map.get(platforms, "#{modifiers}"),
             platform_module <- Module.concat(__ENV__.module, context.template_namespace)
        do
          options = [
            engine: Phoenix.LiveView.TagEngine,
            file: __CALLER__.file,
            line: __CALLER__.line + 1,
            caller: __CALLER__,
            indentation: meta[:indentation] || 0,
            source: expr,
            tag_handler: LiveViewNative.TagEngine
          ]

          EEx.compile_string(expr, options)
        end
      end
    end
  end
end
