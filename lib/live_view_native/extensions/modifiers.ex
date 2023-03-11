defmodule LiveViewNative.Extensions.Modifiers do
  @moduledoc """
  LiveView Native extension for platform-specific modifiers. Modifiers refer to
  properties that affect the behavior and visual presentation of native components,
  such as alignment, visibility, styling, and so on. Each platform library defines
  its own set of supported modifiers as well as how to encode those modifiers before
  they are returned from the LiveView server to the client.

  Each modifier for a platform is exposed to its platform-specific templates as a
  function named after the modifier and taking one argument, the `@native` assign.
  These function names may overlap between platforms that co-mingle within a LiveView
  Native application without conflict, thanks to each platform having its own render
  context as part of `LiveViewNative.Extensions.Render`.
  """
  defmacro __using__(opts \\ []) do
    quote bind_quoted: [
      custom_modifiers: opts[:custom_modifiers],
      platform_modifiers: opts[:platform_modifiers]
    ] do
      all_modifiers = Keyword.merge(platform_modifiers, custom_modifiers)

      for {modifier_key, modifier_module} <- all_modifiers do
        def unquote(:"#{modifier_key}")(ctx, params \\ %{}) do
          modifiers = ctx.modifiers
          modifier = apply(unquote(modifier_module), :modifier, [params])

          Map.put(ctx, :modifiers, LiveViewNativePlatform.Modifiers.append(modifiers, modifier))
        end
      end
    end
  end
end
