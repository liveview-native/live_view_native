defmodule LiveViewNativeTest.ComponentInLive.Root do
  use Phoenix.LiveView

  use LiveViewNative.LiveView,
    formats: [:gameboy],
    dispatch_to: &Module.concat/2

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :enabled, true)}
  end

  def render(assigns),
    do: ~H"In HTML"

  defmodule GameBoy do
    use LiveViewNative.Component,
      format: :gameboy,
      as: :render

    def render(assigns, _interface) do
      ~LVN"{@enabled && live_render(@socket, LiveViewNativeTest.ComponentInLive.Live, id: :nested_live)}"
    end
  end

  def handle_info(:disable, socket) do
    {:noreply, assign(socket, :enabled, false)}
  end
end

defmodule LiveViewNativeTest.ComponentInLive.Live do
  use Phoenix.LiveView

  use LiveViewNative.LiveView,
    formats: [:gameboy],
    dispatch_to: &Module.concat/2

  def render(assigns) do
    ~H"In HTML 2"
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  defmodule GameBoy do
    use LiveViewNative.Component,
      format: :gameboy,
      as: :render

    def render(assigns, _interface) do
      ~LVN"""
      <.live_component module={LiveViewNativeTest.ComponentInLive.Component} id={:nested_component} />
      """
    end
  end

  def handle_event("disable", _params, socket) do
    send(socket.parent_pid, :disable)
    {:noreply, socket}
  end
end

defmodule LiveViewNativeTest.ComponentInLive.Component do
  use LiveViewNative.LiveComponent,
    format: :gameboy,
    as: :render

  # Make sure mount is calling by setting assigns in them.
  def mount(socket) do
    {:ok, assign(socket, world: "World")}
  end

  def update(_assigns, socket) do
    {:ok, assign(socket, hello: "Hello")}
  end

  def render(assigns, _interface) do
    ~LVN"<Text>{@hello} {@world}</Text>"
  end
end
