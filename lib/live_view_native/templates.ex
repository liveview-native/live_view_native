defmodule LiveViewNative.Templates do
  @moduledoc """
  Provides functionality for preprocessing LiveView Native
  templates.
  """

  def precompile(expr, platform_id, eex_opts) do
    case compile_class_tree(expr, platform_id, eex_opts) do
      :ok ->
        with_stylesheet_wrapper(expr)

      _ ->
        expr
    end
  end

  def compile_class_tree(expr, platform_id, eex_opts) do
    %Macro.Env{module: template_module} = eex_opts[:caller]

    with %Meeseeks.Document{} = doc <- Meeseeks.parse(expr, :html),
         [_ | _] = class_names <- extract_all_class_names(doc),
         %{} = class_tree_context <- class_tree_context(platform_id, template_module),
         %{} = class_tree <- build_class_tree(class_tree_context, class_names, eex_opts)
    do
      dump_class_tree_bytecode(class_tree, template_module)
    else
      _fallback ->
        dump_class_tree_bytecode(%{}, template_module)

        :skipped
    end
  end

  def with_stylesheet_wrapper(expr) do
    "<compiled-lvn-stylesheet body={__compiled_stylesheet__()}>\n" <> expr <> "\n</compiled-lvn-stylesheet>"
  end

  ###

  defp build_class_tree(%{} = class_tree_context, class_names, eex_opts) do
    {func_name, func_arity} = eex_opts[:render_function] || eex_opts[:caller].function

    class_tree_context
    |> put_in([:class_tree, "#{func_name}/#{func_arity}"], Enum.uniq(class_names))
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
    "#{:code.lib_dir(:live_view_native)}/.lvn/#{platform_id}/#{template_module}.classtree.json"
  end

  defp dump_class_tree_bytecode(class_tree, template_module) do
    class_tree
    |> generate_class_tree_module(template_module)
    |> Code.compile_string()

    :ok
  end

  defp generate_class_tree_module(class_tree, template_module) do
    module_name = Module.concat([LiveViewNative, Internal, ClassTree, template_module])

    Macro.to_string(
      quote location: :keep do
        defmodule unquote(module_name) do
          def class_tree, do: unquote(class_tree)
        end
      end
    )
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
