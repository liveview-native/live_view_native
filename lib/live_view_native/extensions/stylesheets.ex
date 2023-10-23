defmodule LiveViewNative.Extensions.Stylesheets do
  @moduledoc false

  @doc """
  This macro adds support for LiveView Native's stylesheet DSL which
  enables configuration of visual properties for native platforms
  (i.e. SwiftUI modifiers, Jetpack Compose themes, etc.)
  """
  defmacro __using__(opts \\ []) do
    module = opts[:module]
    stylesheet = opts[:stylesheet]

    quote bind_quoted: [module: module, stylesheet: stylesheet] do
      if stylesheet do
        def __compiled_stylesheet__ do
          class_tree_module =
            Module.safe_concat([LiveViewNative, Internal, ClassTree, unquote(module)])

          class_tree = apply(class_tree_module, :class_tree, [])

          class_names =
            class_tree
            |> Map.values()
            |> List.flatten()

          apply(unquote(stylesheet), :compile_string, [class_names])
        end
      else
        def __compiled_stylesheet__, do: nil
      end
    end
  end
end
