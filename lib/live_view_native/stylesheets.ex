defmodule LiveViewNative.Stylesheets do
  @moduledoc """
  Provides runtime support for LiveView Native's stylesheet system.
  """

  @doc """
  Returns a map containing all class names for templates within the given
  LiveView, LiveComponent or Phoenix Components module. `tree_key` can be
  passed for retrieving a specific class tree; this should only used for
  modules which have multiple tree shaking passes applied at compile-time
  (for example, layout modules), otherwise `:default` should be passed.
  """
  def get_class_tree(class_tree_module, tree_key \\ :default, opts \\ []) do
    result = apply(class_tree_module, :class_tree, [tree_key])

    if opts[:expand] do
      %{result | class_names: expand_class_names(result, [class_tree_module])}
    else
      result
    end
  end

  @doc """
  Returns the internal class tree module for the given LiveView, LiveComponent
  or Phoenix Components module.
  """
  def get_class_tree_module(module) do
    Module.safe_concat([LiveViewNative, Internal, ClassTree, module])
  end

  @doc """
  Compiles all stylesheets for the given class tree and returns them
  as a single map.
  """
  def reduce_stylesheets(class_tree, stylesheet_modules) do
    class_names = get_class_names(class_tree)

    stylesheet_modules
    |> Enum.reduce(%{}, fn stylesheet_module, acc ->
      compiled_stylesheet = apply(stylesheet_module, :compile_ast, [class_names])

      Map.merge(acc, compiled_stylesheet)
    end)
  end

  ###

  defp expand_class_names(%{branches: branches, class_names: class_names}, ignored_modules) do
    branches
    |> Enum.reject(&(&1 in ignored_modules))
    |> Enum.reduce(class_names, fn branch, acc ->
      branch_class_names =
        branch
        |> get_class_tree(:default)
        |> expand_class_names(ignored_modules ++ [branch])

      Map.merge(acc, branch_class_names)
    end)
  end

  defp get_class_names(%{class_names: class_names}) do
    class_names
    |> Map.values()
    |> List.flatten()
  end
end