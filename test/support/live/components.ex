defmodule LiveViewNativeTest.FunctionComponent do
  use LiveViewNative.Component, format: :gameboy

  def render(assigns, _interface) do
    ~LVN"""
    COMPONENT:{@value}
    """
  end

  def render_with_inner_content(assigns) do
    ~LVN"""
    COMPONENT:{@value}, Content: {render_slot(@inner_block)}
    """
  end
end

defmodule LiveViewNativeTest.FunctionComponentWithAttrs do
  use LiveViewNative.Component

  defmodule Struct do
    defstruct []
  end

  def identity(var), do: var
  def map_identity(%{} = map), do: map

  attr :attr, :any
  def fun_attr_any(assigns, _interface), do: ~LVN[]

  attr :attr, :string
  def fun_attr_string(assigns, _interface), do: ~LVN[]

  attr :attr, :atom
  def fun_attr_atom(assigns, _interface), do: ~LVN[]

  attr :attr, :boolean
  def fun_attr_boolean(assigns, _interface), do: ~LVN[]

  attr :attr, :integer
  def fun_attr_integer(assigns, _interface), do: ~LVN[]

  attr :attr, :float
  def fun_attr_float(assigns, _interface), do: ~LVN[]

  attr :attr, :map
  def fun_attr_map(assigns, _interface), do: ~LVN[]

  attr :attr, :list
  def fun_attr_list(assigns, _interface), do: ~LVN[]

  attr :attr, :global
  def fun_attr_global(assigns, _interface), do: ~LVN[]

  attr :rest, :global, doc: "These are passed to the inner input field"
  def fun_attr_global_doc(assigns, _interface), do: ~LVN[]

  attr :rest, :global, doc: "These are passed to the inner input field", include: ~w(value)
  def fun_attr_global_doc_include(assigns, _interface), do: ~LVN[]

  attr :rest, :global, include: ~w(value)
  def fun_attr_global_include(assigns, _interface), do: ~LVN[]

  attr :name, :string, doc: "The form input name"
  attr :rest, :global, doc: "These are passed to the inner input field"
  def fun_attr_global_and_regular(assigns, _interface), do: ~LVN[]

  attr :attr, Struct
  def fun_attr_struct(assigns, _interface), do: ~LVN[]

  attr :attr, :any, required: true
  def fun_attr_required(assigns, _interface), do: ~LVN[]

  attr :attr, :any, default: %{}
  def fun_attr_default(assigns, _interface), do: ~LVN[]

  attr :attr1, :any
  attr :attr2, :any
  def fun_multiple_attr(assigns, _interface), do: ~LVN[]

  attr :attr, :any, doc: "attr docs"
  def fun_with_attr_doc(assigns, _interface), do: ~LVN[]

  attr :attr, :any, default: "foo", doc: "attr docs."
  def fun_with_attr_doc_period(assigns, _interface), do: ~LVN[]

  attr :attr, :any,
    default: "foo",
    doc: """
    attr docs with bullets:

      * foo
      * bar

    and that's it.
    """

  def fun_with_attr_doc_multiline(assigns, _interface), do: ~LVN[]

  attr :attr1, :any
  attr :attr2, :any, doc: false
  def fun_with_hidden_attr(assigns, _interface), do: ~LVN[]

  attr :attr, :any
  @doc "fun docs"
  def fun_with_doc(assigns, _interface), do: ~LVN[]

  attr :attr, :any

  @doc """
  fun docs
  [INSERT LVATTRDOCS]
  fun docs
  """
  def fun_doc_injection(assigns, _interface), do: ~LVN[]

  attr :attr, :any
  @doc false
  def fun_doc_false(assigns, _interface), do: ~LVN[]

  attr :attr, :any
  defp private_fun(assigns, _interface), do: ~LVN[]
  def exposes_private_fun_to_avoid_warnings(assigns, interface), do: private_fun(assigns, interface)

  slot(:inner_block)
  def fun_slot(assigns, _interface), do: ~LVN[]

  slot(:inner_block, doc: "slot docs")
  def fun_slot_doc(assigns, _interface), do: ~LVN[]

  slot(:inner_block, required: true)
  def fun_slot_required(assigns, _interface), do: ~LVN[]

  slot :named, required: true, doc: "a named slot" do
    attr :attr1, :any, required: true, doc: "a slot attr doc"
    attr :attr2, :any, doc: "a slot attr doc"
  end

  def fun_slot_with_attrs(assigns, _interface), do: ~LVN[]

  slot :named, required: true do
    attr :attr1, :any, required: true, doc: "a slot attr doc"
    attr :attr2, :any, doc: "a slot attr doc"
  end

  def fun_slot_no_doc_with_attrs(assigns, _interface), do: ~LVN[]

  slot :named,
    required: true,
    doc: """
    Important slot:

    * for a
    * for b
    """ do
    attr :attr1, :any, required: true, doc: "a slot attr doc"
    attr :attr2, :any, doc: "a slot attr doc"
  end

  def fun_slot_doc_multiline_with_attrs(assigns, _interface), do: ~LVN[]

  slot :named, required: true do
    attr :attr1, :any,
      required: true,
      doc: """
      attr docs with bullets:

        * foo
        * bar

      and that's it.
      """

    attr :attr2, :any, doc: "a slot attr doc"
  end

  def fun_slot_doc_with_attrs_multiline(assigns, _interface), do: ~LVN[]

  attr :attr1, :atom, values: [:foo, :bar, :baz]
  attr :attr2, :atom, examples: [:foo, :bar, :baz]
  attr :attr3, :list, values: [[60, 40]]
  attr :attr4, :list, examples: [[60, 40]]

  def fun_attr_values_examples(assigns, _interface), do: ~LVN[]
