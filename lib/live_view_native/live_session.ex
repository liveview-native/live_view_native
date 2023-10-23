defmodule LiveViewNative.LiveSession do
  @moduledoc """
  Conducts platform detection on socket connections and applies
  native assigns.
  """
  import Phoenix.LiveView
  import Phoenix.Component, only: [assign: 3]

  alias Phoenix.LiveView.Socket

  def on_mount(:live_view_native, params, _session, %Socket{} = socket) do
    with %{} = connect_params <-
           if(connected?(socket), do: get_connect_params(socket), else: params),
         %LiveViewNativePlatform.Env{} = platform_context <-
           get_platform_context(connect_params) do
      socket =
        socket
        |> assign(:native, platform_context)
        |> assign(:platform_id, platform_context.platform_id)
        |> push_stylesheet_if_present()

      {:cont, socket}
    else
      _result ->
        socket =
          socket
          |> assign(:native, nil)
          |> assign(:platform_id, :html)

        {:cont, socket}
    end
  end

  ###

  defp get_platform_context(%{"_platform" => platform_id} = connect_params) do
    platforms = LiveViewNative.platforms()

    with %LiveViewNativePlatform.Env{platform_config: platform_config} = context <-
           Map.get(platforms, platform_id) do
      platform_metadata = get_platform_metadata(connect_params)
      platform_config = merge_platform_metadata(platform_config, platform_metadata)

      Map.put(context, :platform_config, platform_config)
    end
  end

  defp get_platform_context(_connect_params), do: nil

  defp get_platform_metadata(%{"_platform_meta" => %{} = platform_metadata}),
    do: platform_metadata

  defp get_platform_metadata(_connect_params), do: %{}

  defp merge_platform_metadata(platform_config, platform_metadata) do
    platform_config_keys = Map.keys(platform_config)
    platform_config_string_keys = Enum.map(platform_config_keys, &to_string/1)

    platform_metadata
    |> Map.take(platform_config_string_keys)
    |> Enum.reduce(platform_config, fn {key, value}, acc ->
      Map.put(acc, String.to_existing_atom(key), value)
    end)
  end

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
