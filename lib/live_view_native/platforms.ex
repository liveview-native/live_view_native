defmodule LiveViewNative.Platforms do
  @moduledoc false

  @default_platforms [LiveViewNative.Platforms.HTML]

  @platforms_table :live_view_native_platforms

  @doc """
  Provides configuration constants about all platforms supported by an
  application that uses LiveView Native. This function is a dependency
  of various LiveView Native systems, such as `LiveViewNative.LiveSession`
  which is responsible for determining which platform (HTML, SwiftUI, etc.) a
  session originates from.
  """
  def env_platforms do
    case fetch_platforms() do
      :none -> 
        :live_view_native
        |> Application.get_env(:plugins, [])
        |> Enum.flat_map(fn plugin_mod -> apply(plugin_mod, :platforms, []) end)
        |> Enum.concat(@default_platforms)
        |> Enum.uniq()
        |> Enum.map(fn platform_mod ->
          platform_config = Application.get_env(:live_view_native, platform_mod, [])
          platform_params = Enum.into(platform_config, %{})

          {platform_mod, platform_params}
        end)
        |> Enum.into(%{})
        |> Enum.map(&expand_env_platform/1)
        |> Enum.into(%{})
        |> store_platforms()
      platforms -> platforms
    end
  end

  def env_platform(platform_id) do
    env_platforms()
    |> Map.get(platform_id)
  end

  ###

  defp fetch_platforms do
    case :ets.info(@platforms_table) do
      :undefined -> :ets.new(@platforms_table, [:named_table, :public])
      _ -> nil
    end

    case :ets.lookup(@platforms_table, :all) do
      [all: platforms] -> platforms
      _ -> :none
    end
  end

  defp store_platforms(platforms) do
    :ets.insert(:live_view_native_platforms, {:all, platforms})
    platforms
  end

  defp expand_env_platform({platform_mod, %{} = platform_params}) do
    platform_config = struct!(platform_mod, platform_params)

    platform_context =
      platform_config
      |> LiveViewNativePlatform.Kit.compile()
      |> Map.put(:platform_config, platform_config)

    {"#{platform_context.platform_id}", platform_context}
  end
end
