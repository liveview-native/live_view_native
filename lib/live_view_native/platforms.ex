defmodule LiveViewNative.Platforms do
  @default_platforms [LiveViewNative.Platforms.Web]

  @env_platforms (
    :live_view_native
    |> Application.get_env(:platforms, [])
    |> Enum.concat(@default_platforms)
    |> Enum.map(fn platform_mod ->
      platform_config = Application.get_env(:live_view_native, platform_mod)
      platform_params = if is_list(platform_config), do: Enum.into(platform_config, %{}), else: %{}
      platform_struct = struct!(platform_mod, platform_params)
      platform_meta = LiveViewNativePlatform.Platform.platform_meta(platform_struct)
      platform_id = platform_meta.platform_id

      {"#{platform_id}", {platform_struct, platform_meta}}
    end)
    |> Enum.into(%{})
  )

  def env_platforms, do: @env_platforms
end
