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
    expand = Keyword.get(opts, :expand, true)

    case apply(class_tree_module, :class_tree, [tree_key]) do
      result when expand ->
        expand_class_tree(result)

      result ->
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
  def reduce_stylesheets(%{contents: %{class_names: class_names}}, stylesheet_modules) do
    stylesheet_modules
    |> Enum.reduce(%{}, fn stylesheet_module, acc ->
      compiled_stylesheet = apply(stylesheet_module, :compile_ast, [class_names])

      Map.merge(acc, compiled_stylesheet)
    end)
  end

  ###

  defp expand_class_tree(%{branches: branches} = class_tree) do
    branches
    |> Enum.reject(&(&1 in class_tree.expanded_branches))
    |> Enum.reduce(class_tree, fn branch, %{contents: %{} = acc_contents} = acc ->
      branch_class_tree =
        branch
        |> get_class_tree(:default)
        |> expand_class_tree()

      acc_class_names = acc_contents.class_names ++ branch_class_tree.contents.class_names

      acc_class_mappings =
        Map.merge(acc_contents.class_mappings, branch_class_tree.contents.class_mappings)

      %{
        acc
        | branches: acc.branches,
          contents: %{
            acc_contents
            | class_names: acc_class_names,
              class_mappings: acc_class_mappings
          },
          expanded_branches: class_tree.expanded_branches ++ [branch]
      }
    end)
  end
end
