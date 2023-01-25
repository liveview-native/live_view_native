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
    platform_modifiers = opts[:platform_modifiers]

    quote bind_quoted: [platform_modifiers: platform_modifiers] do
      if platform_modifiers do
        platform_modifiers_as_struct = struct(platform_modifiers, %{})

        for {modifier_key, _val} <- Map.from_struct(platform_modifiers_as_struct) do
          def unquote(:"#{modifier_key}")(ctx, params \\ %{}, opts \\ []) do
            modifiers = ctx.modifiers
            modifier_value = Map.get(modifiers, unquote(modifier_key)) || %{}
            modifier_changes = Enum.into(params, %{})
            updated_modifier_value = Map.merge(modifier_value, modifier_changes)

            updated_modifiers = Map.put(modifiers, unquote(modifier_key), updated_modifier_value)

            Map.put(ctx, :modifiers, updated_modifiers)
          end
        end
      end
    end
  end
end
