defmodule LiveViewNative.Extensions.Render do
  @moduledoc false

  @doc """
  This macro adds support for the `render_native/1` function which allows
  namespacing external platform-specific template files (for example,
  `template_live.swiftui.heex`, `template_live.jetpack.heex`, etc.)
  """
  defmacro __using__(_opts \\ []) do
    quote bind_quoted: [] do
      require EEx

      def render_native(assigns) do
        case assigns do
          %{native: %LiveViewNativePlatform.Env{} = platform_context} ->
            render_module = Module.safe_concat([__MODULE__, platform_context.template_namespace])

            apply(render_module, :render, [assigns])

          _ ->
            render_blank(assigns)
        end
      end

      EEx.function_from_string(:def, :render_blank, "", [:assigns],
        engine: Phoenix.LiveView.Engine
      )
    end
  end
end
