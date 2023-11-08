defmodule LiveViewNative.Templates do
  @moduledoc """
  Provides functionality for preprocessing LiveView Native
  templates.
  """

  def precompile(expr, platform_id, eex_opts) do
    %Macro.Env{function: {template_func, _template_func_arity}, module: template_module} =
      eex_opts[:caller]

    stylesheet = eex_opts[:stylesheet]
    doc = Meeseeks.parse(expr, :xml)
    class_names = extract_all_class_names(doc)
    class_tree_context = class_tree_context(platform_id, template_module)
    class_tree = build_class_tree(class_tree_context, class_names, template_func)
    dump_class_tree_bytecode(class_tree, template_module)

    case stylesheet do
      stylesheet when template_func == :render and not is_nil(stylesheet) ->
        "<compiled-lvn-stylesheet body={__compiled_stylesheet__()}>\n" <> expr <> "\n</compiled-lvn-stylesheet>"

      _ ->
        expr
    end
  end

  ###

  defp build_class_tree(%{} = class_tree_context, class_names, template_func) do
    class_tree_context
    # TODO: Properly handle multiple function clauses
    |> put_in([:class_tree, "#{template_func}"], Enum.uniq(class_names))
    |> persist_to_class_tree()
  end

  defp class_tree_context(platform_id, template_module) do
    filename = class_tree_filename(platform_id, template_module)

    with {:ok, body} <- File.read(filename),
         {:ok, %{} = class_tree} <- Jason.decode(body)
    do
      %{class_tree: class_tree, meta: %{filename: filename}}
    else
      _ ->
        %{class_tree: %{}, meta: %{filename: filename}}
    end
  end

  defp class_tree_filename(platform_id, template_module) do
    # TODO: Infer build path
    "_build/#{Mix.env()}/lib/live_view_native/.lvn/#{platform_id}/#{template_module}.classtree.json"
  end

  defp dump_class_tree_bytecode(class_tree, template_module) do
    class_tree_module = Module.concat([LiveViewNative, Internal, ClassTree, template_module])

    expr =
      Macro.to_string(
        quote do
          defmodule unquote(class_tree_module) do
            def class_tree, do: unquote(class_tree)
          end
        end
      )

    Code.put_compiler_option(:ignore_module_conflict, true)
    Code.compile_string(expr)
  end

  defp extract_all_class_names(doc) do
    Enum.flat_map(doc.nodes, &extract_class_names/1)
  end

  defp extract_class_names({_key, node}) do
    case node do
      %{attributes: [_ | _] = attributes} ->
        attributes
        |> Enum.into(%{})
        |> Map.get("class", "")
        |> String.split(" ")
        |> Enum.filter(&(&1 != ""))

      _ ->
        []
    end
  end

  defp persist_to_class_tree(%{class_tree: %{} = class_tree, meta: %{filename: filename}}) do
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
