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

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5DbGlja0V4YW1wbGVMaXZlIGRvXG4gIHVzZSBQaG9lbml4LkxpdmVWaWV3XG4gIHVzZSBMaXZlVmlld05hdGl2ZS5MaXZlVmlld1xuXG4gIEBpbXBsIHRydWVcbiAgZGVmIHJlbmRlcigle2Zvcm1hdDogOnN3aWZ0dWl9ID0gYXNzaWducykgZG9cbiAgICB+U1dJRlRVSVwiXCJcIlxuICAgIDxCdXR0b24gcGh4LWNsaWNrPVwicGluZ1wiPlByZXNzIG1lIG9uIG5hdGl2ZSE8L0J1dHRvbj5cbiAgICBcIlwiXCJcbiAgZW5kXG5cbiAgQGltcGwgdHJ1ZVxuICBkZWYgcmVuZGVyKGFzc2lnbnMpIGRvXG4gICAgfkhcIlwiXCJcbiAgICA8YnV0dG9uIHBoeC1jbGljaz1cInBpbmdcIj5DbGljayBtZSBvbiB3ZWIhPC9idXR0b24+XG4gICAgXCJcIlwiXG4gIGVuZFxuXG4gIGRlZiBoYW5kbGVfZXZlbnQoXCJwaW5nXCIsIF9wYXJhbXMsIHNvY2tldCkgZG9cbiAgICBJTy5wdXRzKFwiUG9uZ1wiKVxuICAgIHs6bm9yZXBseSwgc29ja2V0fVxuICBlbmRcbmVuZCIsInBhdGgiOiIvIn0","chunks":[[0,109],[111,457],[570,45],[617,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

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

  def handle_event("ping", _params, socket) do
    IO.puts("Pong")
    {:noreply, socket}
  end
end
```

### Click Events Updating State

Event handlers in LiveView can update the LiveView's state in the socket.

Evaluate the cell below to see an example of incrementing a count.

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5Db3VudGVyTGl2ZSBkb1xuICB1c2UgUGhvZW5peC5MaXZlVmlld1xuICB1c2UgTGl2ZVZpZXdOYXRpdmUuTGl2ZVZpZXdcblxuICBAaW1wbCB0cnVlXG4gIGRlZiBtb3VudChfcGFyYW1zLCBfc2Vzc2lvbiwgc29ja2V0KSBkb1xuICAgIHs6b2ssIGFzc2lnbihzb2NrZXQsIDpjb3VudCwgMCl9XG4gIGVuZFxuXG4gIEBpbXBsIHRydWVcbiAgZGVmIHJlbmRlcigle2Zvcm1hdDogOnN3aWZ0dWl9ID0gYXNzaWducykgZG9cbiAgICB+U1dJRlRVSVwiXCJcIlxuICAgIDxCdXR0b24gcGh4LWNsaWNrPVwiaW5jcmVtZW50XCI+Q291bnQ6IDwlPSBAY291bnQgJT48L0J1dHRvbj5cbiAgICBcIlwiXCJcbiAgZW5kXG5cbiAgZGVmIHJlbmRlcihhc3NpZ25zKSBkb1xuICAgIH5IXCJcIlwiXG4gICAgPGJ1dHRvbiBwaHgtY2xpY2s9XCJpbmNyZW1lbnRcIj5Db3VudDogPCU9IEBjb3VudCAlPjwvYnV0dG9uPlxuICAgIFwiXCJcIlxuICBlbmRcblxuICBkZWYgaGFuZGxlX2V2ZW50KFwiaW5jcmVtZW50XCIsIF9wYXJhbXMsIHNvY2tldCkgZG9cbiAgICB7Om5vcmVwbHksIGFzc2lnbihzb2NrZXQsIDpjb3VudCwgc29ja2V0LmFzc2lnbnMuY291bnQgKyAxKX1cbiAgZW5kXG5lbmQiLCJwYXRoIjoiLyJ9","chunks":[[0,109],[111,580],[693,45],[740,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

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

  def handle_event("increment", _params, socket) do
    {:noreply, assign(socket, :count, socket.assigns.count + 1)}
  end
end
```

## Selectable Lists

`List` views support selecting items within the list based on their id. To select an item, provide the `selection` attribute with the item's id.

