defmodule LiveViewNative.Extensions do
  @moduledoc """
  This macro is largely responsible for upgrading a LiveView or Live Component
  to a module that supports LiveView Native. This macro should not be directly
  inherited by a LiveView or Live Component via `use`; instead, those modules
  should use `LiveViewNative.LiveView` or `LiveViewNative.LiveComponent`
  respectively.
  """
  defmacro __using__(_opts \\ []) do
    caller = Macro.escape(__CALLER__)

    quote bind_quoted: [caller: caller] do
      for {platform_id, platform_context} <- LiveViewNative.platforms() do
        platform_module = Module.concat(__ENV__.module, platform_context.template_namespace)

        defmodule :"#{platform_module}" do
          use LiveViewNative.Extensions.Modifiers, platform_modifiers: platform_context.modifiers

          use LiveViewNative.Extensions.Templates,
            caller: caller,
            platform_module: platform_module,
            template_basename: Path.basename(__ENV__.file) |> String.split(".") |> List.first(),
            template_directory: Path.dirname(__ENV__.file),
            template_engine: platform_context.template_engine,
            template_extension: platform_context.template_extension || ".#{platform_id}.heex",
            template_path: template_path
        end
      end

      use LiveViewNative.Extensions.Render
    end
  end
end
