alias LiveViewNativeTest.{ClockLive, ClockControlsLive}

defmodule LiveViewNativeTest.ThermostatLive do
  use Phoenix.LiveView, container: {:article, class: "thermo"}, namespace: Phoenix.LiveViewTest

  use LiveViewNative.LiveView,
    formats: [:gameboy]

  defmodule GameBoy do
    use LiveViewNative.Component,
      format: :gameboy,
      as: :render

    def render(assigns, _interface) do
      ~LVN"""
      <Text>Redirect: {@redirect}</Text>
      <Text>The temp is: {@val}{@greeting}</Text>
      <Button phx-click="dec">-</Button>
      <Button phx-click="inc">+</Button>
      <%= if @nest do %>
        {live_render(@socket, ClockLive, [id: :clock] ++ @nest)}
        <%= for user <- @users do %>
          <Text>{user.name} {user.email}</Text>
        <% end %>
      <% end %>
      """
    end
  end

  defmodule Error do
    defexception [:plug_status]
    def message(%{plug_status: status}), do: "error #{status}"
  end

  def render(assigns),
    do: ~H"In HTML"

  def mount(%{"raise_connected" => status}, session, socket) do
    if connected?(socket) do
      raise Error, plug_status: String.to_integer(status)
    else
      mount(%{}, session, socket)
    end
  end

  def mount(%{"raise_disconnected" => status}, session, socket) do
    if connected?(socket) do
      mount(%{}, session, socket)
    else
      raise Error, plug_status: String.to_integer(status)
    end
  end

  def mount(_params, session, socket) do
    nest = Map.get(session, "nest", false)
    users = session["users"] || []
    val = if connected?(socket), do: 1, else: 0

    {:ok, assign(socket, val: val, nest: nest, users: users, greeting: nil)}
  end

  def handle_params(params, _url, socket) do
    {:noreply, assign(socket, redirect: params["redirect"] || "none")}
  end

  def handle_event("key", %{"key" => "i"}, socket) do
    {:noreply, update(socket, :val, &(&1 + 1))}
  end

  def handle_event("key", %{"key" => "d"}, socket) do
    {:noreply, update(socket, :val, &(&1 - 1))}
  end

  def handle_event("save", %{"temp" => new_temp} = params, socket) do
    {:noreply, assign(socket, val: new_temp, greeting: inspect(params["_target"]))}
  end

  def handle_event("save", new_temp, socket) do
    {:noreply, assign(socket, :val, new_temp)}
  end

  def handle_event("inactive", %{"value" => msg}, socket) do
    {:noreply, assign(socket, :greeting, "Tap to wake – #{msg}")}
  end

  def handle_event("active", %{"value" => msg}, socket) do
    {:noreply, assign(socket, :greeting, "Waking up – #{msg}")}
  end

  def handle_event("noop", _, socket), do: {:noreply, socket}

  def handle_event("inc", _, socket), do: {:noreply, update(socket, :val, &(&1 + 1))}

  def handle_event("dec", _, socket), do: {:noreply, update(socket, :val, &(&1 - 1))}

  def handle_call({:set, var, val}, _, socket) do
    {:reply, :ok, assign(socket, var, val)}
  end
end

defmodule LiveViewNativeTest.ClockLive do
  use Phoenix.LiveView, container: {:section, class: "clock"}

  use LiveViewNative.LiveView,
    formats: [:gameboy]

  defmodule GameBoy do
    use LiveViewNative.Component,
      format: :gameboy,
      as: :render

    def render(assigns, _interface) do
      ~LVN"""
      time: {@time} {@name}
      {live_render(@socket, ClockControlsLive,
        id: :"#{String.replace(@name, " ", "-")}-controls",
        sticky: @sticky
      ) }
      """
    end
  end

  def render(assigns),
    do: ~H"In HTML"

  def mount(:not_mounted_at_router, session, socket) do
    {:ok, assign(socket, time: "12:00", name: session["name"] || "NY", sticky: false)}
  end

  def mount(%{} = params, session, socket) do
    {:ok,
     assign(socket, time: "12:00", name: session["name"] || "NY", sticky: !!params["sticky"])}
  end

  def handle_info(:snooze, socket) do
    {:noreply, assign(socket, :time, "12:05")}
  end

  def handle_info({:run, func}, socket) do
    func.(socket)
  end

  def handle_call({:set, new_time}, _from, socket) do
    {:reply, :ok, assign(socket, :time, new_time)}
  end
end

defmodule LiveViewNativeTest.ClockControlsLive do
  use Phoenix.LiveView

  use LiveViewNative.LiveView,
    formats: [:gameboy]

  defmodule GameBoy do
    use LiveViewNative.Component,
      format: :gameboy,
      as: :render

    def render(assigns, _interface) do
      ~LVN"""
      <Button phx-click="snooze">+</Button>
      """
    end
  end

  def render(assigns),
    do: ~H""

  def mount(_params, _session, socket), do: {:ok, socket}

  def handle_event("snooze", _, socket) do
    send(socket.parent_pid, :snooze)
    {:noreply, socket}
  end
end

defmodule LiveViewNativeTest.DashboardLive do
  use Phoenix.LiveView, container: {:div, class: inspect(__MODULE__)}
  use LiveViewNative.LiveView,
    formats: [:gameboy]

    defmodule GameBoy do
      use LiveViewNative.Component,
        format: :gameboy,
        as: :render

      def render(assigns, _interface) do
        ~LVN"""
        session: {Phoenix.HTML.raw(inspect(@session))}
        """
      end
    end

  def render(assigns),
    do: ~H"In HTML"

  def mount(_params, session, socket) do
    {:ok, assign(socket, %{session: session, title: "Dashboard"})}
  end
end
