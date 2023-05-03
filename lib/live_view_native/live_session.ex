defmodule LiveViewNative.LiveSession do
  @moduledoc """
  Ensures common `assigns` are applied to all LiveViews attaching this hook.
  """
  import Phoenix.LiveView
  import Phoenix.Component, only: [assign: 3]

  def on_mount(:live_view_native, _params, _session, socket) do
    with %{} = connect_params <- get_connect_params(socket),
         %LiveViewNativePlatform.Context{} = platform_context <- get_platform_context(connect_params)
    do
      socket =
        socket
        |> assign(:native, platform_context)
        |> assign(:platform_id, platform_context.platform_id)

      {:cont, socket}
    else
      _result ->
        platform_config = %LiveViewNative.Platforms.Web{}
        platform_context = LiveViewNativePlatform.context(platform_config)
        socket =
          socket
          |> assign(:native, platform_context)
          |> assign(:platform_id, platform_context.platform_id)

        {:cont, socket}
    end
  end

  ###

  defp get_platform_context(%{"_platform" => platform_id} = connect_params) do
    platforms = LiveViewNative.platforms()

    with %LiveViewNativePlatform.Context{platform_config: platform_config} = context <- Map.get(platforms, platform_id) do
      platform_metadata = get_platform_metadata(connect_params)
      platform_config = merge_platform_metadata(platform_config, platform_metadata)

      Map.put(context, :platform_config, platform_config)
    end
  end

  defp get_platform_context(_connect_params), do: nil

  defp get_platform_metadata(%{"_platform_meta" => %{} = platform_metadata}), do: platform_metadata
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
end
