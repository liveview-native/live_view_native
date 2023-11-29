defmodule LiveViewNative.Extensions.Stylesheets do
  @moduledoc false

  @doc """
  This macro adds support for LiveView Native's stylesheet DSL which
  enables configuration of visual properties for native platforms
  (i.e. SwiftUI modifiers, Jetpack Compose themes, etc.)
  """
  defmacro __using__(opts \\ []) do
    module = opts[:module]

    quote bind_quoted: [module: module], location: :keep do
      def __compiled_stylesheet__(stylesheet_key) do
        class_tree_module =
          Module.safe_concat([LiveViewNative, Internal, ClassTree, unquote(module)])

        class_tree = apply(class_tree_module, :class_tree, [stylesheet_key])

        class_names =
          class_tree
          |> Map.values()
          |> List.flatten()

        __stylesheet_modules__()
        |> Enum.reduce(%{}, fn stylesheet_module, acc ->
          compiled_stylesheet = apply(stylesheet_module, :compile_ast, [class_names])

          Map.merge(acc, compiled_stylesheet)
        end)
        |> inspect(limit: :infinity, charlists: :as_list, printable_limit: :infinity)
      end

      def __stylesheet_modules__, do: []
    end
  end
end
