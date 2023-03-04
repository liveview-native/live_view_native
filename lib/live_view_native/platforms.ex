defmodule LiveViewNative.Platforms do
  @moduledoc """
  Provides configuration constants about all platforms supported by an
  application that uses LiveView Native. This module is a dependency
  of various LiveView Native systems, such as `LiveViewNative.LiveSession`
  which is responsible for determining which platform (web, iOS, etc.) a
  session originates from.
  """
  @default_platforms [LiveViewNative.Platforms.Web]

  @env_platforms :live_view_native
                 |> Application.compile_env(:platforms, [])
                 |> Enum.concat(@default_platforms)
                 |> Enum.map(fn platform_mod ->
                   platform_config = Application.compile_env(:live_view_native, platform_mod)

                   platform_params =
                     if is_list(platform_config), do: Enum.into(platform_config, %{}), else: %{}

                   platform_config = struct!(platform_mod, platform_params)
                   platform_context = LiveViewNativePlatform.context(platform_config)
                   platform_id = platform_context.platform_id

                   {"#{platform_id}",
                    Map.put(platform_context, :platform_config, platform_config)}
                 end)
                 |> Enum.into(%{})

  def env_platforms, do: @env_platforms
end
