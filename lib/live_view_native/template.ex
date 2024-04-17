defmodule LiveViewNative.Template do
  @doc """
  Return all template engines for registered plugins
  """
  def engines() do
    Application.get_env(:live_view_native, :plugins)
    |> Enum.into(%{html: Phoenix.LiveView.Engine}, fn(plugin) ->
      plugin = struct(plugin)
      {plugin.format, plugin.template_engine}
    end)
  end

  def attributes_escape(attrs) when is_list(attrs) do
    {:safe, build_attrs(attrs)}
  end

  def attributes_escape(attrs) do
    {:safe, attrs |> Enum.to_list() |> build_attrs()}
  end

  defp build_attrs([{_, nil} | t]),
    do: build_attrs(t)

  defp build_attrs([{:class, v} | t]),
    do: [" class=\"", class_value(v), ?" | build_attrs(t)]

  defp build_attrs([{:aria, v} | t]) when is_list(v),
    do: nested_attrs(v, " aria", t)

  defp build_attrs([{:data, v} | t]) when is_list(v),
    do: nested_attrs(v, " data", t)

  defp build_attrs([{:phx, v} | t]) when is_list(v),
    do: nested_attrs(v, " phx", t)

  defp build_attrs([{"class", v} | t]),
    do: [" class=\"", class_value(v), ?" | build_attrs(t)]

  defp build_attrs([{"aria", v} | t]) when is_list(v),
    do: nested_attrs(v, " aria", t)

  defp build_attrs([{"data", v} | t]) when is_list(v),
    do: nested_attrs(v, " data", t)

  defp build_attrs([{"phx", v} | t]) when is_list(v),
    do: nested_attrs(v, " phx", t)

  defp build_attrs([{k, v} | t]),
    do: [?\s, key_escape(k), ?=, ?", attr_escape(v), ?" | build_attrs(t)]

  defp build_attrs([]), do: []

  defp nested_attrs([{_, bool_atom} | kv], attr, t) when bool_atom in [true, false, nil],
    do: nested_attrs(kv, attr, t)

  defp nested_attrs([{k, v} | kv], attr, t) when is_list(v),
    do: [nested_attrs(v, "#{attr}-#{key_escape(k)}", []) | nested_attrs(kv, attr, t)]

  defp nested_attrs([{k, v} | kv], attr, t),
    do: [attr, ?-, key_escape(k), ?=, ?", attr_escape(v), ?" | nested_attrs(kv, attr, t)]

  defp nested_attrs([], _attr, t),
    do: build_attrs(t)

  defp nested_attrs(list, attr, t),
    do: [attr, list, t]

  defp class_value(value) when is_list(value) do
    value
    |> list_class_value()
    |> attr_escape()
  end

  defp class_value(value) do
    attr_escape(value)
  end

  defp list_class_value(value) do
    value
    |> Enum.flat_map(fn
      nil -> []
      false -> []
      inner when is_list(inner) -> [list_class_value(inner)]
      other -> [other]
    end)
    |> Enum.join(" ")
  end

  defp key_escape(value) when is_atom(value), do: String.replace(Atom.to_string(value), "_", "-")
  defp key_escape(value), do: attr_escape(value)

  defp attr_escape(attr)
  defp attr_escape({:safe, data}), do: data
  defp attr_escape(nil), do: []
  defp attr_escape(other) when is_binary(other), do: Phoenix.HTML.Engine.html_escape(other)
  defp attr_escape(other), do: LiveViewNative.Template.Safe.to_iodata(other)
end
