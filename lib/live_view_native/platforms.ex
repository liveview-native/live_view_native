defmodule LiveViewNative.Platforms do
  @moduledoc false

  @type env_platforms_map() :: %{
          String.t() => %LiveViewNativePlatform.Env{}
        }

  @default_platforms [LiveViewNative.Platforms.Web]

  @env_platforms :live_view_native
                 |> Application.compile_env(:plugins, [])
                 |> Enum.flat_map(fn plugin_mod -> apply(plugin_mod, :platforms, []) end)
                 |> Enum.concat(@default_platforms)
                 |> Enum.uniq()
                 |> Enum.map(fn platform_mod ->
                   platform_config = Application.compile_env(:live_view_native, platform_mod, [])
                   platform_params = Enum.into(platform_config, %{})

                   {platform_mod, platform_params}
                 end)
                 |> Enum.into(%{})

  @doc """
  Provides configuration constants about all platforms supported by an
  application that uses LiveView Native. This function is a dependency
  of various LiveView Native systems, such as `LiveViewNative.LiveSession`
  which is responsible for determining which platform (web, iOS, etc.) a
  session originates from.
  """
  @spec env_platforms() :: env_platforms_map()
  def env_platforms do
    @env_platforms
    |> Enum.map(&expand_env_platform/1)
    |> Enum.into(%{})
  end

  def env_platform(platform_id) do
    env_platforms()
    |> Map.get(platform_id)
  end

  ###

  defp expand_env_platform({platform_mod, %{} = platform_params}) do
    platform_config = struct!(platform_mod, platform_params)

    platform_context =
      platform_config
      |> LiveViewNativePlatform.Kit.compile()
      |> Map.put(:platform_config, platform_config)

    {"#{platform_context.platform_id}", platform_context}
  end
end
