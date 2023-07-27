defmodule LiveViewNative.Extensions.Render do
  @moduledoc """
  LiveView Native extension for swapping the `render/1` function when rendering
  for specific platforms from a LiveView or Live Component. Using this macro causes
  a module to inherit a `render_native/1` function which takes a map of assigns and
  calls `render/1` on the render module for the calling platform as defined by the
  `LiveViewNativePlatform.Env` struct set to the `:native` assign. The module
  where that platform-specific `render/1` function lives is derived by concatenating
  the LiveView or LiveComponent's module name with the platform context struct's
  `template_namespace` and should be automatically generated from a LiveView or Live
  Component that uses `LiveViewNative.LiveView` or `LiveViewNative.LiveComponent`
  respectively.

  This extension effectively allows a native-enabled LiveView or Live Component to
  support a distinct render context for each platform, allowing for platform-specific
  templates, modifiers, etc.
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
