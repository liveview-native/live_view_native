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
          |> put_native_layout()

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
      app_build: lvn_params["app_build"],
      app_version: lvn_params["app_version"],
      bundle_id: lvn_params["bundle_id"],
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

  defp put_native_layout(%Socket{} = socket) do
    with %Socket{assigns: %{format: format}, private: private, view: view} when not is_nil(view) <-
           socket,
         %{layout: {layout_mod, layout_name}} <- apply(view, :__live__, []) do
      %Socket{
        socket
        | private: Map.put(private, :live_layout, {layout_mod, "#{layout_name}_#{format}"})
      }
    else
      _ ->
        socket
    end
  end
end
