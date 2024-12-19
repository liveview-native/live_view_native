defmodule LiveViewNativeTest.ThermostatLive do
  use Phoenix.LiveView, container: {:article, class: "thermo"}, namespace: Phoenix.LiveViewTest

  use LiveViewNative.LiveView,
    formats: [:gameboy],
    dispatch_to: &Module.concat/2

  alias LiveViewNativeTest.ClockLive

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
    formats: [:gameboy],
    dispatch_to: &Module.concat/2

  alias LiveViewNativeTest.ClockControlsLive

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
    formats: [:gameboy],
    dispatch_to: &Module.concat/2

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
    formats: [:gameboy],
    dispatch_to: &Module.concat/2

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

defmodule LiveViewNativeTest.AssignAsyncLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView,
    formats: [:gameboy],
    dispatch_to: &Module.concat/2

  on_mount({__MODULE__, :defaults})

  def on_mount(:defaults, _params, _session, socket) do
    {:cont, assign(socket, lc: false)}
  end

  def render(assigns),
    do: ~H""

  defmodule GameBoy do
    use LiveViewNative.Component,
      format: :gameboy,
      as: :render

    def render(assigns, _interface) do
      ~LVN"""
      <.live_component
        :if={@lc}
        module={LiveViewNativeTest.AssignAsyncLive.LC}
        test={@lc}
        id="lc"
      />

      <Text :if={@data.loading}>data loading...</Text>
      <Text :if={@data.ok? && @data.result == nil}>no data found</Text>
      <Text :if={@data.ok? && @data.result}>data: {inspect(@data.result)}</Text>
      <Text :if={@data.failed}>{inspect(@data.failed)}</Text>
      """
    end
  end

  def mount(%{"test" => "lc_" <> lc_test}, _session, socket) do
    {:ok,
     socket
     |> assign(lc: lc_test)
     |> assign_async(:data, fn -> {:ok, %{data: :live_component}} end)}
  end

  def mount(%{"test" => "bad_return"}, _session, socket) do
    {:ok, assign_async(socket, :data, fn -> 123 end)}
  end

  def mount(%{"test" => "bad_ok"}, _session, socket) do
    {:ok, assign_async(socket, :data, fn -> {:ok, %{bad: 123}} end)}
  end

  def mount(%{"test" => "ok"}, _session, socket) do
    {:ok, assign_async(socket, :data, fn -> {:ok, %{data: 123}} end)}
  end

  def mount(%{"test" => "sup_ok"}, _session, socket) do
    {:ok,
     assign_async(socket, :data, fn -> {:ok, %{data: 123}} end, supervisor: TestAsyncSupervisor)}
  end

  def mount(%{"test" => "raise"}, _session, socket) do
    {:ok, assign_async(socket, :data, fn -> raise("boom") end)}
  end

  def mount(%{"test" => "sup_raise"}, _session, socket) do
    {:ok, assign_async(socket, :data, fn -> raise("boom") end, supervisor: TestAsyncSupervisor)}
  end

  def mount(%{"test" => "exit"}, _session, socket) do
    {:ok, assign_async(socket, :data, fn -> exit(:boom) end)}
  end

  def mount(%{"test" => "sup_exit"}, _session, socket) do
    {:ok, assign_async(socket, :data, fn -> exit(:boom) end, supervisor: TestAsyncSupervisor)}
  end

  def mount(%{"test" => "lv_exit"}, _session, socket) do
    {:ok,
     assign_async(socket, :data, fn ->
       Process.register(self(), :lv_exit)
       send(:assign_async_test_process, :async_ready)
       Process.sleep(:infinity)
     end)}
  end

  def mount(%{"test" => "cancel"}, _session, socket) do
    {:ok,
     assign_async(socket, :data, fn ->
       Process.register(self(), :cancel)
       send(:assign_async_test_process, :async_ready)
       Process.sleep(:infinity)
     end)}
  end

  def mount(%{"test" => "trap_exit"}, _session, socket) do
    Process.flag(:trap_exit, true)

    {:ok,
     assign_async(socket, :data, fn ->
       spawn_link(fn -> exit(:boom) end)
       Process.sleep(100)
       {:ok, %{data: 0}}
     end)}
  end

  def mount(%{"test" => "socket_warning"}, _session, socket) do
    {:ok, assign_async(socket, :data, function_that_returns_the_anonymous_function(socket))}
  end

  def mount(params, _session, socket) do
    require IEx
    IEx.pry()
    {:ok, socket}
  end

  defp function_that_returns_the_anonymous_function(socket) do
    fn ->
      Function.identity(socket)
      {:ok, %{data: 0}}
    end
  end

  def handle_info(:boom, _socket), do: exit(:boom)

  def handle_info(:cancel, socket) do
    {:noreply, cancel_async(socket, socket.assigns.data)}
  end

  def handle_info({:EXIT, pid, reason}, socket) do
    send(:trap_exit_test, {:exit, pid, reason})
    {:noreply, socket}
  end

  def handle_info(:renew_canceled, socket) do
    {:noreply,
     assign_async(socket, :data, fn ->
       Process.sleep(100)
       {:ok, %{data: 123}}
     end)}
  end
