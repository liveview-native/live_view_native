# Handling Events

Events are a common part of any LiveView application. On the server, LiveView Native handles events identically to LiveView
on the web. How the client handles events depends on the native platform and its respective client implementation. This
document provides some general information on events regardless of platform.

## Translated Bindings

Platforms may translate [Phoenix bindings](https://hexdocs.pm/phoenix_live_view/bindings.html) to their native counterparts
where it makes sense. The most common example of this is `phx-click` which listens for tap events on SwiftUI and Jetpack
targets.

On the server, events are handled using standard LiveView callbacks like `handle_event/3` regardless of what platform they
come from. Callbacks can also be shared across platforms, assuming the events and their params are compatible. Here is a
basic example of sharing a `handle_event/3` callback in this way:

```elixir
# hello_live.ex
defmodule MyAppWeb.HelloLive do
  use Phoenix.LiveView
  use MyAppWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, name: "World")}
  end

  @impl true
  def render(%{format: :swiftui} = assigns) do
    # This UI renders on the iPhone / iPad app
    ~SWIFTUI"""
    <VStack>
      <Text phx-click="click_test">Hello <%= @name %>!</Text>
    </VStack>
    """
  end

  @impl true
  def render(%{} = assigns) do
    # This UI renders on the web
    ~H"""
    <div class="flex w-full h-screen items-center">
      <span class="w-full text-center" phx-click="click_test">
        Hello <%= @name %>!
      </span>
    </div>
    """
  end

  @impl true
  def handle_event("click_test", _params, socket) do
    # This event can be called from both SwiftUI and the web
    {:noreply, assign(socket, name: "José")}
  end
end
```

In this example, clicking the "Hello World" button changes it to say "Hello José" on both the web and iOS.
The same `handle_event/3` callback is fired in both cases.

## Change Events

In LiveView Native, elements can support client-side changes to their value outside of a `<form>`.
Synchronizing the values must be handled manually by the LiveView using change events.

### Client-side changes
Use the `phx-change` attribute to respond to client-side changes to an element's value.

```html
<TextField text={@text} phx-change="value-changed" />
```

A [`handle_event/3`](`c:Phoenix.LiveView.handle_event/3`) implementation with the name `"value-changed"` will be called anytime the user changes the text of the `TextField`.

```elixir
def handle_event("value-changed", new_value, socket) do
  {:noreply, assign(socket, text: new_value)}
end
```

The `phx-debounce`, `phx-throttle`, and `phx-target` attributes can be used to configure the event.

Refer to the documentation for an element to find out if it supports client-side changes.

### Server-side changes
Each element has an attribute that controls its value.
For example, `TextField` in the SwiftUI client uses the attribute `text`.
See the documentation for an element to find out what attribute it uses.

Whenever the attribute's value is changed, the client will update to display the new value.
No change event is sent when the server updates the value.

### Modifier change events
Some modifiers have values that can be changed by the client.

To receive change events on these modifiers, pass a `LiveViewNativePlatform.Modifier.Types.Event` to the `change` argument.

```elixir
sheet(is_presented: @show, change: "presentation-changed")
```

Provide a map to `change` for more advanced configuration.

```elixir
sheet(is_presented: @show, change: %{ event: "presentation-changed", debounce: 2000, target: @myself })
```

A change event will be sent with every argument of the modifier that can be change-tracked.

```elixir
def handle_event("presentation-changed", %{ "is_presented" => show }, socket) do
  {:noreply, assign(socket, show: show)}
end
```

In the example above, the server can show/hide the sheet by setting the `show` assign.
When the user swipes down on the sheet to close it, the `"presentation-changed"` event will be called with the value `false`.

See the documentation for a modifier to find out which arguments can be change-tracked.