defmodule LiveViewNative.LiveSession do
  @moduledoc """
  Conducts platform detection on socket connections and applies
  native assigns.
  """
  import Phoenix.LiveView
  import Phoenix.Component, only: [assign: 2]

  alias LiveViewNative.Assigns
  alias Phoenix.LiveView.Socket

  def on_mount(:live_view_native, params, _session, %Socket{} = socket) do
    case get_native_assigns(socket, params) do
      %Assigns{} = native_assigns ->
        assigns = Map.from_struct(native_assigns)
        socket =
          socket
          |> assign(assigns)
          |> push_stylesheet_if_present()

        {:cont, socket}

      _ ->
        {:cont, socket}
    end
  end

  ###

  defp get_native_assigns(socket, params) do
    if connected?(socket) do
      socket
      |> get_connect_params()
      |> expand_lvn_params()
    else
      expand_lvn_params(params)
    end
  end

  defp expand_lvn_params(%{"_lvn" => %{} = lvn_params}) do
    %Assigns{
      native: get_platform_env(lvn_params),
      os: lvn_params["os"],
      os_version: lvn_params["os_version"]
    }
    |> put_format(lvn_params)
    |> put_target(lvn_params)
  end

  defp expand_lvn_params(_), do: nil

  defp get_platform_env(%{"format" => format}) do
    platforms = LiveViewNative.platforms()

    case Map.get(platforms, format) do
      %LiveViewNativePlatform.Env{} = env ->
        env

      _ ->
        nil
    end
  end

  defp get_platform_env(_lvn_params), do: nil

  defp put_format(%Assigns{} = assigns, %{"format" => format}) do
    %Assigns{assigns | format: String.to_existing_atom(format)}
  end

  defp put_format(assigns, _lvn_params), do: assigns

  defp put_target(%Assigns{} = assigns, %{"target" => target}) do
    %Assigns{assigns | target: String.to_existing_atom(target)}
  end

  defp put_target(assigns, _lvn_params), do: assigns

  defp push_stylesheet_if_present(%Socket{view: view_module} = socket)
       when not is_nil(view_module) do
    case apply(view_module, :__compiled_stylesheet__, []) do
      nil ->
        socket

      stylesheet ->
        push_event(socket, "_ingest_stylesheet", %{stylesheet: stylesheet})
    end
  end

  defp push_stylesheet_if_present(socket), do: socket
end