end

defmodule LiveViewNativeTest.StatefulComponent do
  use LiveViewNative.LiveComponent,
    format: :gameboy,
    as: :render

  def mount(socket) do
    {:ok, assign(socket, name: "unknown", dup_name: nil, parent_id: nil)}
  end

  def update(assigns, socket) do
    if from = assigns[:from] do
      sent_assigns = Map.merge(assigns, %{id: socket.assigns[:id], myself: socket.assigns.myself})
      send(from, {:updated, sent_assigns})
    end

    {:ok, assign(socket, assigns)}
  end

  def render(%{disabled: true} = assigns, _interface) do
    ~LVN"""
    <Text>
      DISABLED
    </Text>
    """
  end

  def render(%{socket: _} = assigns, _interface) do
    ~LVN"""
    <Group phx-click="transform" id={@id} phx-target={"#" <> @id <> include_parent_id(@parent_id)}>
      {@name} says hi
      <.live_component :if={@dup_name} module={__MODULE__} id={@dup_name} name={@dup_name} />
    </Group>
    """
  end

  defp include_parent_id(nil), do: ""
  defp include_parent_id(parent_id), do: ",#{parent_id}"

  def handle_event("transform", %{"op" => op}, socket) do
    case op do
      "upcase" ->
        {:noreply, update(socket, :name, &String.upcase(&1))}

      "title-case" ->
        {:noreply,
         update(socket, :name, fn <<first::binary-size(1), rest::binary>> ->
           String.upcase(first) <> rest
         end)}

      "dup" ->
        {:noreply, assign(socket, :dup_name, socket.assigns.name <> "-dup")}

      "push_navigate" ->
        {:noreply, push_navigate(socket, to: "/components?redirect=push")}

      "push_patch" ->
        {:noreply, push_patch(socket, to: "/components?redirect=patch")}

      "redirect" ->
        {:noreply, redirect(socket, to: "/components?redirect=redirect")}
    end
  end
end

