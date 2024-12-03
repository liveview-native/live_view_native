defmodule LiveViewNativeTest.ParamCounterLive do
  use Phoenix.LiveView

  use LiveViewNative.LiveView,
    formats: [:gameboy]

  defmodule GameBoy do
    use LiveViewNative.Component,
      format: :gameboy,
      as: :render

    def render(assigns, _interface) do
      ~LVN"""
      <Text>The value is: {@val}</Text>
      <Text>mount: {inspect(@mount_params)}</Text>
      <Text>params: {inspect(@params)}</Text>
      """
    end
  end

  def render(assigns),
    do: ~H"In HTML"

  def mount(params, session, socket) do
    on_handle_params = session["on_handle_params"]

    {:ok,
     assign(
       socket,
       val: 1,
       mount_params: params,
       test_pid: session["test_pid"],
       connected?: connected?(socket),
       on_handle_params: on_handle_params && :erlang.binary_to_term(on_handle_params)
     )}
  end

  def handle_params(%{"from" => "handle_params"} = params, uri, socket) do
    send(socket.assigns.test_pid, {:handle_params, uri, socket.assigns, params})
    socket.assigns.on_handle_params.(assign(socket, :params, params))
  end

  def handle_params(params, uri, socket) do
    send(socket.assigns.test_pid, {:handle_params, uri, socket.assigns, params})
    {:noreply, assign(socket, :params, params)}
  end

  def handle_info({:set, var, val}, socket), do: {:noreply, assign(socket, var, val)}

  def handle_info({:push_patch, to}, socket) do
    {:noreply, push_patch(socket, to: to)}
  end

  def handle_info({:push_navigate, to}, socket) do
    {:noreply, push_navigate(socket, to: to)}
  end

  def handle_call({:push_patch, func}, _from, socket) do
    func.(socket)
  end

  def handle_call({:push_navigate, func}, _from, socket) do
    func.(socket)
  end

  def handle_cast({:push_patch, to}, socket) do
    {:noreply, push_patch(socket, to: to)}
  end

  def handle_cast({:push_navigate, to}, socket) do
    {:noreply, push_navigate(socket, to: to)}
  end

  def handle_event("push_patch", %{"to" => to}, socket) do
    {:noreply, push_patch(socket, to: to)}
  end

  def handle_event("push_navigate", %{"to" => to}, socket) do
    {:noreply, push_navigate(socket, to: to)}
  end
end
