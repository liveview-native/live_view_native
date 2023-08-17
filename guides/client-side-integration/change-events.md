# Change Events

In LiveView Native, elements can support client-side changes to their value outside of a `<form>`.
Synchronizing the values must be handled manually by the LiveView using change events.

## Client-side changes
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

## Server-side changes
Each element has an attribute that controls its value.
For example, `TextField` in the SwiftUI client uses the attribute `text`.
See the documentation for an element to find out what attribute it uses.

Whenever the attribute's value is changed, the client will update to display the new value.
No change event is sent when the server updates the value.

## Modifier change events
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