defmodule LiveViewNative.Templates do
  @moduledoc """
  Provides functionality for preprocessing LiveView Native
  templates.
  """

  def precompile(expr, platform_id, eex_opts) do
    with_stylesheet_wrapper = Keyword.get(eex_opts, :with_stylesheet_wrapper, true)

    case compile_class_tree(expr, platform_id, eex_opts) do
      {:ok, _class_tree} when with_stylesheet_wrapper ->
        with_stylesheet_wrapper(expr)

      _ ->
        expr
    end
  end

  def compile_class_tree(expr, platform_id, eex_opts) do
    caller = eex_opts[:caller]
    %Macro.Env{module: template_module} = caller

    with doc <- Floki.parse_document!(expr),
         class_names <- extract_all_class_names(doc),
         %{} = class_tree_context <- class_tree_context(platform_id, template_module, eex_opts),
         %{} = class_tree <- build_class_tree(class_tree_context, class_names, eex_opts) do
      if eex_opts[:persist_class_tree], do: persist_class_tree_map(%{default: class_tree}, caller)

      {:ok, class_tree}
    else
      _ ->
        {:ok, :skipped}
    end
  end

  def persist_class_tree_map(class_tree_map, caller) do
    dump_class_tree_bytecode(class_tree_map, caller)
  end

  def with_stylesheet_wrapper(expr, stylesheet_key \\ :default) do
    "<compiled-lvn-stylesheet body={__compiled_stylesheet__(:#{stylesheet_key})}>#{expr}</compiled-lvn-stylesheet>"
  end

  ###

  defp build_class_tree(%{} = class_tree_context, class_names, eex_opts) do
    {func_name, func_arity} = eex_opts[:render_function] || eex_opts[:caller].function
    function_tag = "#{func_name}/#{func_arity}"
    incremental_class_names = Map.get(class_tree_context, :class_names, [])
    incremental_mappings = Map.get(class_tree_context, :class_mappings, %{})
    class_names_for_function = Map.get(incremental_mappings, function_tag, []) ++ class_names
    class_mappings = Enum.uniq(class_names_for_function)

    class_names =
      class_mappings
      |> Enum.concat(incremental_class_names)
      |> Enum.uniq()

    class_tree_context
    |> Map.put(:class_names, class_names)
    |> put_in([:class_mappings, function_tag], class_mappings)
    |> persist_to_class_tree()
  end

  defp class_tree_context(platform_id, template_module, eex_opts) do
    compiled_at = eex_opts[:compiled_at]
    filename = class_tree_filename(platform_id, template_module)

    with {:ok, body} <- File.read(filename),
         {:ok, %{} = class_tree} <- Jason.decode(body) do
      class_mappings = class_tree["class_mappings"] || %{}
      class_names = Map.values(class_mappings)

      %{
        class_mappings: class_mappings,
        class_names: List.flatten(class_names),
        meta: %{
          compiled_at: compiled_at,
          filename: get_in(class_tree, ["meta", "filename"]) || filename
        }
      }
    else
      _ ->
        %{
          class_mappings: %{},
          class_names: [],
          meta: %{
            compiled_at: compiled_at,
            filename: filename
          }
        }
    end
  end

  defp class_tree_filename(platform_id, template_module) do
    "#{:code.lib_dir(:live_view_native)}/.lvn/#{platform_id}/#{template_module}.classtree.json"
  end

  defp dump_class_tree_bytecode(class_tree_map, caller) do
    generate_class_tree_module(class_tree_map, caller)
  end

  defp generate_class_tree_module(class_tree_map, caller) do
    %Macro.Env{module: template_module, requires: requires} = caller
    module_name = generate_class_tree_module_name(template_module)
    branches = get_class_tree_branches(requires)

    ast = quote location: :keep do
      def class_tree(stylesheet_key) do
        %{
          branches: unquote(branches),
          contents: unquote(Macro.escape(class_tree_map))[stylesheet_key],
          expanded_branches: [unquote(module_name)]
        } ||
          %{
            branches: [],
            contents: %{},
            expanded_branches: [unquote(module_name)]
          }
      end
    end

    Module.create(module_name, ast, Macro.Env.location(__ENV__))

    :ok
  end

  defp generate_class_tree_module_name(module) do
    Module.concat([LiveViewNative, Internal, ClassTree, module])
  end

  defp get_class_tree_branches(requires) do
    requires
    |> Enum.filter(&module_has_stylesheet?/1)
    |> Enum.map(&generate_class_tree_module_name/1)
  end

  defp extract_all_class_names(doc) do
    doc
    |> Floki.traverse_and_update(%{}, &extract_class_names/2)
    |> elem(1)
    |> Map.keys()
  end

  defp extract_class_names(node, acc) do
    new_acc =
      node
      |> Floki.attribute("class")
      |> split_class_names()
      |> Enum.reduce(acc, fn(class_name, acc) ->
        Map.put(acc, class_name, true)
      end)

      {nil, new_acc}
  end

  defp split_class_names([]), do: []
  defp split_class_names([class_names | _tail]) do
    String.split(class_names, " ", trim: true)
  end

  defp module_has_stylesheet?(module) do
    :functions
    |> module.__info__()
    |> Enum.member?({:__compiled_stylesheet__, 1})
  end

  defp persist_to_class_tree(%{meta: %{filename: filename}} = class_tree) do
    with {:ok, encoded_tree} <- Jason.encode(class_tree),
         dirname <- Path.dirname(filename),
         :ok <- File.mkdir_p(dirname),
         :ok <- File.touch(filename),
         :ok <- File.write(filename, encoded_tree) do
      class_tree
    else
      error ->
        raise "TODO: Handle error #{error}"
    end
  end
end
