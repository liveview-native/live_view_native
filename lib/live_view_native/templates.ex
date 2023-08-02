defmodule LiveViewNative.Templates do
  def precompile(expr) do
    doc = Meeseeks.parse(expr, :xml)
    replacements = Enum.flat_map(doc.nodes, &transform_node/1)

    transformed_expr =
      replacements
      |> Enum.reduce(expr, fn {from, to}, acc ->
        String.replace(acc, from, to)
      end)

    transformed_expr
  end

  ###

  defp transform_node({key, node}) do
    case node do
      %{attributes: [_ | _] = attributes} = node ->
        attributes
        |> Enum.map(&transform_attribute/1)
        |> Enum.filter(&(&1 != nil))

      _ ->
        []
    end
  end

  defp transform_attribute({key, value}) do
    case key do
      "modclass" ->
        {"modclass=\"#{value}\"", transform_modclass(value)}

      _ ->
        nil
    end
  end

  defp transform_modclass(modclass) do
    modifiers =
      modclass
      |> String.split(" ")
      |> Enum.map(fn classname -> "modclass(\"#{classname}\")" end)
      |> Enum.join("|> ")

    "modifiers={@native |> #{modifiers}}"
  end
end
