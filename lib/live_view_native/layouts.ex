defmodule LiveViewNative.Layouts do
  def extract_layouts(%{file: file} = opts) do
    file
    |> File.read!()
    |> Code.string_to_quoted!()
    |> extract_layouts_recursive(opts)
    |> List.flatten()
    |> Enum.map(fn layout_params -> {layout_params.render_function, layout_params} end)
    |> Enum.reject(&format_excluded?(&1, opts))
    |> Enum.into(%{})
    |> apply_default_layouts(opts)
    |> generate_class_trees(opts)
    |> persist_class_trees(opts)
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

  def extract_layouts_recursive([do: {:__block__, [], args}], %{} = opts),
    do: extract_layouts_recursive(args, opts)

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
    func_name =
      template_path
      |> Path.basename()
      |> Path.rootname()
      |> String.replace(".", "_")
      |> String.to_atom()

    is_root_template? = "#{func_name}" == "root_#{platform.platform_id}"

    %{
      class_tree: %{},
      template: layout_template(template_path, is_root_template?),
      eex_engine: platform.eex_engine,
      platform_id: platform.platform_id,
      render_function: func_name,
      tag_handler: platform.tag_handler,
      template_path: template_path
    }
  end

  def compile_layout(_platform, _template_path, _opts), do: nil

  def layout_template(template_path, is_root_template?) do
    template_path
    |> File.read!()
    |> layout_template_with_live_reload(Mix.env())
    |> layout_template_with_csrf_token(is_root_template?)
  end

  def layout_template_with_live_reload(template, :dev) do
    """
    #{template}
    <iframe src="/phoenix/live_reload/frame" />
    """
  end

  def layout_template_with_live_reload(template, _mix_env), do: template

  def layout_template_with_csrf_token(template, true) do
    """
    #{template}
    <csrf-token value={get_csrf_token()} />
    """
  end

  def layout_template_with_csrf_token(template, _is_root_template?), do: template

  def matches_template?({_key, %{} = platform}, filename) do
    case platform.template_extension do
      nil ->
        false

      extension ->
        String.ends_with?(filename, extension)
    end
  end

  def generate_class_trees(%{} = layouts, %{} = opts) do
    Enum.reduce(layouts, layouts, fn {func_name, %{template: template, platform_id: platform_id} = layout}, acc ->
      opts = Map.put(opts, :render_function, {layout.render_function, 1})

      case LiveViewNative.Templates.compile_class_tree(template, platform_id, opts) do
        {:ok, %{} = class_tree} ->
          updated_layout = Map.put(layout, :class_tree, class_tree)
          Map.put(acc, func_name, updated_layout)

        _ ->
          acc
      end
    end)
  end

  def persist_class_trees(%{} = layouts, opts) do
    layouts
    |> Enum.map(&extract_class_tree/1)
    |> LiveViewNative.Templates.persist_class_tree_map(opts.caller)

    layouts
  end

  ###

  defp apply_default_layouts(%{} = layouts, %{default_layouts: true, platforms: platforms} = opts) do
    platforms
    |> Enum.reject(&format_excluded?(&1, opts))
    |> Enum.flat_map(fn {format, %{default_layouts: %{} = default_layouts} = platform} ->
      Enum.map(default_layouts, fn {layout_name, layout_source} ->
        {String.to_atom("#{layout_name}_#{format}"), {layout_source, platform}}
      end)
    end)
    |> Enum.into(%{})
    |> Enum.reduce(layouts, fn {func_name, {layout_source, platform}}, %{} = acc ->
      if Map.has_key?(acc, func_name) do
        acc
      else
        Map.put(acc, func_name, %{
          template: layout_source,
          render_function: func_name,
          template_path: nil,
          eex_engine: platform.eex_engine,
          platform_id: platform.platform_id,
          tag_handler: platform.tag_handler
        })
      end
    end)
  end

  defp apply_default_layouts(%{} = layouts, _opts), do: layouts

  defp extract_class_tree({func_name, layout}) do
    case layout do
      %{class_tree: class_tree} ->
        {func_name, class_tree}

      _ ->
        {func_name, %{}}
    end
  end

  defp format_excluded?({_, %{platform_id: platform_id}}, %{} = opts) do
    case opts do
      %{exclude: [_ | _] = excluded_formats} ->
        platform_id in excluded_formats

      _ ->
        false
    end
  end

  defmacro __using__(_opts \\ []) do
    compiled_at = :os.system_time(:nanosecond)

    quote bind_quoted: [caller: Macro.escape(__CALLER__), compiled_at: compiled_at],
          location: :keep do
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
            compiled_at: compiled_at,
            engine: layout_params.eex_engine,
            file: __ENV__.file,
            render_function: {render_func, 1},
            source: layout_params.template,
            persist_class_tree: false,
            tag_handler: layout_params.tag_handler
          ]

          LiveViewNative.Templates.compile_class_tree(
            layout_params.template,
            layout_params.platform_id,
            eex_opts
          )

          expr =
            LiveViewNative.Templates.with_stylesheet_wrapper(layout_params.template, render_func)

          EEx.function_from_string(:def, render_func, expr, [:assigns], eex_opts)
        end)
    end
  end
end
