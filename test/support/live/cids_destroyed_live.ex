defmodule LiveViewNativeTest.CidsDestroyedLive do
  use Phoenix.LiveView

  use LiveViewNative.LiveView,
    formats: [:gameboy],
    dispatch_to: &Module.concat/2

  defmodule GameBoy do
    use LiveViewNative.Component,
      format: :gameboy,
      as: :render

    defmodule Button do
      use LiveViewNative.LiveComponent,
        format: :gameboy,
        as: :render

      def mount(socket) do
        {:ok, assign(socket, counter: 0)}
      end

      def render(assigns) do
        ~LVN"""
        <Group>
          <Button type="submit">{@text}</Button>
          <Text id="bumper" phx-click="bump" phx-target={@myself}>Bump: {@counter}</Text>
        </Group>
        """
      end

      def handle_event("bump", _, socket) do
        {:noreply, update(socket, :counter, &(&1 + 1))}
      end
    end

    def render(assigns) do
      ~LVN"""
      <%= if @form do %>
        <LiveForm phx-submit="event_1">
          <.live_component module={Button} id="button" text="Hello World" />
        </LiveForm>
      <% else %>
        <Text class="loader">loading...</Text>
      <% end %>
      """
    end
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: true)}
  end

  def render(assigns),
    do: ~H"In HTML"

  def handle_event("event_1", _params, socket) do
    send(self(), :event_2)
    {:noreply, assign(socket, form: false)}
  end

  def handle_info(:event_2, socket) do
    {:noreply, assign(socket, form: true)}
  end
end
