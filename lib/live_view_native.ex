defmodule LiveViewNative do
  @moduledoc """
  A module providing supporting functions for LiveView Native.
  """
  import LiveViewNative.Platforms, only: [env_platform: 1, env_platforms: 0]

  @doc """
  Returns an environment struct for a LiveView Native platform given its
  `platform_id` or `:error` if not found.

  Used to introspect platforms at compile-time or runtime.
  """
  @spec platform(atom | String.t()) :: {:ok, %LiveViewNativePlatform.Env{}} | :error
  def platform(platform_id) when is_atom(platform_id) and not is_nil(platform_id),
    do: platform("#{platform_id}")

  def platform(platform_id) when is_binary(platform_id) do
    case env_platform(platform_id) do
      %{} = platform_struct ->
        {:ok, platform_struct}

      _ ->
        :error
    end
  end

  @doc """
  Returns an environment struct for a LiveView Native platform given its
  `platform_id` or raises if not found.

  Same as `platform/1` but raises `RuntimeError` instead of returning
  `:error` if no platform exists for the given `platform_id`
  """
  @spec platform!(atom) :: %LiveViewNativePlatform.Env{}
  def platform!(platform_id) do
    case platform(platform_id) do
      {:ok, %{} = platform} ->
        platform

      :error ->
        platform_ids = env_platforms() |> Map.keys() |> Enum.map(&":#{&1}") |> Enum.join(", ")

        error_message_no_platform = "No LiveView Native platform for #{inspect(platform_id)}"

        error_message_valid_platforms_hint = "The valid platforms are: #{platform_ids}"

        raise error_message_no_platform <> ". " <> error_message_valid_platforms_hint
    end
  end

  @doc """
  Returns a list of environment structs for all LiveView Native platforms.
  """
  @spec platforms() :: LiveViewNative.Platforms.env_platforms_map()
  def platforms, do: env_platforms()
end
