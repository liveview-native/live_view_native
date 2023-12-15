defmodule LiveViewNative.Extensions do
  @moduledoc false

  @doc """
  This macro is largely responsible for upgrading a LiveView or Live Component
  to a module that supports LiveView Native. This macro should not be directly
  inherited by a LiveView or Live Component via `use`; instead, those modules
  should use `LiveViewNative.LiveView` or `LiveViewNative.LiveComponent`
  respectively.
  """
  defmacro __using__(opts) do
    compiled_at = :os.system_time(:nanosecond)
    role = opts[:role]

    quote bind_quoted: [caller: Macro.escape(__CALLER__), compiled_at: compiled_at, role: role],
          location: :keep do
      Code.put_compiler_option(:ignore_module_conflict, true)

      for {platform_id, platform_context} <- LiveViewNative.platforms() do
        require EEx

        # `render_native/1` (external templates)
        use LiveViewNative.Extensions.Templates,
          caller: caller,
          eex_engine: platform_context.eex_engine,
          render_function: String.to_atom("render_#{platform_id}"),
          tag_handler: platform_context.tag_handler,
          template_basename: Path.basename(__ENV__.file) |> String.split(".") |> List.first(),
          template_directory: Path.dirname(__ENV__.file),
          template_extension: platform_context.template_extension || ".#{platform_id}.heex"

        if platform_id != "html" do
          if is_nil(platform_context.render_macro) do
            # Custom render sigil
            use LiveViewNative.Extensions.InlineRender,
              compiled_at: compiled_at,
              platform_id: platform_id,
              role: role
          else
            # Default render sigil (`~LVN`)
            use LiveViewNative.Extensions.RenderMacro,
              compiled_at: compiled_at,
              platform_id: platform_id,
              render_macro: platform_context.render_macro,
              role: role
          end
        end
      end

      use LiveViewNative.Extensions.Render
      use LiveViewNative.Extensions.Stylesheets, module: __ENV__.module
    end
  end
end
