defmodule LiveViewNative.Server do
  use GenServer
  require Logger

  # Client

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, initial_state())
  end

  # Server (callbacks)

  @impl true
  def init(state) do
    IO.inspect(state)
    {:ok, state}
  end

  # Private functions

  defp initial_state do
    {:ok, app_name} = :application.get_application(__MODULE__)
    live_view_native_config = live_view_native_config()

    live_view_native_config
    |> Enum.into(%{})
    |> Map.put_new(:otp_app, app_name)
    |> init_targets()
  end

  defp init_targets(%{otp_app: otp_app, targets: %{} = targets}) do
    targets
    |> Enum.map(fn {key, {target_mod, _opts}} ->
      app_target_config = Application.get_env(otp_app, target_mod)
      lib_target_config = Application.get_env(:live_view_native, target_mod)

      case app_target_config do
        nil when not is_nil(lib_target_config) ->
          lib_target = struct!(target_mod, lib_target_config)

          {key, lib_target}

        app_target_config when not is_nil(app_target_config) ->
          app_target = struct!(target_mod, app_target_config)

          {key, app_target}

        nil ->
          Logger.warn(
            "no configuration found for otp_app :#{otp_app} and module #{inspect(target_mod)}"
          )

          {key, struct(target_mod, %{})}
      end
    end)
    |> Enum.into(%{})
  end

  defp init_targets(_), do: %{}

  defp live_view_native_config do
    case Application.get_all_env(:live_view_native) do
      config when not is_nil(config) and config != [] ->
        config

      _ ->
        []
    end
  end
end
