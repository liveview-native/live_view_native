defmodule LiveViewNative.Modclasses do
  @moduledoc false

  defmacro __using__(opts) do
    platform_id = "#{opts[:platform]}"

    quote do
      with %{} = platforms <- LiveViewNative.platforms(),
           %LiveViewNativePlatform.Env{} = context <- Map.get(platforms, unquote(platform_id)) do
        use LiveViewNative.Extensions.Modifiers,
          custom_modifiers: context.custom_modifiers || [],
          modifiers_struct: context.modifiers_struct,
          platform_modifiers: context.platform_modifiers || []
      end
    end
  end
end
