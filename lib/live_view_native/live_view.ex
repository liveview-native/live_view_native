defmodule LiveViewNative.LiveView do
  defmacro __using__(_opts \\ []) do
    quote bind_quoted: [] do
      require EEx

      @live_view_native_context %{
        template: %{
          basename: Path.basename(__ENV__.file) |> String.split(".") |> List.first(),
          directory: Path.dirname(__ENV__.file),
          extension: Path.extname(__ENV__.file),
          filename: __ENV__.file
        }
      }

      on_mount {LiveViewNative.LiveSession, :live_view_native}

      for {platform_id, platform_context} <- LiveViewNative.platforms() do
        template_extension = platform_context.template_extension || ".#{platform_id}.heex"

        template_path =
          Path.join(
            @live_view_native_context.template.directory,
            @live_view_native_context.template.basename
          ) <> template_extension

        template_exists? = File.exists?(template_path)
        platform_module = Module.concat(__ENV__.module, platform_context.template_namespace)
        platform_modifiers = platform_context.modifiers

        platform_modifiers_as_struct =
          if platform_modifiers, do: struct(platform_modifiers, %{}), else: nil

        defmodule :"#{platform_module}" do
          require EEx

          if platform_modifiers_as_struct do
            for {modifier_key, _val} <- Map.from_struct(platform_modifiers_as_struct) do
              def unquote(:"#{modifier_key}")(ctx, params \\ %{}, opts \\ []) do
                modifiers = ctx.modifiers
                modifier_value = Map.get(modifiers, unquote(modifier_key)) || %{}
                modifier_changes = Enum.into(params, %{})
                updated_modifier_value = Map.merge(modifier_value, modifier_changes)

                updated_modifiers =
                  Map.put(modifiers, unquote(modifier_key), updated_modifier_value)

                Map.put(ctx, :modifiers, updated_modifiers)
              end
            end
          end

          EEx.function_from_file(:def, :render, template_path, [:assigns],
            engine: Phoenix.LiveView.HTMLEngine
          )
        end
      end

      def render_native(assigns) do
        case assigns do
          %{native: %LiveViewNativePlatform.Context{} = platform_context} ->
            render_module = Module.safe_concat([__MODULE__, platform_context.template_namespace])

            apply(render_module, :render, [assigns])

          _ ->
            render_blank(assigns)
        end
      end

      EEx.function_from_string(:def, :render_blank, "", [:assigns],
        engine: Phoenix.LiveView.HTMLEngine
      )
    end
  end
end
