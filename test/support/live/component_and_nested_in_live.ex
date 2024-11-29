defmodule LiveViewNativeTest.ComponentAndNestedInLive do
  use Phoenix.LiveView

  use LiveViewNative.LiveView,
    formats: [:gameboy]

  defmodule GameBoy do
    use LiveViewNative.Component,
      format: :gameboy,
      as: :render

    defmodule NestedLive do
      use Phoenix.LiveView

      use LiveViewNative.LiveView,
        formats: [:gameboy]

      defmodule GameBoy do
        use LiveViewNative.Component,
          format: :gameboy,
          as: :render

        def render(assigns, _interface) do
          ~LVN"<Text><%= @hello %></Text>"
        end
      end

      def mount(_params, _session, socket) do
        {:ok, assign(socket, :hello, "hello")}
      end

      def render(assigns) do
        ~H"<div><%= @hello %></div>"
      end

      def handle_event("disable", _params, socket) do
        send(socket.parent_pid, :disable)
        {:noreply, socket}
      end
    end

    defmodule NestedComponent do
      use LiveViewNative.LiveComponent,
        format: :gameboy,
        as: :render

      def mount(socket) do
        {:ok, assign(socket, :world, "world")}
      end

      def render(assigns) do
        ~LVN"<Text><%= @world %></Text>"
      end
    end

    def render(assigns, _interface) do
      ~LVN"""
      <%= if @enabled do %>
        <%= live_render(@socket, NestedLive, id: :nested_live) %>
        <.live_component module={NestedComponent} id={:_component} />
      <% end %>
      """
    end

  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :enabled, true)}
  end

  def render(assigns) do
    ~H"In HTML"
  end

  def handle_event("disable", _, socket) do
    {:noreply, assign(socket, :enabled, false)}
  end
end
