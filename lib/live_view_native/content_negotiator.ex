defmodule LiveViewNative.ContentNegotiator do
  alias Phoenix.LiveView.Socket
  import Phoenix.LiveView, only: [render_with: 2]
  import LiveViewNative.Utils, only: [get_format: 1]

  def on_mount(:call, _params, _session, %Socket{view: view} = socket) do
    formats =
      view.__native__()[:formats]
      |> Enum.map(&Atom.to_string(&1))

    format = get_format(socket)

    if Enum.member?(formats, format) do
      {
        :cont,
        build_render_with(socket, format),
        layout: build_layout(socket, format)
      }
    else
      {:cont, socket}
    end
  end

  defp build_render_with(%Socket{view: view} = socket, format) do
    component = view.__native__()[:render_with][format]

    render_with(socket, component)
  end

  defp build_layout(%Socket{view: view}, format) do
    case view.__native__()[:layouts] do
      false -> false
      layouts -> layouts[format]
    end
  end
end