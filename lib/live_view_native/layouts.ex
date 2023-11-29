defmodule LiveViewNative.Layouts do
  def extract_layouts(%{file: file} = opts) do
    file
    |> File.read!()
    |> Code.string_to_quoted!()
    |> extract_layouts_recursive(opts)
    |> List.flatten()
    |> Enum.map(fn layout_params -> {layout_params.render_function, layout_params} end)
    |> Enum.reject(&(format_excluded?(&1, opts)))
    |> Enum.into(%{})
    |> apply_default_layouts(opts)
  end

  def extract_layouts_recursive({:embed_templates, _meta, [template | _args]}, %{} = opts) do
    base_path = Path.join([opts.dirname, Path.dirname(template)])
    opts = Map.put(opts, :base_path, base_path)

    base_path
    |> File.ls!()
    |> Enum.map(&extract_layout(&1, opts))
    |> Enum.filter(& &1)
  end

  def extract_layouts_recursive({_func, _meta, [_ | _] = nodes}, %{} = opts),
    do: Enum.map(nodes, &extract_layouts_recursive(&1, opts))

  def extract_layouts_recursive([do: {:__block__, [], args}], %{} = opts), do: extract_layouts_recursive(args, opts)

  def extract_layouts_recursive([_ | _] = nodes, %{} = opts),
    do: Enum.map(nodes, &extract_layouts_recursive(&1, opts))

  def extract_layouts_recursive(_node, _opts), do: []

  def extract_layout(filename, %{platforms: platforms} = opts) do
    template_path = Path.join(opts.base_path, filename)

    platforms
    |> Enum.find(&matches_template?(&1, filename))
    |> compile_layout(template_path, opts)
  end

  def compile_layout({_format, platform}, template_path, _opts) do
    render_function_name =
      template_path
      |> Path.basename()
      |> Path.rootname()
      |> String.replace(".", "_")
      |> String.to_atom()

    %{
      template: File.read!(template_path),
      eex_engine: platform.eex_engine,
      platform_id: platform.platform_id,
      render_function: render_function_name,
      tag_handler: platform.tag_handler,
      template_path: template_path
    }
  end

  def compile_layout(_platform, _template_path, _opts), do: nil

  def matches_template?({_key, %{} = platform}, filename) do
    case platform.template_extension do
      nil ->
        false

      extension ->
        String.ends_with?(filename, extension)
    end
  end

  ###

  defp apply_default_layouts(%{} = layouts, %{default_layouts: true, platforms: platforms} = opts) do
    platforms
    |> Enum.reject(&(format_excluded?(&1, opts)))
    |> Enum.flat_map(fn {format, %{default_layouts: %{} = default_layouts} = platform} ->
      Enum.map(default_layouts, fn {layout_name, layout_source} ->
        {String.to_atom("#{layout_name}_#{format}"), {layout_source, platform}}
      end)
    end)
    |> Enum.into(%{})
    |> Enum.reduce(layouts, fn {render_function_name, {layout_source, platform}}, %{} = acc ->
      if Map.has_key?(acc, render_function_name) do
        acc
      else
        Map.put(acc, render_function_name, %{
          template: layout_source,
          render_function: render_function_name,
          template_path: nil,
          eex_engine: platform.eex_engine,
          platform_id: platform.platform_id,
          tag_handler: platform.tag_handler
        })
      end
    end)
  end

  defp apply_default_layouts(%{} = layouts, _opts), do: layouts

  defp format_excluded?({_, %{platform_id: platform_id}}, %{} = opts) do
    case opts do
      %{exclude: [_ | _] = excluded_formats} ->
        platform_id in excluded_formats

      _ ->
        false
    end
  end

  defmacro __using__(_opts \\ []) do
    quote bind_quoted: [caller: Macro.escape(__CALLER__)], location: :keep do
      use LiveViewNative.Extensions, role: :layouts

      layout_templates =
        %{
          caller: caller,
          default_layouts: true,
          dirname: Path.dirname(__ENV__.file),
          exclude: [:html],
          file: __ENV__.file,
          platforms: LiveViewNative.platforms()
        }
        |> LiveViewNative.Layouts.extract_layouts()
        |> Enum.map(fn {render_func, %{} = layout_params} ->
          if layout_params.template_path do
            @external_resource layout_params.template_path
          end

          eex_opts = [
            caller: caller,
            engine: layout_params.eex_engine,
            file: __ENV__.file,
            render_function: {render_func, 1},
            source: layout_params.template,
            tag_handler: layout_params.tag_handler
          ]
          LiveViewNative.Templates.compile_class_tree(layout_params.template, layout_params.platform_id, eex_opts)
          expr = LiveViewNative.Templates.with_stylesheet_wrapper(layout_params.template)

          EEx.function_from_string(:def, render_func, expr, [:assigns], eex_opts)
        end)
    end
  end
end