defmodule LiveViewNativeTest.WithComponentLive do
  use Phoenix.LiveView

  use LiveViewNative.LiveView,
    formats: [:gameboy],
    dispatch_to: &Module.concat/2

  def render(assigns), do: ~H"In HTML"

  defmodule GameBoy do
    use LiveViewNative.Component,
      format: :gameboy,
      as: :render

    def render(%{disabled: :all} = assigns) do
      ~LVN"""
      Disabled
      """
    end

    def render(assigns) do
      ~LVN"""
      Redirect: {@redirect}
      <%= for name <- @names do %>
        <.live_component
          module={LiveViewNativeTest.StatefulComponent}
          id={name}
          name={name}
          from={@from}
          disabled={name in @disabled}
          parent_id={nil}
        />
      <% end %>
      """
    end
  end

  def mount(_params, %{"names" => names, "from" => from}, socket) do
    {:ok, assign(socket, names: names, from: from, disabled: [])}
  end

  def handle_params(params, _url, socket) do
    {:noreply, assign(socket, redirect: params["redirect"] || "none")}
  end

  def handle_info({:send_update, updates}, socket) do
    Enum.each(updates, fn {module, args} -> send_update(module, args) end)
    {:noreply, socket}
  end

  def handle_event("delete-name", %{"name" => name}, socket) do
    {:noreply, update(socket, :names, &List.delete(&1, name))}
  end

  def handle_event("disable-all", %{}, socket) do
    {:noreply, assign(socket, :disabled, :all)}
  end

  def handle_event("dup-and-disable", %{}, socket) do
    names = socket.assigns.names
    new_socket = assign(socket, disabled: names, names: names ++ Enum.map(names, &(&1 <> "-new")))
    {:noreply, new_socket}
  end
end

defmodule LiveViewNativeTest.WithMultipleTargets do
  use Phoenix.LiveView

  use LiveViewNative.LiveView,
    formats: [:gameboy],
    dispatch_to: &Module.concat/2

  def render(assigns), do: ~H"In HTML"

  defmodule GameBoy do
    use LiveViewNative.Component,
      format: :gameboy,
      as: :render

    def render(assigns) do
      ~LVN"""
      <Group id="parent_id" class="parent">
        {@message}
        <%= for name <- @names do %>
          <.live_component
            module={LiveViewNativeTest.StatefulComponent}
            id={name}
            name={name}
            from={@from}
            disabled={name in @disabled}
            parent_id={@parent_selector}
          />
        <% end %>
      </Group>
      """
    end
  end

  def mount(_params, %{"names" => names, "from" => from} = session, socket) do
    {
      :ok,
      assign(socket,
        names: names,
        from: from,
        disabled: [],
        message: nil,
        parent_selector: Map.get(session, "parent_selector", "#parent_id")
      )
    }
  end

  def handle_event("transform", %{"op" => _op}, socket) do
    {:noreply, assign(socket, :message, "Parent was updated")}
  end

  def handle_event("disable", %{"name" => name}, socket) do
    {:noreply, assign(socket, :disabled, Enum.uniq([name | socket.assigns.disabled]))}
  end
end

defmodule LiveViewNativeTest.WithLogOverride do
  use Phoenix.LiveView, log: :warning

  use LiveViewNative.LiveView,
    formats: [:gameboy],
    dispatch_to: &Module.concat/2

  def render(assigns), do: ~H"In HTML"

  defmodule GameBoy do
    use LiveViewNative.Component,
      format: :gameboy,
      as: :render

    def render(assigns),
      do: ~LVN[]
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end

defmodule LiveViewNativeTest.WithLogDisabled do
  use Phoenix.LiveView, log: false

  use LiveViewNative.LiveView,
    formats: [:gameboy],
    dispatch_to: &Module.concat/2

  def render(assigns), do: ~H"In HTML"

  defmodule GameBoy do
    use LiveViewNative.Component,
      format: :gameboy,
      as: :render

    def render(assigns),
      do: ~LVN[]
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end

defmodule LiveViewNativeTest.NestedFunctionComponents do
  use Phoenix.LiveView, log: false

  use LiveViewNative.LiveView,
    formats: [:gameboy],
    dispatch_to: &Module.concat/2

  def render(assigns), do: ~H"<.first/>"

  def first(assigns) do
    ~H"In HTML"
  end

  defmodule GameBoy do
    use LiveViewNative.Component,
      format: :gameboy,
      as: :render

    def render(assigns),
      do: ~LVN"<.first/>"

    def first(assigns, _interface) do
      ~LVN"<.second/>"
    end

    def second(assigns, %{"target" => "watch"}) do
      ~LVN"<Text>In Watch</Text>"
    end

    def second(assigns, _interface) do
      ~LVN"<Text>In Default</Text>"
    end
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
