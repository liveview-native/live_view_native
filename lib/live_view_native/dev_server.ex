defmodule LiveViewNative.DevServer do
  @moduledoc """
  A GenServer that provides additional services in development environments.
  It supports multicast addressing over UDP to provide visibility between
  LiveView Native development servers and clients running on the same network.
  """
  use GenServer
  require Logger

  @broadcast_interval 1_000 # Broadcast to available clients every second
  @listen_port 0 # Use any available port
  @multicast_group_ip {239, 2, 3, 4} # TODO: Make this configurable
  @publish_port 49_002 # TODO: Make this configurable
  @otp_app_name Application.compile_env(:live_view_native, :otp_app, nil)
  @udp_options [
    :binary,
    active: true,
    add_membership: {@multicast_group_ip, {0, 0, 0, 0}},
    multicast_loop: true
  ]

  def start_link(_) do
    GenServer.start_link(__MODULE__, {}, name: __MODULE__)
  end

  def init(_opts) do
    {:ok, socket} = :gen_udp.open(@listen_port, @udp_options)
    send(self(), :broadcast)

    {:ok, %{socket: socket}}
  end

  def handle_info(:broadcast, %{socket: socket} = state) do
    Process.send_after(self(), :broadcast, @broadcast_interval)

    broadcast_endpoints(socket)

    {:noreply, state}
  end

  def handle_info({:udp, _port, _ip, _port_number, _message}, state) do
    {:noreply, state}
  end

  def handle_info({:udp_passive, _}, %{socket: socket} = state) do
    :inet.setopts(socket, active: true)

    {:noreply, state}
  end

  ###

  defp broadcast_endpoints(socket) do
    all_endpoints()
    |> List.first() # TODO: Broadcast all endpoints
    |> Jason.encode()
    |> case do
      {:ok, payload} ->
        :gen_udp.send(socket, @multicast_group_ip, @publish_port, payload)

      _ ->
        :error
    end
  end

  defp all_endpoints do
    with spec <- Application.spec(@otp_app_name),
         modules <- spec[:modules] || [],
         endpoint_modules <- endpoint_modules(modules)
    do
      endpoint_modules
      |> Enum.map(&endpoint_config/1)
      |> Enum.filter(& &1)
    end
  end

  def endpoint_config(endpoint_module) do
    case Application.fetch_env(@otp_app_name, endpoint_module) do
      {:ok, config} ->
        %{
          hostname: hostname(),
          id: @otp_app_name,
          ip: format_ip(config[:http][:ip]),
          port: "#{config[:http][:port]}"
        }

      _ ->
        nil
    end
  end

  defp endpoint_modules(modules) do
    modules
    |> Enum.filter(fn mod ->
      case mod.module_info(:attributes)[:behaviour] do
        [_ | _] = behaviours ->
          Enum.member?(behaviours, Phoenix.Endpoint)

        _ ->
          false
      end
    end)
  end

  defp hostname do
    {:ok, name} = :inet.gethostname()

    List.to_string(name)
  end

  defp format_ip(ip_tuple) do
    ip_tuple
    |> Tuple.to_list()
    |> Enum.join(".")
  end
end
