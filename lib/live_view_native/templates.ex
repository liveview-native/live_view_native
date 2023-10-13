defmodule LiveViewNative.Templates do
  @moduledoc """
  Provides functionality for preprocessing LiveView Native
  templates.
  """

  def precompile(expr, platform_id, eex_opts) do
    %Macro.Env{function: {template_func, _template_func_arity}, module: template_module} = eex_opts[:caller]
    doc = Meeseeks.parse(expr, :xml)
    class_names = extract_all_class_names(doc)
    class_tree_filename = "_build/#{Mix.env()}/lib/live_view_native/.lvn/#{platform_id}/#{template_module}.classtree.json"
    class_tree = build_incremental_class_tree(class_tree_filename, class_names, template_func)
    dump_class_tree_bytecode(class_tree, template_module)

    expr
  end

  ###

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

  defp build_incremental_class_tree(class_tree_filename, class_names, template_func) do
    class_tree_filename
    |> read_or_stub_class_tree()
    |> Map.put("#{template_func}", Enum.uniq(class_names)) # TODO: Properly handle multiple function clauses
    |> persist_to_class_tree(class_tree_filename)
  end

  defp read_or_stub_class_tree(class_tree_filename) do
    with {:ok, body} <- File.read(class_tree_filename),
         {:ok, %{} = class_tree} <- Jason.decode(body) do
      class_tree
    else
      _ ->
        %{}
    end
  end

  defp persist_to_class_tree(class_tree, class_tree_filename) do
    with {:ok, encoded_class_tree} <- Jason.encode(class_tree),
         dirname <- Path.dirname(class_tree_filename),
         :ok <- File.mkdir_p(dirname),
         :ok <- File.touch(class_tree_filename),
         :ok <- File.write(class_tree_filename, encoded_class_tree)
    do
      class_tree
    else
      error ->
        raise "TODO: Handle error #{error}"
    end
  end

  defp dump_class_tree_bytecode(class_tree, template_module) do
    class_tree_module = Module.concat([LiveViewNative, Internal, ClassTree, template_module])
    expr = Macro.to_string(quote do
      defmodule unquote(class_tree_module) do
        def class_tree, do: unquote(class_tree)
      end
    end)

    Code.put_compiler_option(:ignore_module_conflict, true)
    Code.compile_string(expr)
  end
end
