defmodule LiveViewNative.Templates do
  @moduledoc """
  Provides functionality for preprocessing LiveView Native
  templates.
  """

  def precompile(expr, platform_id, eex_opts) do
    %Macro.Env{function: {template_func, _template_func_arity}, module: template_module} =
      eex_opts[:caller]
    stylesheet = eex_opts[:stylesheet]
    doc = Meeseeks.parse(expr, :xml)
    class_names = extract_all_class_names(doc)

    case stylesheet do
      nil ->
        expr

      stylesheet ->
        compiled_stylesheet =
          [body: apply(stylesheet, :compile_string, [class_names])]
          |> Phoenix.HTML.attributes_escape()
          |> Phoenix.HTML.safe_to_string()

       "<compiled-lvn-stylesheet #{compiled_stylesheet}>\n" <> expr <> "\n</compiled-lvn-stylesheet>"
    end
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
end