Pressing a child item in the `List` on a native device triggers the `phx-change` event. In the example below we've bound the `phx-change` event to send the `"selection-changed"` event. This event is then handled by the `handle_event/3` callback function and used to change the selected item.

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5TZWxlY3Rpb25MaXZlIGRvXG4gIHVzZSBQaG9lbml4LkxpdmVWaWV3XG4gIHVzZSBMaXZlVmlld05hdGl2ZS5MaXZlVmlld1xuXG4gIGRlZiBtb3VudChfcGFyYW1zLCBfc2Vzc2lvbiwgc29ja2V0KSBkb1xuICAgIHs6b2ssIGFzc2lnbihzb2NrZXQsIHNlbGVjdGlvbjogXCIxXCIpfVxuICBlbmRcblxuICBAaW1wbCB0cnVlXG4gIGRlZiByZW5kZXIoYXNzaWducykgZG9cbiAgICB+U1dJRlRVSVwiXCJcIlxuICAgIDxMaXN0IHNlbGVjdGlvbj17QHNlbGVjdGlvbn0gcGh4LWNoYW5nZT1cInNlbGVjdGlvbi1jaGFuZ2VkXCI+XG4gICAgICA8JT0gZm9yIGkgPC0gMS4uMTAgZG8gJT5cbiAgICAgICAgPFRleHQgaWQ9e1wiI3tpfVwifT5JdGVtIDwlPSBpICU+PC9UZXh0PlxuICAgICAgPCUgZW5kICU+XG4gICAgPC9MaXN0PlxuICAgIFwiXCJcIlxuICBlbmRcblxuICBkZWYgaGFuZGxlX2V2ZW50KFwic2VsZWN0aW9uLWNoYW5nZWRcIiwgJXsgXCJzZWxlY3Rpb25cIiA9PiBzZWxlY3Rpb24gfSwgc29ja2V0KSBkb1xuICAgIHs6bm9yZXBseSwgYXNzaWduKHNvY2tldCwgc2VsZWN0aW9uOiBzZWxlY3Rpb24pfVxuICBlbmRcbmVuZCIsInBhdGgiOiIvIn0","chunks":[[0,109],[111,563],[676,45],[723,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule Server.SelectionLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  def mount(_params, _session, socket) do
    {:ok, assign(socket, selection: "1")}
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

## Controls and Indicators

