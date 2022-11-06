defmodule LiveViewNative.LiveSession do
  @moduledoc """
  Ensures common `assigns` are applied to all LiveViews attaching this hook.
  """
  import Phoenix.LiveView

  def on_mount(:live_view_native, _params, _session, socket) do
    with %{"_platform" => platform_id} <- get_connect_params(socket),
         {platform_struct, platform_meta} <- Map.get(LiveViewNative.platforms(), platform_id)
    do
      {:cont, assign(socket,
        modifiers: struct(platform_meta.modifiers_mod, %{}),
        native_platform: platform_struct,
        native_platform_meta: platform_meta
      )}
    else
      _ ->
        platform_struct = %LiveViewNative.Platforms.Web{}
        platform_meta = LiveViewNativePlatform.Platform.platform_meta(platform_struct)

        {:cont, assign(socket, native_platform: platform_struct, native_platform_meta: platform_meta)}
    end
  end
end