end

defmodule LiveViewNativeTest.AssignAsyncLive.LC do
  use LiveViewNative.LiveComponent,
    format: :gameboy,
    as: :render

  def render(assigns) do
    ~LVN"""
    <Group>
      <.async_result :let={data} assign={@lc_data}>
        <:loading>lc_data loading...</:loading>
        <:failed :let={{kind, reason}}>{kind}: {inspect(reason)}</:failed>
        lc_data: {inspect(data)}
      </.async_result>
      <.async_result :let={data} assign={@other_data}>
        <:loading>other_data loading...</:loading>
        other_data: {inspect(data)}
      </.async_result>
    </Group>
    """
  end

  def update(%{test: "bad_return"}, socket) do
    {:ok, assign_async(socket, [:lc_data, :other_data], fn -> 123 end)}
  end

  def update(%{test: "bad_ok"}, socket) do
    {:ok, assign_async(socket, [:lc_data, :other_data], fn -> {:ok, %{bad: 123}} end)}
  end

  def update(%{test: "ok"}, socket) do
    {:ok,
     assign_async(socket, [:lc_data, :other_data], fn ->
       {:ok, %{other_data: 555, lc_data: 123}}
     end)}
  end

  def update(%{test: "raise"}, socket) do
    {:ok, assign_async(socket, [:lc_data, :other_data], fn -> raise("boom") end)}
  end

  def update(%{test: "exit"}, socket) do
    {:ok, assign_async(socket, [:lc_data, :other_data], fn -> exit(:boom) end)}
  end

  def update(%{test: "lv_exit"}, socket) do
    {:ok,
     assign_async(socket, [:lc_data, :other_data], fn ->
       Process.register(self(), :lc_exit)
       send(:assign_async_test_process, :async_ready)
       Process.sleep(:infinity)
     end)}
  end

  def update(%{test: "cancel"}, socket) do
    {:ok,
     assign_async(socket, [:lc_data, :other_data], fn ->
       Process.register(self(), :lc_cancel)
       send(:assign_async_test_process, :async_ready)
       Process.sleep(:infinity)
     end)}
  end

  def update(%{action: :boom}, _socket), do: exit(:boom)

  def update(%{action: :cancel}, socket) do
    {:ok, cancel_async(socket, socket.assigns.lc_data)}
  end

  def update(%{action: :assign_async_reset, reset: reset}, socket) do
    fun = fn ->
      Process.sleep(50)
      {:ok, %{other_data: 999, lc_data: 456}}
    end

    {:ok, assign_async(socket, [:lc_data, :other_data], fun, reset: reset)}
  end

  def update(%{action: :renew_canceled}, socket) do
    {:ok,
     assign_async(socket, :lc_data, fn ->
       Process.sleep(100)
       {:ok, %{lc_data: 123}}
     end)}
  end
end
