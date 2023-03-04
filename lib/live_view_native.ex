defmodule LiveViewNative do
  @moduledoc """
  LiveViewNative keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  @env_platforms LiveViewNative.Platforms.env_platforms()

  def start_simulator!(platform_id, opts \\ []) do
    %LiveViewNativePlatform.Context{platform_config: platform_config} = platform!(platform_id)

    LiveViewNativePlatform.start_simulator(platform_config, opts)
  end

  def platform(platform_id) when is_atom(platform_id) and not is_nil(platform_id),
    do: platform("#{platform_id}")

  def platform(platform_id) when is_binary(platform_id) do
    case Map.get(@env_platforms, platform_id) do
      %{} = platform_struct ->
        {:ok, platform_struct}

      _ ->
        :error
    end
  end

  def platform!(platform_id) do
    case platform(platform_id) do
      {:ok, %{} = platform} ->
        platform

      :error ->
        platform_ids = @env_platforms |> Map.keys() |> Enum.map(&":#{&1}") |> Enum.join(", ")

        error_message_no_platform =
          "No LiveView Native platform for #{inspect(platform_id)}"

        error_message_valid_platforms_hint =
          "The valid platforms are: #{platform_ids}"

        raise error_message_no_platform <> ". " <> error_message_valid_platforms_hint
    end
  end

  def platforms, do: @env_platforms
end
