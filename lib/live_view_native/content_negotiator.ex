defmodule LiveViewNative.ContentNegotiator do
  @moduledoc """
  The callback module for delegating LiveView Native format
  requests to the correct render component
  """
  alias Phoenix.LiveView.Socket
  import Phoenix.LiveView, only: [
    connected?: 1,
    get_connect_params: 1,
    render_with: 2,
  ]
  import LiveViewNative.Utils, only: [get_format: 1]
  import Phoenix.Component, only: [assign: 3]

  @doc false

  def on_mount(:call, params, _session, %Socket{view: view} = socket) do
    socket = if connected?(socket) do
      params = get_connect_params(socket)
      assign_params(socket, params)
    else
      assign_params(socket, params)
    end

    formats =
      view.__native__()[:formats]
      |> Enum.map(&Atom.to_string(&1))

    format = get_format(socket.assigns)

    result = if Enum.member?(formats, format) do
      {
        :cont,
        build_render_with(socket, format),
        layout: build_layout(socket, format)
      }
    else
      {:cont, socket}
    end

    result
  end

  defp assign_params(socket, %{"_format" => format} = params) do
    params = Map.delete(params, "_format")

    socket
    |> assign(:_format, format)
    |> assign_params(params)
  end

  defp assign_params(%{assigns: %{:_format => format}} = socket, %{"_interface" => interface} = params) do
    params = Map.delete(params, "_interface")

    interface = normalize_interface(interface, format)

    socket
    |> assign(:_interface, interface)
    |> assign_params(params)
  end

  defp assign_params(socket, _params),
    do: socket

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

  defp normalize_interface(interface, format) do
    plugin =
      format
      |> LiveViewNative.fetch_plugin!()
      |> Map.get(:__struct__)

    interface
    |> normalize_os_version(plugin)
    |> normalize_app_version(plugin)
  end

  defp normalize_os_version(%{"os_version" => os_version} = interface, plugin) when not is_nil(os_version) do
    if function_exported?(plugin, :normalize_os_version, 1) do
      os_version = plugin.normalize_os_version(os_version)
      Map.put(interface, "os_version", os_version)
    else
      interface
    end
  end

  defp normalize_os_version(interface, _plugin),
    do: interface

  defp normalize_app_version(%{"app_version" => app_version} = interface, plugin) when not is_nil(app_version) do
    if function_exported?(plugin, :normalize_app_version, 1) do
      app_version = plugin.normalize_app_version(app_version)
      Map.put(interface, "app_version", app_version)
    else
      interface
    end
  end

  defp normalize_app_version(interface, _plugin),
    do: interface
end
