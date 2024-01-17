# Interactive SwiftUI Views

[![Run in Livebook](https://livebook.dev/badge/v1/blue.svg)](https://livebook.dev/run?url=https%3A%2F%2Fraw.githubusercontent.com%2Fliveview-native%2Flive_view_native%2Fmain%2Fguides%2Fnotebooks%interactive-swiftui-views.livemd)

## Overview

In this guide, you'll learn how to build interactive LiveView Native applications using event bindings.

This guide assumes some existing familiarity with [Phoenix Bindings](https://hexdocs.pm/phoenix_live_view/bindings.html) and how to set/access state stored in the LiveView's socket assigns. To get the most out of this material, you should already understand the `assign/3`/`assign/2` function, and how event bindings such as `phx-click` interact with the `handle_event/3` callback function.

## Event Bindings

We can bind any available `phx-*` [Phoenix Binding](https://hexdocs.pm/phoenix_live_view/bindings.html) to a SwiftUI Element. However certain events are not available on native.

LiveView Native currently supports the following events on all SwiftUI views:

* `phx-window-focus`: Fired when the application window gains focus, indicating user interaction with the Native app.
* `phx-window-blur`: Fired when the application window loses focus, indicating the user's switch to other apps or screens.
* `phx-focus`: Fired when a specific native UI element gains focus, often used for input fields.
* `phx-blur`: Fired when a specific native UI element loses focus, commonly used with input fields.
* `phx-click`: Fired when a user taps on a native UI element, enabling a response to tap events.

> The above events work on all SwiftUI views. Some events are only available on specific views. For example, `phx-change` is available on controls and `phx-throttle/phx-debounce` is available on views with events.

There is also a [Pull Request](https://github.com/liveview-native/liveview-client-swiftui/issues/1095) to add Key Events which may have been merged since this guide was published.

## Basic Click Example

The `phx-click` event triggers a corresponding [handle_event/3](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#c:handle_event/3) callback function whenever a SwiftUI view is pressed.

In the example below, the client sends a `"ping"` event to the server, and trigger's the LiveView's `"ping"` event handler.

Evaluate the example below, then click the `"Click me!"` button. Notice `"Pong"` is printed in the server logs below.

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5DbGlja0V4YW1wbGVMaXZlIGRvXG4gIHVzZSBQaG9lbml4LkxpdmVWaWV3XG4gIHVzZSBMaXZlVmlld05hdGl2ZS5MaXZlVmlld1xuXG4gIEBpbXBsIHRydWVcbiAgZGVmIHJlbmRlcigle2Zvcm1hdDogOnN3aWZ0dWl9ID0gYXNzaWducykgZG9cbiAgICB+U1dJRlRVSVwiXCJcIlxuICAgIDxCdXR0b24gcGh4LWNsaWNrPVwicGluZ1wiPlByZXNzIG1lIG9uIG5hdGl2ZSE8L0J1dHRvbj5cbiAgICBcIlwiXCJcbiAgZW5kXG5cbiAgQGltcGwgdHJ1ZVxuICBkZWYgcmVuZGVyKGFzc2lnbnMpIGRvXG4gICAgfkhcIlwiXCJcbiAgICA8YnV0dG9uIHBoeC1jbGljaz1cInBpbmdcIj5DbGljayBtZSBvbiB3ZWIhPC9idXR0b24+XG4gICAgXCJcIlwiXG4gIGVuZFxuXG4gIEBpbXBsIHRydWVcbiAgZGVmIGhhbmRsZV9ldmVudChcInBpbmdcIiwgX3BhcmFtcywgc29ja2V0KSBkb1xuICAgIElPLnB1dHMoXCJQb25nXCIpXG4gICAgezpub3JlcGx5LCBzb2NrZXR9XG4gIGVuZFxuZW5kIiwicGF0aCI6Ii8ifQ","chunks":[[0,109],[111,470],[583,45],[630,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule Server.ClickExampleLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <Button phx-click="ping">Press me on native!</Button>
    """
  end

  @impl true
  def render(assigns) do
    ~H"""
    <button phx-click="ping">Click me on web!</button>
    """
  end

  @impl true
  def handle_event("ping", _params, socket) do
    IO.puts("Pong")
    {:noreply, socket}
  end
end
```

### Click Events Updating State

Event handlers in LiveView can update the LiveView's state in the socket.

Evaluate the cell below to see an example of incrementing a count.

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5Db3VudGVyTGl2ZSBkb1xuICB1c2UgUGhvZW5peC5MaXZlVmlld1xuICB1c2UgTGl2ZVZpZXdOYXRpdmUuTGl2ZVZpZXdcblxuICBAaW1wbCB0cnVlXG4gIGRlZiBtb3VudChfcGFyYW1zLCBfc2Vzc2lvbiwgc29ja2V0KSBkb1xuICAgIHs6b2ssIGFzc2lnbihzb2NrZXQsIDpjb3VudCwgMCl9XG4gIGVuZFxuXG4gIEBpbXBsIHRydWVcbiAgZGVmIHJlbmRlcigle2Zvcm1hdDogOnN3aWZ0dWl9ID0gYXNzaWducykgZG9cbiAgICB+U1dJRlRVSVwiXCJcIlxuICAgIDxCdXR0b24gcGh4LWNsaWNrPVwiaW5jcmVtZW50XCI+Q291bnQ6IDwlPSBAY291bnQgJT48L0J1dHRvbj5cbiAgICBcIlwiXCJcbiAgZW5kXG5cbiAgZGVmIHJlbmRlcihhc3NpZ25zKSBkb1xuICAgIH5IXCJcIlwiXG4gICAgPGJ1dHRvbiBwaHgtY2xpY2s9XCJpbmNyZW1lbnRcIj5Db3VudDogPCU9IEBjb3VudCAlPjwvYnV0dG9uPlxuICAgIFwiXCJcIlxuICBlbmRcblxuICBAaW1wbCB0cnVlXG4gIGRlZiBoYW5kbGVfZXZlbnQoXCJpbmNyZW1lbnRcIiwgX3BhcmFtcywgc29ja2V0KSBkb1xuICAgIHs6bm9yZXBseSwgYXNzaWduKHNvY2tldCwgOmNvdW50LCBzb2NrZXQuYXNzaWducy5jb3VudCArIDEpfVxuICBlbmRcbmVuZCIsInBhdGgiOiIvIn0","chunks":[[0,109],[111,593],[706,45],[753,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule Server.CounterLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :count, 0)}
  end

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <Button phx-click="increment">Count: <%= @count %></Button>
    """
  end

  def render(assigns) do
    ~H"""
    <button phx-click="increment">Count: <%= @count %></button>
    """
  end

  @impl true
  def handle_event("increment", _params, socket) do
    {:noreply, assign(socket, :count, socket.assigns.count + 1)}
  end
end
```

### Your Turn: Decrement Counter

You're going to take the example above, and create a counter that can **both increment and decrement**.

There should be two buttons, each with a `phx-click` binding. One button should bind the `"decrement"` event, and the other button should bind the `"increment"` event. Each event should have a corresponding handler defined using the `handle_event/3` callback function.

### Example Solution

```elixir
defmodule Server.DecrementCounterLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :count, 0)}
  end

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <!-- Displays the current count -->
    <Text><%= @count %></Text>
    <!-- Enter your solution below -->
    <Button phx-click="increment">Increment</Button>
    <Button phx-click="decrement">Decrement</Button>
    """
  end

  def render(assigns) do
    ~H"""
    <p><%= @count %></p>
    <button phx-click="increment">Increment</button>
    <button phx-click="decrement">Decrement</button>
    """
  end

  @impl true
  def handle_event("increment", _params, socket) do
    {:noreply, assign(socket, :count, socket.assigns.count + 1)}
  end

  def handle_event("decrement", _params, socket) do
    {:noreply, assign(socket, :count, socket.assigns.count - 1)}
  end
end
```



<!-- livebook:{"break_markdown":true} -->

### Enter Your Solution Below

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5EZWNyZW1lbnRDb3VudGVyTGl2ZSBkb1xuICB1c2UgUGhvZW5peC5MaXZlVmlld1xuICB1c2UgTGl2ZVZpZXdOYXRpdmUuTGl2ZVZpZXdcblxuICBAaW1wbCB0cnVlXG4gIGRlZiBtb3VudChfcGFyYW1zLCBfc2Vzc2lvbiwgc29ja2V0KSBkb1xuICAgIHs6b2ssIGFzc2lnbihzb2NrZXQsIDpjb3VudCwgMCl9XG4gIGVuZFxuXG4gIEBpbXBsIHRydWVcbiAgZGVmIHJlbmRlcigle2Zvcm1hdDogOnN3aWZ0dWl9ID0gYXNzaWducykgZG9cbiAgICB+U1dJRlRVSVwiXCJcIlxuICAgIDwhLS0gRGlzcGxheXMgdGhlIGN1cnJlbnQgY291bnQgLS0+XG4gICAgPFRleHQ+PCU9IEBjb3VudCAlPjwvVGV4dD5cbiAgICA8IS0tIEVudGVyIHlvdXIgc29sdXRpb24gYmVsb3cgLS0+XG4gICAgXCJcIlwiXG4gIGVuZFxuXG4gIGRlZiByZW5kZXIoYXNzaWducykgZG9cbiAgICB+SFwiXCJcIlxuICAgIDwhLS0gRGlzcGxheXMgdGhlIGN1cnJlbnQgY291bnQgLS0+XG4gICAgPFRleHQ+PCU9IEBjb3VudCAlPjwvVGV4dD5cbiAgICA8IS0tIChPcHRpb25hbCkgRW50ZXIgeW91ciBzb2x1dGlvbiBmb3Igd2ViIGJlbG93IC0tPlxuICAgIFwiXCJcIlxuICBlbmRcblxuICAjIERlZmluZSB5b3VyIGhhbmRsZV9ldmVudC8zIGNhbGxiYWNrcyBiZWxvd1xuZW5kIiwicGF0aCI6Ii8ifQ","chunks":[[0,109],[111,624],[737,45],[784,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule Server.DecrementCounterLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :count, 0)}
  end

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <!-- Displays the current count -->
    <Text><%= @count %></Text>
    <!-- Enter your solution below -->
    """
  end

  def render(assigns) do
    ~H"""
    <!-- Displays the current count -->
    <Text><%= @count %></Text>
    <!-- (Optional) Enter your solution for web below -->
    """
  end

  # Define your handle_event/3 callbacks below
end
```

## Selectable Lists

`List` views support selecting items within the list based on their id. To select an item, provide the `selection` attribute with the item's id.

Pressing a child item in the `List` on a native device triggers the `phx-change` event. In the example below we've bound the `phx-change` event to send the `"selection-changed"` event. This event is then handled by the `handle_event/3` callback function and used to change the selected item.

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5TZWxlY3Rpb25MaXZlIGRvXG4gIHVzZSBQaG9lbml4LkxpdmVWaWV3XG4gIHVzZSBMaXZlVmlld05hdGl2ZS5MaXZlVmlld1xuXG4gIGRlZiBtb3VudChfcGFyYW1zLCBfc2Vzc2lvbiwgc29ja2V0KSBkb1xuICAgIHs6b2ssIGFzc2lnbihzb2NrZXQsIHNlbGVjdGlvbjogXCJOb25lXCIpfVxuICBlbmRcblxuICBAaW1wbCB0cnVlXG4gIGRlZiByZW5kZXIoYXNzaWducykgZG9cbiAgICB+U1dJRlRVSVwiXCJcIlxuICAgIDxMaXN0IHNlbGVjdGlvbj17QHNlbGVjdGlvbn0gcGh4LWNoYW5nZT1cInNlbGVjdGlvbi1jaGFuZ2VkXCI+XG4gICAgICA8JT0gZm9yIGkgPC0gMS4uMTAgZG8gJT5cbiAgICAgICAgPFRleHQgaWQ9e1wiI3tpfVwifT5JdGVtIDwlPSBpICU+PC9UZXh0PlxuICAgICAgPCUgZW5kICU+XG4gICAgPC9MaXN0PlxuICAgIFwiXCJcIlxuICBlbmRcblxuICBkZWYgaGFuZGxlX2V2ZW50KFwic2VsZWN0aW9uLWNoYW5nZWRcIiwgJXsgXCJzZWxlY3Rpb25cIiA9PiBzZWxlY3Rpb24gfSwgc29ja2V0KSBkb1xuICAgIHs6bm9yZXBseSwgYXNzaWduKHNvY2tldCwgc2VsZWN0aW9uOiBzZWxlY3Rpb24pfVxuICBlbmRcbmVuZCIsInBhdGgiOiIvIn0","chunks":[[0,109],[111,566],[679,45],[726,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule Server.SelectionLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  def mount(_params, _session, socket) do
    {:ok, assign(socket, selection: "None")}
  end

  @impl true
  def render(assigns) do
    ~SWIFTUI"""
    <List selection={@selection} phx-change="selection-changed">
      <%= for i <- 1..10 do %>
        <Text id={"#{i}"}>Item <%= i %></Text>
      <% end %>
    </List>
    """
  end

  def handle_event("selection-changed", %{"selection" => selection}, socket) do
    {:noreply, assign(socket, selection: selection)}
  end
end
```

## Expandable Lists

`List` views support hierarchical content using the [DisclosureGroup](https://developer.apple.com/documentation/swiftui/disclosuregroup) view. Nest `DisclosureGroup` views within a list to create multiple levels of content as seen in the example below.

To control a `DisclosureGroup` view, use the `is-expanded` boolean attribute as seen in the example below.

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5IaWVyYXJjaGljYWxMaXN0TGl2ZSBkb1xuICB1c2UgUGhvZW5peC5MaXZlVmlld1xuICB1c2UgTGl2ZVZpZXdOYXRpdmUuTGl2ZVZpZXdcblxuICBkZWYgbW91bnQoX3BhcmFtcywgX3Nlc3Npb24sIHNvY2tldCkgZG9cbiAgICB7Om9rLCBhc3NpZ24oc29ja2V0LCA6aXNfZXhwYW5kZWQsIGZhbHNlKX1cbiAgZW5kXG5cbiAgQGltcGwgdHJ1ZVxuICBkZWYgcmVuZGVyKCV7Zm9ybWF0OiA6c3dpZnR1aX0gPSBhc3NpZ25zKSBkb1xuICAgIH5TV0lGVFVJXCJcIlwiXG4gICAgPExpc3Q+XG4gICAgICA8RGlzY2xvc3VyZUdyb3VwIHBoeC1jaGFuZ2U9XCJ0b2dnbGVcIiBpcy1leHBhbmRlZD17QGlzX2V4cGFuZGVkfT5cbiAgICAgICAgPFRleHQgdGVtcGxhdGU9XCJsYWJlbFwiPkxldmVsIDE8L1RleHQ+XG4gICAgICAgIDxUZXh0Pkl0ZW0gMTwvVGV4dD5cbiAgICAgICAgPFRleHQ+SXRlbSAyPC9UZXh0PlxuICAgICAgICA8VGV4dD5JdGVtIDM8L1RleHQ+XG4gICAgICA8L0Rpc2Nsb3N1cmVHcm91cD5cbiAgICA8L0xpc3Q+XG4gICAgXCJcIlwiXG4gIGVuZFxuXG4gIGRlZiBoYW5kbGVfZXZlbnQoXCJ0b2dnbGVcIiwgJXtcImlzLWV4cGFuZGVkXCIgPT4gaXNfZXhwYW5kZWR9LCBzb2NrZXQpIGRvXG4gICAgezpub3JlcGx5LCBhc3NpZ24oc29ja2V0LCBpc19leHBhbmRlZDogaXNfZXhwYW5kZWQpfVxuICBlbmRcbmVuZCIsInBhdGgiOiIvIn0","chunks":[[0,109],[111,670],[783,45],[830,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule Server.HierarchicalListLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :is_expanded, false)}
  end

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <List>
      <DisclosureGroup phx-change="toggle" is-expanded={@is_expanded}>
        <Text template="label">Level 1</Text>
        <Text>Item 1</Text>
        <Text>Item 2</Text>
        <Text>Item 3</Text>
      </DisclosureGroup>
    </List>
    """
  end

  def handle_event("toggle", %{"is-expanded" => is_expanded}, socket) do
    {:noreply, assign(socket, is_expanded: is_expanded)}
  end
end
```

### Multiple Expandable Lists

The next example shows a convenient pattern for displaying multiple expandable lists without needing to write multiple event handlers.

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5NdWx0aXBsZUV4cGFuZGluZ0xpc3RzTGl2ZSBkb1xuICB1c2UgUGhvZW5peC5MaXZlVmlld1xuICB1c2UgTGl2ZVZpZXdOYXRpdmUuTGl2ZVZpZXdcblxuICBAaW1wbCB0cnVlXG4gIGRlZiBtb3VudChfcGFyYW1zLCBfc2Vzc2lvbiwgc29ja2V0KSBkb1xuICAgIHs6b2ssIGFzc2lnbihzb2NrZXQsIDpleHBhbmRlZF9ncm91cHMsICV7MSA9PiBmYWxzZSwgMiA9PiBmYWxzZX0pfVxuICBlbmRcblxuICBAaW1wbCB0cnVlXG4gIGRlZiByZW5kZXIoJXtmb3JtYXQ6IDpzd2lmdHVpfSA9IGFzc2lnbnMpIGRvXG4gICAgflNXSUZUVUlcIlwiXCJcbiAgICA8TGlzdD5cbiAgICAgIDxEaXNjbG9zdXJlR3JvdXAgcGh4LWNoYW5nZT1cInRvZ2dsZS0xXCIgaXMtZXhwYW5kZWQ9e0BleHBhbmRlZF9ncm91cHNbMV19PlxuICAgICAgICA8VGV4dCB0ZW1wbGF0ZT1cImxhYmVsXCI+TGV2ZWwgMTwvVGV4dD5cbiAgICAgICAgPFRleHQ+SXRlbSAxPC9UZXh0PlxuICAgICAgICA8RGlzY2xvc3VyZUdyb3VwIHBoeC1jaGFuZ2U9XCJ0b2dnbGUtMlwiIGlzLWV4cGFuZGVkPXtAZXhwYW5kZWRfZ3JvdXBzWzJdfT5cbiAgICAgICAgICA8VGV4dCB0ZW1wbGF0ZT1cImxhYmVsXCI+TGV2ZWwgMjwvVGV4dD5cbiAgICAgICAgICA8VGV4dD5JdGVtIDI8L1RleHQ+XG4gICAgICAgIDwvRGlzY2xvc3VyZUdyb3VwPlxuICAgICAgPC9EaXNjbG9zdXJlR3JvdXA+XG4gICAgPC9MaXN0PlxuICAgIFwiXCJcIlxuICBlbmRcblxuICBAaW1wbCB0cnVlXG4gIGRlZiBoYW5kbGVfZXZlbnQoXCJ0b2dnbGUtXCIgPD4gbGV2ZWwsICV7XCJpcy1leHBhbmRlZFwiID0+IGlzX2V4cGFuZGVkfSwgc29ja2V0KSBkb1xuICAgIGxldmVsID0gU3RyaW5nLnRvX2ludGVnZXIobGV2ZWwpXG5cbiAgICB7Om5vcmVwbHksXG4gICAgIGFzc2lnbihcbiAgICAgICBzb2NrZXQsXG4gICAgICAgOmV4cGFuZGVkX2dyb3VwcyxcbiAgICAgICBNYXAucmVwbGFjZSEoc29ja2V0LmFzc2lnbnMuZXhwYW5kZWRfZ3JvdXBzLCBsZXZlbCwgaXNfZXhwYW5kZWQpXG4gICAgICl9XG4gIGVuZFxuZW5kIiwicGF0aCI6Ii8ifQ","chunks":[[0,109],[111,1005],[1118,45],[1165,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule Server.MultipleExpandingListsLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :expanded_groups, %{1 => false, 2 => false})}
  end

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <List>
      <DisclosureGroup phx-change="toggle-1" is-expanded={@expanded_groups[1]}>
        <Text template="label">Level 1</Text>
        <Text>Item 1</Text>
        <DisclosureGroup phx-change="toggle-2" is-expanded={@expanded_groups[2]}>
          <Text template="label">Level 2</Text>
          <Text>Item 2</Text>
        </DisclosureGroup>
      </DisclosureGroup>
    </List>
    """
  end

  @impl true
  def handle_event("toggle-" <> level, %{"is-expanded" => is_expanded}, socket) do
    level = String.to_integer(level)

    {:noreply,
     assign(
       socket,
       :expanded_groups,
       Map.replace!(socket.assigns.expanded_groups, level, is_expanded)
     )}
  end
end
```

## Controls and Indicators

In Phoenix, the `phx-change` event must be applied to a parent form. However in SwiftUI there is no similar concept of forms. Instead, SwiftUI provides [Controls and Indicators](https://developer.apple.com/documentation/swiftui/controls-and-indicators) views. We can apply the `phx-change` binding to any of these views.

Once bound, the SwiftUI view will send a message to the LiveView anytime the control or indicator changes its value.

The params of the message are based on the name of the [Binding](https://developer.apple.com/documentation/swiftui/binding) argument of the view's initializer in SwiftUI.

<!-- livebook:{"break_markdown":true} -->

### Event Value Bindings

Many views use the `value` binding argument, so event params are generally sent as `%{"value" => value}`. However, certain views such as `TextField` and `Toggle` deviate from this pattern because SwiftUI uses a different `value` binding argument. For example, the `TextField` view uses `text` to bind its value, so it sends the event params as `%{"text" => value}`.

When in doubt, you can connect the event handler and inspect the params to confirm the shape of map.

## Text Field

The following example shows you how to connect a SwiftUI [TextField](https://developer.apple.com/documentation/swiftui/textfield) with a `phx-change` event binding to a corresponding event handler.

Evaluate the example and enter some text in your iOS simulator. Notice the inspected `params` appear in the server logs in the console below as a map of `%{"text" => value}`.

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5UZXh0RmllbGRMaXZlIGRvXG4gIHVzZSBQaG9lbml4LkxpdmVWaWV3XG4gIHVzZSBMaXZlVmlld05hdGl2ZS5MaXZlVmlld1xuXG4gIEBpbXBsIHRydWVcbiAgZGVmIHJlbmRlcigle2Zvcm1hdDogOnN3aWZ0dWl9ID0gYXNzaWducykgZG9cbiAgICB+U1dJRlRVSVwiXCJcIlxuICAgIDxUZXh0RmllbGQgcGh4LWNoYW5nZT1cInR5cGVcIj5FbnRlciB0ZXh0IGhlcmU8L1RleHRGaWVsZD5cbiAgICBcIlwiXCJcbiAgZW5kXG5cbiAgQGltcGwgdHJ1ZVxuICBkZWYgaGFuZGxlX2V2ZW50KFwidHlwZVwiLCBwYXJhbXMsIHNvY2tldCkgZG9cbiAgICBJTy5pbnNwZWN0KHBhcmFtcywgbGFiZWw6IFwicGFyYW1zXCIpXG4gICAgezpub3JlcGx5LCBzb2NrZXR9XG4gIGVuZFxuZW5kIiwicGF0aCI6Ii8ifQ","chunks":[[0,109],[111,371],[484,45],[531,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule Server.TextFieldLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <TextField phx-change="type">Enter text here</TextField>
    """
  end

  @impl true
  def handle_event("type", params, socket) do
    IO.inspect(params, label: "params")
    {:noreply, socket}
  end
end
```

### Storing TextField Values in the Socket

The following example demonstrates how to set/access a TextField's value by controlling it using the socket assigns.

This pattern is useful when rendering the TextField's value elsewhere on the page, using the `TextField` view's value in other event handler logic, or to set an initial value.

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5Db250cm9sbGVkVGV4dEZpZWxkTGl2ZSBkb1xuICB1c2UgUGhvZW5peC5MaXZlVmlld1xuICB1c2UgTGl2ZVZpZXdOYXRpdmUuTGl2ZVZpZXdcblxuICBAaW1wbCB0cnVlXG4gIGRlZiBtb3VudChfcGFyYW1zLCBfc2Vzc2lvbiwgc29ja2V0KSBkb1xuICAgIHs6b2ssIGFzc2lnbihzb2NrZXQsIDp0ZXh0LCBcImluaXRpYWwgdmFsdWVcIil9XG4gIGVuZFxuXG4gIEBpbXBsIHRydWVcbiAgZGVmIHJlbmRlcigle2Zvcm1hdDogOnN3aWZ0dWl9ID0gYXNzaWducykgZG9cbiAgICB+U1dJRlRVSVwiXCJcIlxuICAgIDxUZXh0RmllbGQgcGh4LWNoYW5nZT1cInR5cGVcIiB0ZXh0PXtAdGV4dH0+RW50ZXIgdGV4dCBoZXJlPC9UZXh0RmllbGQ+XG4gICAgPEJ1dHRvbiBwaHgtY2xpY2s9XCJwcmV0dHktcHJpbnRcIj5Mb2cgVGV4dCBWYWx1ZTwvQnV0dG9uPlxuICAgIDxUZXh0PlRoZSBjdXJyZW50IHZhbHVlOiA8JT0gQHRleHQgJT48L1RleHQ+XG4gICAgXCJcIlwiXG4gIGVuZFxuXG4gIEBpbXBsIHRydWVcbiAgZGVmIGhhbmRsZV9ldmVudChcInR5cGVcIiwgJXtcInRleHRcIiA9PiB0ZXh0fSwgc29ja2V0KSBkb1xuICAgIHs6bm9yZXBseSwgYXNzaWduKHNvY2tldCwgOnRleHQsIHRleHQpfVxuICBlbmRcblxuICBkZWYgaGFuZGxlX2V2ZW50KFwicHJldHR5LXByaW50XCIsIF9wYXJhbXMsIHNvY2tldCkgZG9cbiAgICBJTy5wdXRzKFwiXCJcIlxuICAgID09PT09PT09PT09PT09PT09PVxuICAgICN7c29ja2V0LmFzc2lnbnMudGV4dH1cbiAgICA9PT09PT09PT09PT09PT09PT1cbiAgICBcIlwiXCIpXG4gICAgezpub3JlcGx5LCBzb2NrZXR9XG4gIGVuZFxuZW5kIiwicGF0aCI6Ii8ifQ","chunks":[[0,109],[111,791],[904,45],[951,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule Server.ControlledTextFieldLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :text, "initial value")}
  end

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <TextField phx-change="type" text={@text}>Enter text here</TextField>
    <Button phx-click="pretty-print">Log Text Value</Button>
    <Text>The current value: <%= @text %></Text>
    """
  end

  @impl true
  def handle_event("type", %{"text" => text}, socket) do
    {:noreply, assign(socket, :text, text)}
  end

  def handle_event("pretty-print", _params, socket) do
    IO.puts("""
    ==================
    #{socket.assigns.text}
    ==================
    """)

    {:noreply, socket}
  end
end
```

## Slider

This code example renders a SwiftUI [Slider](https://developer.apple.com/documentation/swiftui/slider). It triggers the change event when the slider is moved and sends a `"slide"` message. The `"slide"` event handler then logs the value to the console.

Evaluate the example and enter some text in your iOS simulator. Notice the inspected `params` appear in the console below as a map of `%{"value" => value}`.

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5TbGlkZXJMaXZlIGRvXG4gIHVzZSBQaG9lbml4LkxpdmVWaWV3XG4gIHVzZSBMaXZlVmlld05hdGl2ZS5MaXZlVmlld1xuXG4gIEBpbXBsIHRydWVcbiAgZGVmIHJlbmRlcigle2Zvcm1hdDogOnN3aWZ0dWl9ID0gYXNzaWducykgZG9cbiAgICB+U1dJRlRVSVwiXCJcIlxuICAgIDxTbGlkZXJcbiAgICAgIGxvd2VyLWJvdW5kPXswfVxuICAgICAgdXBwZXItYm91bmQ9ezEwfVxuICAgICAgc3RlcD17MX1cbiAgICAgIHBoeC1jaGFuZ2U9XCJzbGlkZVwiXG4gICAgPlxuICAgICAgPFRleHQgdGVtcGxhdGU9ezpsYWJlbH0+UGVyY2VudCBDb21wbGV0ZWQ8L1RleHQ+XG4gICAgICA8VGV4dCB0ZW1wbGF0ZT17OlwibWluaW11bS12YWx1ZS1sYWJlbFwifT4wJTwvVGV4dD5cbiAgICAgIDxUZXh0IHRlbXBsYXRlPXs6XCJtYXhpbXVtLXZhbHVlLWxhYmVsXCJ9PjEwMCU8L1RleHQ+XG4gICAgPC9TbGlkZXI+XG4gICAgXCJcIlwiXG4gIGVuZFxuXG4gIGRlZiBoYW5kbGVfZXZlbnQoXCJzbGlkZVwiLCBwYXJhbXMsIHNvY2tldCkgZG9cbiAgICBJTy5pbnNwZWN0KHBhcmFtcywgbGFiZWw6IFwiU2xpZGUgUGFyYW1zXCIpXG4gICAgezpub3JlcGx5LCBzb2NrZXR9XG4gIGVuZFxuZW5kIiwicGF0aCI6Ii8ifQ","chunks":[[0,109],[111,587],[700,45],[747,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule Server.SliderLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <Slider
      lower-bound={0}
      upper-bound={10}
      step={1}
      phx-change="slide"
    >
      <Text template={:label}>Percent Completed</Text>
      <Text template={:"minimum-value-label"}>0%</Text>
      <Text template={:"maximum-value-label"}>100%</Text>
    </Slider>
    """
  end

  def handle_event("slide", params, socket) do
    IO.inspect(params, label: "Slide Params")
    {:noreply, socket}
  end
end
```

## Stepper

This code example renders a SwiftUI [Stepper](https://developer.apple.com/documentation/swiftui/stepper). It triggers the change event and sends a `"change-tickets"` message when the stepper increments or decrements. The `"change-tickets"` event handler then updates the number of tickets stored in state, which appears in the UI.

Evaluate the example and increment/decrement the step.

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5UaWNrZXRzTGl2ZSBkb1xuICB1c2UgUGhvZW5peC5MaXZlVmlld1xuICB1c2UgTGl2ZVZpZXdOYXRpdmUuTGl2ZVZpZXdcblxuICBAaW1wbCB0cnVlXG4gIGRlZiBtb3VudChfcGFyYW1zLCBfc2Vzc2lvbiwgc29ja2V0KSBkb1xuICAgIHs6b2ssIGFzc2lnbihzb2NrZXQsIDp0aWNrZXRzLCAwKX1cbiAgZW5kXG5cbiAgQGltcGwgdHJ1ZVxuICBkZWYgcmVuZGVyKCV7Zm9ybWF0OiA6c3dpZnR1aX0gPSBhc3NpZ25zKSBkb1xuICAgIH5TV0lGVFVJXCJcIlwiXG4gICAgPFN0ZXBwZXJcbiAgICAgIGxvd2VyLWJvdW5kPXswfVxuICAgICAgdXBwZXItYm91bmQ9ezE2fVxuICAgICAgc3RlcD17MX1cbiAgICAgIHBoeC1jaGFuZ2U9XCJjaGFuZ2UtdGlja2V0c1wiXG4gICAgPlxuICAgICAgVGlja2V0cyA8JT0gQHRpY2tldHMgJT5cbiAgICA8L1N0ZXBwZXI+XG4gICAgXCJcIlwiXG4gIGVuZFxuXG4gIGRlZiBoYW5kbGVfZXZlbnQoXCJjaGFuZ2UtdGlja2V0c1wiLCAle1widmFsdWVcIiA9PiB0aWNrZXRzfSwgc29ja2V0KSBkb1xuICAgIHs6bm9yZXBseSwgYXNzaWduKHNvY2tldCwgOnRpY2tldHMsIHRpY2tldHMpfVxuICBlbmRcbmVuZCIsInBhdGgiOiIvIn0","chunks":[[0,109],[111,566],[679,45],[726,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule Server.TicketsLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :tickets, 0)}
  end

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <Stepper
      lower-bound={0}
      upper-bound={16}
      step={1}
      phx-change="change-tickets"
    >
      Tickets <%= @tickets %>
    </Stepper>
    """
  end

  def handle_event("change-tickets", %{"value" => tickets}, socket) do
    {:noreply, assign(socket, :tickets, tickets)}
  end
end
```

## Toggle

This code example renders a SwiftUI [Toggle](https://developer.apple.com/documentation/swiftui/toggle). It triggers the change event and sends a `"toggle"` message when toggled. The `"toggle"` event handler then updates the `:on` field in state, which allows the `Toggle` view to be toggled on. Without providing the `is-on` attribute, the `Toggle` view could not be flipped on and off.

Evaluate the example below and click on the toggle.

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5Ub2dnbGVMaXZlIGRvXG4gIHVzZSBQaG9lbml4LkxpdmVWaWV3XG4gIHVzZSBMaXZlVmlld05hdGl2ZS5MaXZlVmlld1xuXG4gIGRlZiBtb3VudChfcGFyYW1zLCBfc2Vzc2lvbiwgc29ja2V0KSBkb1xuICAgIHs6b2ssIGFzc2lnbihzb2NrZXQsIDpvbiwgZmFsc2UpfVxuICBlbmRcblxuICBAaW1wbCB0cnVlXG4gIGRlZiByZW5kZXIoJXtmb3JtYXQ6IDpzd2lmdHVpfSA9IGFzc2lnbnMpIGRvXG4gICAgflNXSUZUVUlcIlwiXCJcbiAgICA8VG9nZ2xlIHBoeC1jaGFuZ2U9XCJ0b2dnbGVcIiBpcy1vbj17QG9ufT5Pbi9PZmY8L1RvZ2dsZT5cbiAgICBcIlwiXCJcbiAgZW5kXG5cbiAgZGVmIGhhbmRsZV9ldmVudChcInRvZ2dsZVwiLCAle1wiaXMtb25cIiA9PiBvbn0sIHNvY2tldCkgZG9cbiAgICB7Om5vcmVwbHksIGFzc2lnbihzb2NrZXQsIDpvbiwgb24pfVxuICBlbmRcbmVuZCIsInBhdGgiOiIvIn0","chunks":[[0,109],[111,430],[543,45],[590,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule Server.ToggleLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :on, false)}
  end

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <Toggle phx-change="toggle" is-on={@on}>On/Off</Toggle>
    """
  end

  def handle_event("toggle", %{"is-on" => on}, socket) do
    {:noreply, assign(socket, :on, on)}
  end
end
```

## DatePicker

The SwiftUI Date Picker provides a native view for selecting a date. The date is selected by the user and sent back as a string.

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5EYXRlUGlja2VyTGl2ZSBkb1xuICB1c2UgUGhvZW5peC5MaXZlVmlld1xuICB1c2UgTGl2ZVZpZXdOYXRpdmUuTGl2ZVZpZXdcblxuICBkZWYgbW91bnQoX3BhcmFtcywgX3Nlc3Npb24sIHNvY2tldCkgZG9cbiAgICB7Om9rLCBhc3NpZ24oc29ja2V0LCA6ZGF0ZSwgbmlsKX1cbiAgZW5kXG5cbiAgQGltcGwgdHJ1ZVxuICBkZWYgcmVuZGVyKCV7Zm9ybWF0OiA6c3dpZnR1aX0gPSBhc3NpZ25zKSBkb1xuICAgIH5TV0lGVFVJXCJcIlwiXG4gICAgPERhdGVQaWNrZXIgcGh4LWNoYW5nZT1cInBpY2stZGF0ZVwiLz5cbiAgICBcIlwiXCJcbiAgZW5kXG5cbiAgZGVmIGhhbmRsZV9ldmVudChcInBpY2stZGF0ZVwiLCBwYXJhbXMsIHNvY2tldCkgZG9cbiAgICBJTy5pbnNwZWN0KHBhcmFtcywgbGFiZWw6IFwiRGF0ZSBQYXJhbXNcIilcbiAgICB7Om5vcmVwbHksIHNvY2tldH1cbiAgZW5kXG5lbmQiLCJwYXRoIjoiLyJ9","chunks":[[0,109],[111,436],[549,45],[596,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule Server.DatePickerLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :date, nil)}
  end

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <DatePicker phx-change="pick-date"/>
    """
  end

  def handle_event("pick-date", params, socket) do
    IO.inspect(params, label: "Date Params")
    {:noreply, socket}
  end
end
```

### Parsing Dates

The date from the `DatePicker` is in iso8601 format. You can use the `from_iso8601` function to parse this string into a `DateTime` struct.

```elixir
iso8601 = "2024-01-17T20:51:00.000Z"

DateTime.from_iso8601(iso8601)
```

### Your Turn: Displayed Components

The `DatePicker` view accepts a `displayed-components` attribute with the value of `"hour-and-minute"` or `"date"` to only display one of the two components. By default, the value is `"all"`.

You're going to change the `displayed-components` attribute in the example below to see both of these options. Change `"all"` to `"date"`, then to `"hour-and-minute"`. Re-evaluate the cell between changes and see the updated UI.

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5EYXRlUGlja2VyTGl2ZSBkb1xuICB1c2UgUGhvZW5peC5MaXZlVmlld1xuICB1c2UgTGl2ZVZpZXdOYXRpdmUuTGl2ZVZpZXdcblxuICBkZWYgbW91bnQoX3BhcmFtcywgX3Nlc3Npb24sIHNvY2tldCkgZG9cbiAgICB7Om9rLCBhc3NpZ24oc29ja2V0LCA6ZGF0ZSwgbmlsKX1cbiAgZW5kXG5cbiAgQGltcGwgdHJ1ZVxuICBkZWYgcmVuZGVyKCV7Zm9ybWF0OiA6c3dpZnR1aX0gPSBhc3NpZ25zKSBkb1xuICAgIH5TV0lGVFVJXCJcIlwiXG4gICAgPERhdGVQaWNrZXIgZGlzcGxheWVkLWNvbXBvbmVudHM9XCJhbGxcIiBwaHgtY2hhbmdlPVwicGljay1kYXRlXCIvPlxuICAgIFwiXCJcIlxuICBlbmRcblxuICBkZWYgaGFuZGxlX2V2ZW50KFwicGljay1kYXRlXCIsIHBhcmFtcywgc29ja2V0KSBkb1xuICAgIHs6bm9yZXBseSwgc29ja2V0fVxuICBlbmRcbmVuZCIsInBhdGgiOiIvIn0","chunks":[[0,109],[111,418],[531,45],[578,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule Server.DatePickerLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :date, nil)}
  end

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <DatePicker displayed-components="all" phx-change="pick-date"/>
    """
  end

  def handle_event("pick-date", params, socket) do
    {:noreply, socket}
  end
end
```

## Small Project: Todo List

Using the previous examples as inspiration, you're going to create a todo list.

**Requirements**

* Items should be `Text` views rendered within a `List` view.
* Item ids should be stored in state as a list of integers i.e. `[1, 2, 3, 4]`
* Use a `TextField` to provide the name of the next added todo item.
* An add item `Button` should add items to the list of integers in state when pressed.
* A delete item `Button` should remove the currently selected item from the list of integers in state when pressed.

### Example Solution

```elixir
defmodule Server.TodoListLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, items: [], selection: "None", item_name: "", next_item_id: 1)}
  end

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <!-- The  -->
    <TextField phx-change="type-name" text={@item_name}>Todo...</TextField>
    <Button phx-click="add-item">Add Item</Button>
    <Button phx-click="delete-item">Delete Item</Button>
    <List selection={@selection} phx-change="selection-changed">
      <%= for {id, content} <- @items do %>
        <Text id={id}><%= content %></Text>
      <% end %>
    </List>
    """
  end

  @impl true
  def handle_event("type-name", %{"text" => name}, socket) do
    {:noreply, assign(socket, :item_name, name)}
  end

  def handle_event("add-item", _params, socket) do
    updated_items = [
      {"item-#{socket.assigns.next_item_id}", socket.assigns.item_name}
      | socket.assigns.items
    ]

    {:noreply,
     assign(socket,
       item_name: "",
       items: updated_items,
       next_item_id: socket.assigns.next_item_id + 1
     )}
  end

  def handle_event("delete-item", _params, socket) do
    updated_items =
      Enum.reject(socket.assigns.items, fn {id, _name} -> id == socket.assigns.selection end)
    {:noreply, assign(socket, :items, updated_items)}
  end

  def handle_event("selection-changed", %{"selection" => selection}, socket) do
    {:noreply, assign(socket, selection: selection)}
  end
end
```



<!-- livebook:{"break_markdown":true} -->

### Enter Your Solution Below

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5Ub2RvTGlzdExpdmUgZG9cbiAgdXNlIFBob2VuaXguTGl2ZVZpZXdcbiAgdXNlIExpdmVWaWV3TmF0aXZlLkxpdmVWaWV3XG5cbiAgIyBEZWZpbmUgeW91ciBtb3VudC8zIGNhbGxiYWNrc1xuXG4gICMgRGVmaW5lIHlvdXIgcmVuZGVyLzMgY2FsbGJhY2tcblxuICAjIERlZmluZSBhbnkgaGFuZGxlX2V2ZW50LzMgY2FsbGJhY2tzXG5lbmQiLCJwYXRoIjoiLyJ9","chunks":[[0,109],[111,200],[313,45],[360,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule Server.TodoListLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  # Define your mount/3 callbacks

  # Define your render/3 callback

  # Define any handle_event/3 callbacks
end
```