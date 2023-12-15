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
          %{format: format, native: %LiveViewNativePlatform.Env{} = platform_context} ->
            render_function = String.to_existing_atom("render_#{format}")

            apply(__MODULE__, render_function, [assigns])

          _ ->
            apply(__MODULE__, :render_html, [assigns])
        end
      end
    end
  end
end
