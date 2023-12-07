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
    %Macro.Env{module: template_module} = eex_opts[:caller]

    with %Meeseeks.Document{} = doc <- Meeseeks.parse(expr, :html),
         [_ | _] = class_names <- extract_all_class_names(doc),
         %{} = class_tree_context <- class_tree_context(platform_id, template_module),
         %{} = class_tree <- build_class_tree(class_tree_context, class_names, eex_opts)
    do
      if eex_opts[:persist_class_tree], do: persist_class_tree_map(%{default: class_tree}, template_module)

      {:ok, class_tree}
    else
      _ ->
        {:ok, :skipped}
    end
  end

  def persist_class_tree_map(class_tree_map, template_module) do
    dump_class_tree_bytecode(class_tree_map, template_module)
  end

  def with_stylesheet_wrapper(expr, stylesheet_key \\ :default) do
    """
    <%= case __compiled_stylesheet__(:#{stylesheet_key}) do %>
      <% "%{}" -> %>
        #{expr}

      <% stylesheet -> %>
        <compiled-lvn-stylesheet body={stylesheet}>#{expr}</compiled-lvn-stylesheet>
    <% end %>
    """
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

  defp dump_class_tree_bytecode(class_tree_map, template_module) do
    class_tree_map
    |> generate_class_tree_module(template_module)
    |> Code.compile_string()

    :ok
  end

  defp generate_class_tree_module(class_tree_map, template_module) do
    module_name = Module.concat([LiveViewNative, Internal, ClassTree, template_module])

    Macro.to_string(
      quote location: :keep do
        defmodule unquote(module_name) do
          def class_tree(stylesheet_key), do: unquote(class_tree_map)[stylesheet_key] || %{}
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
