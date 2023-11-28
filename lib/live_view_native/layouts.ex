defmodule LiveViewNative.Layouts do
  def extract_layouts({:embed_templates, _meta, [template | _args]}, %{} = opts) do
    base_path = Path.join([opts.dirname, Path.dirname(template)])
    opts = Map.put(opts, :base_path, base_path)

    base_path
    |> File.ls!()
    |> Enum.map(&extract_layout(&1, opts))
    |> Enum.filter(& &1)
  end

  def extract_layouts({_func, _meta, [_ | _] = nodes}, %{} = opts),
    do: Enum.map(nodes, &extract_layouts(&1, opts))

  def extract_layouts([do: {:__block__, [], args}], %{} = opts), do: extract_layouts(args, opts)

  def extract_layouts([_ | _] = nodes, %{} = opts),
    do: Enum.map(nodes, &extract_layouts(&1, opts))

  def extract_layouts(_node, _opts), do: []

  def extract_layout(filename, %{platforms: platforms} = opts) do
    template_path = Path.join(opts.base_path, filename)

    platforms
    |> Enum.find(&matches_template?(&1, filename))
    |> compile_layout(template_path, opts)
  end

  def compile_layout({format, platform}, template_path, _opts) when format != "html" do
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

  defmacro __using__(_opts \\ []) do
    quote bind_quoted: [caller: Macro.escape(__CALLER__)], location: :keep do
      use LiveViewNative.Extensions, role: :layouts

      layout_templates =
        __ENV__.file
        |> File.read!()
        |> Code.string_to_quoted!()
        |> LiveViewNative.Layouts.extract_layouts(%{
          caller: caller,
          dirname: Path.dirname(__ENV__.file),
          platforms: LiveViewNative.platforms()
        })
        |> List.flatten()
        |> Enum.map(fn %{} = layout_params ->
          @external_resource layout_params.template_path

          eex_opts = [
            caller: caller,
            engine: layout_params.eex_engine,
            file: __ENV__.file,
            render_function: {layout_params.render_function, 1},
            source: layout_params.template,
            tag_handler: layout_params.tag_handler
          ]
          LiveViewNative.Templates.compile_class_tree(layout_params.template, layout_params.platform_id, eex_opts)

          EEx.function_from_string(
            :def,
            layout_params.render_function,
            LiveViewNative.Templates.with_stylesheet_wrapper(layout_params.template),
            [:assigns],
            eex_opts
          )
        end)
    end
  end
end
