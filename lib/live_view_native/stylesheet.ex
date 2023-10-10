defmodule LiveViewNative.Stylesheet do
  def compile(platform_id) do
    class_names = all_class_names(platform_id)
    stylesheet = compile_stylesheet(platform_id)

    class_names
    |> Enum.reduce(%{}, fn class_name, %{} = modified_ast ->
      Map.put(modified_ast, class_name, generate_style(class_name, stylesheet))
    end)
  end

  ###

  defp all_class_names(platform_id) do
    class_names = File.read!("_build/lvn.styleclasses.#{platform_id}.tmp")

    class_names
    |> String.split("\n")
    |> Enum.uniq()
    |> Enum.filter(&(&1 != ""))
  end

  defp compile_stylesheet(platform_id) do
    file = File.read!("native/#{platform_id}/stylesheet.exs")

    file
    |> SwiftClass.parse_class_block()
    |> elem(1)
  end

  defp generate_style(class_name, [_ | _] = stylesheet) do
    stylesheet
    |> Enum.find(&(style_matches_class?(&1, class_name)))
  end

  defp style_matches_class?({{:<>, _meta, [prefix, _args]}, _body}, class_name) do
    String.starts_with?(class_name, prefix)
  end

  defp style_matches_class?({style_class, _body}, class_name) do
    style_class == class_name
  end

  defp style_matches_class?(_style, _class_name), do: false
end
