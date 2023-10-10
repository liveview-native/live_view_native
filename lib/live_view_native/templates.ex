defmodule LiveViewNative.Templates do
  @moduledoc """
  Provides functionality for preprocessing LiveView Native
  templates.
  """

  def precompile(expr, platform_id) do
    doc = Meeseeks.parse(expr, :xml)
    class_names = Enum.flat_map(doc.nodes, &extract_class_names/1) |> IO.inspect()
    append_class_names_to_partial_stylesheet(class_names, platform_id)

    expr
  end

  ###

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

  # TODO: Reuse IO device
  defp append_class_names_to_partial_stylesheet([], _platform_id), do: :ok

  defp append_class_names_to_partial_stylesheet(class_names, platform_id) do
    {:ok, file} = File.open("_build/lvn.styleclasses.#{platform_id}.tmp", [:write, :append])

    IO.write(file, Enum.join(class_names, "\n") <> "\n")
    File.close(file)
  end
end