In Phoenix, the `phx-change` event must be applied to a parent form. However in SwiftUI there is no similar concept of forms. Instead, SwiftUI provides [Controls and Indicators](https://developer.apple.com/documentation/swiftui/controls-and-indicators) views. We can apply the `phx-change` binding to any of these views.

Once bound, the SwiftUI view will send a message to the LiveView anytime the control or indicator changes its value.

The params of the message are based on the name of the [Binding](https://developer.apple.com/documentation/swiftui/binding) argument of the view's initializer in SwiftUI.

For example, many views use the `value` binding argument, so the params will be sent as `%{"value" => value}`. However, certain views such as `TextField` and `Toggle` deviate from this pattern as you can see in the examples below.

<!-- livebook:{"branch_parent_index":4} -->

## Text Field

This code example defines a LiveView module that renders a SwiftUI TextField. It triggers the change event when text is entered and logs the entered text to the console.

Evaluate the example and enter some text in your iOS simulator. Notice the inspected `params` appear in the console below as a map of `%{"text" => value}`.

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5UZXh0RmllbGRMaXZlIGRvXG4gIHVzZSBQaG9lbml4LkxpdmVWaWV3XG4gIHVzZSBMaXZlVmlld05hdGl2ZS5MaXZlVmlld1xuXG4gIEBpbXBsIHRydWVcbiAgZGVmIHJlbmRlcigle2Zvcm1hdDogOnN3aWZ0dWl9ID0gYXNzaWducykgZG9cbiAgICB+U1dJRlRVSVwiXCJcIlxuICAgIDxUZXh0RmllbGQgcGh4LWNoYW5nZT1cInR5cGVcIj5FbnRlciB0ZXh0IGhlcmU8L1RleHRGaWVsZD5cbiAgICBcIlwiXCJcbiAgZW5kXG5cbiAgZGVmIHJlbmRlcihhc3NpZ25zKSBkb1xuICAgIH5IXCJcIlwiXG4gICAgXG4gICAgXCJcIlwiXG4gIGVuZFxuXG4gIGRlZiBoYW5kbGVfZXZlbnQoXCJ0eXBlXCIsICV7XCJ0ZXh0XCIgPT4gdmFsdWV9LCBzb2NrZXQpIGRvXG4gICAgSU8uaW5zcGVjdCh2YWx1ZSlcbiAgICB7Om5vcmVwbHksIHNvY2tldH1cbiAgZW5kXG5lbmQiLCJwYXRoIjoiLyJ9","chunks":[[0,109],[111,407],[520,45],[567,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

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

  def render(assigns) do
    ~H"""

    """
  end

  def handle_event("type", %{"text" => value}, socket) do
    IO.inspect(value)
    {:noreply, socket}
  end
end
```

<!-- livebook:{"branch_parent_index":4} -->

## Slider

This code example renders a SwiftUI [Slider](https://developer.apple.com/documentation/swiftui/slider). It triggers the change event when the slider is moved and sends a `"slide"` message. The `"slide"` event handler then logs the value to the console.

Evaluate the example and enter some text in your iOS simulator. Notice the inspected `params` appear in the console below as a map of `%{"value" => value}`.

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5Ib21lTGl2ZSBkb1xuICB1c2UgUGhvZW5peC5MaXZlVmlld1xuICB1c2UgTGl2ZVZpZXdOYXRpdmUuTGl2ZVZpZXdcblxuICBAaW1wbCB0cnVlXG4gIGRlZiByZW5kZXIoJXtmb3JtYXQ6IDpzd2lmdHVpfSA9IGFzc2lnbnMpIGRvXG4gICAgflNXSUZUVUlcIlwiXCJcbiAgICA8U2xpZGVyXG4gICAgICBsb3dlci1ib3VuZD17MH1cbiAgICAgIHVwcGVyLWJvdW5kPXsxMH1cbiAgICAgIHN0ZXA9ezF9XG4gICAgICBwaHgtY2hhbmdlPVwic2xpZGVcIlxuICAgID5cbiAgICAgIDxUZXh0IHRlbXBsYXRlPXs6bGFiZWx9PlBlcmNlbnQgQ29tcGxldGVkPC9UZXh0PlxuICAgICAgPFRleHQgdGVtcGxhdGU9ezpcIm1pbmltdW0tdmFsdWUtbGFiZWxcIn0+MCU8L1RleHQ+XG4gICAgICA8VGV4dCB0ZW1wbGF0ZT17OlwibWF4aW11bS12YWx1ZS1sYWJlbFwifT4xMDAlPC9UZXh0PlxuICAgIDwvU2xpZGVyPlxuICAgIFwiXCJcIlxuICBlbmRcblxuICBkZWYgcmVuZGVyKGFzc2lnbnMpIGRvXG4gICAgfkhcIlwiXCJcbiAgICBcIlwiXCJcbiAgZW5kXG5cbiAgZGVmIGhhbmRsZV9ldmVudChcInNsaWRlXCIsIHBhcmFtcywgc29ja2V0KSBkb1xuICAgIElPLmluc3BlY3QocGFyYW1zKVxuICAgIHs6bm9yZXBseSwgc29ja2V0fVxuICBlbmRcbmVuZCIsInBhdGgiOiIvIn0","chunks":[[0,109],[111,612],[725,45],[772,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule Server.HomeLive do
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

  def render(assigns) do
    ~H"""
    """
  end

  def handle_event("slide", params, socket) do
    IO.inspect(params)
    {:noreply, socket}
  end
end
```

<!-- livebook:{"branch_parent_index":4} -->

## Stepper

This code example renders a SwiftUI [Slider](https://developer.apple.com/documentation/swiftui/slider). It triggers the change event and sends a `"change-tickets"` message when the stepper increments or decrements. The `"change-tickets"` event handler then updates the number of tickets stored in state, which appears in the UI.

Evaluate the example and increment/decrement the step.

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5UaWNrZXRzTGl2ZSBkb1xuICB1c2UgUGhvZW5peC5MaXZlVmlld1xuICB1c2UgTGl2ZVZpZXdOYXRpdmUuTGl2ZVZpZXdcblxuICBAaW1wbCB0cnVlXG4gIGRlZiBtb3VudChfcGFyYW1zLCBfc2Vzc2lvbiwgc29ja2V0KSBkb1xuICAgIHs6b2ssIGFzc2lnbihzb2NrZXQsIDp0aWNrZXRzLCAwKX1cbiAgZW5kXG5cbiAgQGltcGwgdHJ1ZVxuICBkZWYgcmVuZGVyKCV7Zm9ybWF0OiA6c3dpZnR1aX0gPSBhc3NpZ25zKSBkb1xuICAgIH5TV0lGVFVJXCJcIlwiXG4gICAgPFN0ZXBwZXJcbiAgICAgIGxvd2VyLWJvdW5kPXswfVxuICAgICAgdXBwZXItYm91bmQ9ezE2fVxuICAgICAgc3RlcD17MX1cbiAgICAgIHBoeC1jaGFuZ2U9XCJjaGFuZ2UtdGlja2V0c1wiXG4gICAgPlxuICAgICAgVGlja2V0cyA8JT0gQHRpY2tldHMgJT5cbiAgICA8L1N0ZXBwZXI+XG4gICAgXCJcIlwiXG4gIGVuZFxuXG4gIGRlZiByZW5kZXIoYXNzaWducykgZG9cbiAgICB+SFwiXCJcIlxuICAgIDxwPkhlbGxvIGZyb20gTGl2ZVZpZXchPC9wPlxuICAgIFwiXCJcIlxuICBlbmRcblxuICBkZWYgaGFuZGxlX2V2ZW50KFwiY2hhbmdlLXRpY2tldHNcIiwgJXtcInZhbHVlXCIgPT4gdGlja2V0c30sIHNvY2tldCkgZG9cbiAgICB7Om5vcmVwbHksIGFzc2lnbihzb2NrZXQsIDp0aWNrZXRzLCB0aWNrZXRzKX1cbiAgZW5kXG5lbmQiLCJwYXRoIjoiLyJ9","chunks":[[0,109],[111,648],[761,45],[808,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

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

  def render(assigns) do
    ~H"""
    <p>Hello from LiveView!</p>
    """
  end

  def handle_event("change-tickets", %{"value" => tickets}, socket) do
    {:noreply, assign(socket, :tickets, tickets)}
  end
end
```

<!-- livebook:{"branch_parent_index":4} -->

## Toggle

This code example renders a SwiftUI [Toggle](https://developer.apple.com/documentation/swiftui/toggle). It triggers the change event and sends a `"toggle"` message when toggled. The `"toggle"` event handler then updates the `:on` field in state, which allows the `Toggle` view to be toggled on. Without providing the `is-on` attribute, the `Toggle` view could not be flipped on and off.

Evaluate the example below and click on the toggle.

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5Ub2dnbGVMaXZlIGRvXG4gIHVzZSBQaG9lbml4LkxpdmVWaWV3XG4gIHVzZSBMaXZlVmlld05hdGl2ZS5MaXZlVmlld1xuXG4gIGRlZiBtb3VudChfcGFyYW1zLCBfc2Vzc2lvbiwgc29ja2V0KSBkb1xuICAgIHs6b2ssIGFzc2lnbihzb2NrZXQsIDpvbiwgZmFsc2UpfVxuICBlbmRcblxuICBAaW1wbCB0cnVlXG4gIGRlZiByZW5kZXIoJXtmb3JtYXQ6IDpzd2lmdHVpfSA9IGFzc2lnbnMpIGRvXG4gICAgflNXSUZUVUlcIlwiXCJcbiAgICA8VG9nZ2xlIHBoeC1jaGFuZ2U9XCJ0b2dnbGVcIiBpcy1vbj17QG9ufT5Pbi9PZmY8L1RvZ2dsZT5cbiAgICBcIlwiXCJcbiAgZW5kXG5cbiAgZGVmIHJlbmRlcihhc3NpZ25zKSBkb1xuICAgIH5IXCJcIlwiXG4gICAgPHA+SGVsbG8gZnJvbSBMaXZlVmlldyE8L3A+XG4gICAgXCJcIlwiXG4gIGVuZFxuXG4gIGRlZiBoYW5kbGVfZXZlbnQoXCJ0b2dnbGVcIiwgJXtcImlzLW9uXCIgPT4gb259LCBzb2NrZXQpIGRvXG4gICAgezpub3JlcGx5LCBhc3NpZ24oc29ja2V0LCA6b24sIG9uKX1cbiAgZW5kXG5lbmQiLCJwYXRoIjoiLyJ9","chunks":[[0,109],[111,512],[625,45],[672,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

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

  def render(assigns) do
    ~H"""
    <p>Hello from LiveView!</p>
    """
  end

  def handle_event("toggle", %{"is-on" => on}, socket) do
    {:noreply, assign(socket, :on, on)}
  end
end
```

<!-- livebook:{"branch_parent_index":4} -->

## DatePicker

The SwiftUI Date Picker provides a native view for selecting a date. The date is selected by the user and sent back as a string.

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5EYXRlUGlja2VyTGl2ZSBkb1xuICB1c2UgUGhvZW5peC5MaXZlVmlld1xuICB1c2UgTGl2ZVZpZXdOYXRpdmUuTGl2ZVZpZXdcblxuICBkZWYgbW91bnQoX3BhcmFtcywgX3Nlc3Npb24sIHNvY2tldCkgZG9cbiAgICB7Om9rLCBhc3NpZ24oc29ja2V0LCA6ZGF0ZSwgbmlsKX1cbiAgZW5kXG5cbiAgQGltcGwgdHJ1ZVxuICBkZWYgcmVuZGVyKCV7Zm9ybWF0OiA6c3dpZnR1aX0gPSBhc3NpZ25zKSBkb1xuICAgIH5TV0lGVFVJXCJcIlwiXG4gICAgPERhdGVQaWNrZXIgcGh4LWNoYW5nZT1cInBpY2stZGF0ZVwiLz5cbiAgICBcIlwiXCJcbiAgZW5kXG5cbiAgZGVmIGhhbmRsZV9ldmVudChcInBpY2stZGF0ZVwiLCBwYXJhbXMsIHNvY2tldCkgZG9cbiAgICBJTy5pbnNwZWN0KHBhcmFtcylcbiAgICB7Om5vcmVwbHksIHNvY2tldH1cbiAgZW5kXG5lbmQiLCJwYXRoIjoiLyJ9","chunks":[[0,109],[111,414],[527,45],[574,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

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
    IO.inspect(params)
    {:noreply, socket}
  end
end
```

You can customize the [DatePicker](https://developer.apple.com/documentation/swiftui/datepicker) view's `displayedComponents` attribute to display different date information such as the full date or just the day and hour.

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5EYXRlUGlja2VySG91ckFuZERheUxpdmUgZG9cbiAgdXNlIFBob2VuaXguTGl2ZVZpZXdcbiAgdXNlIExpdmVWaWV3TmF0aXZlLkxpdmVWaWV3XG5cbiAgZGVmIG1vdW50KF9wYXJhbXMsIF9zZXNzaW9uLCBzb2NrZXQpIGRvXG4gICAgezpvaywgYXNzaWduKHNvY2tldCwgOmRhdGUsIG5pbCl9XG4gIGVuZFxuXG4gIEBpbXBsIHRydWVcbiAgZGVmIHJlbmRlcigle2Zvcm1hdDogOnN3aWZ0dWl9ID0gYXNzaWducykgZG9cbiAgICB+U1dJRlRVSVwiXCJcIlxuICAgIDxEYXRlUGlja2VyIHBoeC1jaGFuZ2U9XCJwaWNrLWRhdGVcIiBkaXNwbGF5ZWQtY29tcG9uZW50cz17WzpcImhvdXJBbmRNaW51dGVcIl19Lz5cbiAgICBcIlwiXCJcbiAgZW5kXG5cbiAgZGVmIGhhbmRsZV9ldmVudChcInBpY2stZGF0ZVwiLCBwYXJhbXMsIHNvY2tldCkgZG9cbiAgICBJTy5pbnNwZWN0KHBhcmFtcylcbiAgICB7Om5vcmVwbHksIHNvY2tldH1cbiAgZW5kXG5lbmQiLCJwYXRoIjoiLyJ9","chunks":[[0,109],[111,466],[579,45],[626,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule Server.DatePickerHourAndDayLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :date, nil)}
  end

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <DatePicker phx-change="pick-date" displayed-components={[:"hourAndMinute"]}/>
    """
  end

  def handle_event("pick-date", params, socket) do
    IO.inspect(params)
    {:noreply, socket}
  end
end
```

