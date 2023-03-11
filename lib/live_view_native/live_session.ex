defmodule LiveViewNative.LiveSession do
  @moduledoc """
  Ensures common `assigns` are applied to all LiveViews attaching this hook.
  """
  import Phoenix.LiveView
  import Phoenix.Component, only: [assign: 3]

  def on_mount(:live_view_native, _params, _session, socket) do
    with %{"_platform" => platform_id} <- get_connect_params(socket),
         platforms <- LiveViewNative.platforms(),
         %LiveViewNativePlatform.Context{} = platform_context <- Map.get(platforms, platform_id) do
      {:cont, assign(socket, :native, platform_context)}
    else
      _result ->
        platform_config = %LiveViewNative.Platforms.Web{}
        platform_context = LiveViewNativePlatform.context(platform_config)

        {:cont, assign(socket, :native, platform_context)}
    end
  end
end
