defmodule LiveViewNative.LiveView do
  defmacro __using__(_opts \\ []) do
    quote bind_quoted: [] do
      require EEx

      @live_view_native_context %{
        template: %{
          basename: Path.basename(__ENV__.file) |> String.split(".") |> List.first(),
          directory: Path.dirname(__ENV__.file),
          extension: Path.extname(__ENV__.file),
          filename: __ENV__.file,
        }
      }

      on_mount {LiveViewNative.LiveSession, :live_view_native}

      for {platform_id, {platform_struct, platform_meta}} <- LiveViewNative.platforms() do
        template_extension = platform_meta.template_extension || ".#{platform_id}.heex"
        template_path = Path.join(@live_view_native_context.template.directory, @live_view_native_context.template.basename) <> template_extension
        template_exists? = File.exists?(template_path)
        platform_module = Module.concat(__ENV__.module, platform_meta.template_namespace)
        platform_modifiers = platform_meta.modifiers

        defmodule :"#{platform_module}" do
          require EEx

          for {modifier_key, modifier_mod} <- platform_modifiers do
            def unquote(:"#{modifier_key}")(ctx, opts \\ []) do
              apply(unquote(modifier_mod), :put_modifier, [ctx, opts])
            end
          end

          EEx.function_from_file(:def, :render, template_path, [:assigns], engine: Phoenix.LiveView.HTMLEngine)
        end
      end

      def render_native(assigns) do
        case assigns do
          %{native_platform_meta: %LiveViewNativePlatform.Metadata{} = platform_meta} ->
            render_module = Module.safe_concat([__MODULE__, platform_meta.template_namespace])

            apply(render_module, :render, [assigns])

          _ ->
            render_blank(assigns)
        end
      end

      EEx.function_from_string(:def, :render_blank, "", [:assigns], engine: Phoenix.LiveView.HTMLEngine)
    end
  end
end
