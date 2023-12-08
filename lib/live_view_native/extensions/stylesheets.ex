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
        stylesheet_modules = __stylesheet_modules__()

        unquote(module)
        |> LiveViewNative.Stylesheets.get_class_tree_module()
        |> LiveViewNative.Stylesheets.get_class_tree(stylesheet_key)
        |> LiveViewNative.Stylesheets.reduce_stylesheets(stylesheet_modules)
        |> inspect(limit: :infinity, charlists: :as_list, printable_limit: :infinity)
      end

      def __stylesheet_modules__, do: []
    end
  end
end
