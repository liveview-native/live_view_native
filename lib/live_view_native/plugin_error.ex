defmodule LiveViewNative.PluginError do
  alias LiveViewNative.PluginError

  import Mix.LiveViewNative.CodeGen.Patch, only: [
    doc_ref: 0
  ]

  defexception [:message]

  defmacrop compile_string(string),
    do: EEx.compile_string(string)

  @impl true
  def exception(format) do
    formats = LiveViewNative.plugins() |> Map.keys()

    message = """

      Attempted to fetch plugin <%= inspect format %> <%= if Enum.empty?(formats) do %> but there are no plugins configured for LiveView Native.
      <%= doc_ref() |> String.trim_trailing() %><% else %>but no matching plugin of that format was availble.
      You may have misspelled the format or don't yet have it installed.
      Here are the formats LiveView Native is configured for:<%= for format <- formats do %>
          * <%= format %><% end %><% end %>
    """
    |> compile_string()

    %PluginError{message: message}
  end
end
