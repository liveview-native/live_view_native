# Native Navigation

[![Run in Livebook](https://livebook.dev/badge/v1/blue.svg)](https://livebook.dev/run?url=https%3A%2F%2Fraw.githubusercontent.com%2Fliveview-native%2Flive_view_native%2Fmain%2Fguides%2Fnotebooks%native-navigation.livemd)

## Overview

This guide will teach you how to create multi-page applications using LiveView Native. We will cover navigation patterns specific to native applications and how to reuse the existing navigation patterns available in LiveView. 

Before diving in, you should have a basic understanding of navigation in LiveView. You should be familiar with the [redirect/2](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#redirect/2), [push_patch/2](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#push_patch/2) and [push_navigate/2](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#push_navigate/2) functions, which are used to trigger navigation from within a LiveView. Additionally, you should know how to define routes in the router using the [live/4](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.Router.html#live/4) macro.

## NavigationStack

By default, LiveView Native applications are wrapped in a [NavigationStack](https://developer.apple.com/documentation/swiftui/navigationstack) view. Each page is "stacked" on each other, like a list of pages. To see this in action, we'll walk through an example of viewing the LiveView Native Application's source code.

Evaluate the simple example below. We'll view the source code in a moment.

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5Tb3VyY2VDb2RlTGl2ZSBkb1xuICB1c2UgUGhvZW5peC5MaXZlVmlld1xuICB1c2UgTGl2ZVZpZXdOYXRpdmUuTGl2ZVZpZXdcblxuICBAaW1wbCB0cnVlXG4gIGRlZiByZW5kZXIoJXtmb3JtYXQ6IDpzd2lmdHVpfSA9IGFzc2lnbnMpIGRvXG4gICAgflNXSUZUVUlcIlwiXCJcbiAgICA8VGV4dD5SaWdodCBjbGljayB0aGlzIHBhZ2UgYW5kIHNlbGVjdCBcInZpZXcgc291cmNlIGNvZGVcIjwvVGV4dD5cbiAgICBcIlwiXCJcbiAgZW5kXG5lbmQiLCJwYXRoIjoiLyJ9","chunks":[[0,109],[111,251],[364,45],[411,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule Server.SourceCodeLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <Text>Right click this page and select "view source code"</Text>
    """
  end
end
```

Visit http://localhost:4000/?_lvn[format]=swiftui, then right-click the page and select "View Page Source."

You should see some source code similar to the example below. We've removed long tokens for the sake of readability.

```html
<compiled-lvn-stylesheet body="%{}">  
  <csrf-token value="sometoken"></csrf-token>
  <NavigationStack>
    <div id="phx-someid" data-phx-main data-phx-session="sometoken" data-phx-static="sometoken">
      <compiled-lvn-stylesheet body="%{}">
        <Text>Right click this page and select "view source code"</Text>
      </compiled-lvn-stylesheet>
    </div>
  </NavigationStack>
</compiled-lvn-stylesheet>
<iframe hidden height="0" width="0" src="/phoenix/live_reload/frame"></iframe>
```

Notice the [NavigationStack](https://developer.apple.com/documentation/swiftui/navigationstack) view wraps the template. This view manages the state of navigation history and allows for navigating back to previous pages.

## Push Navigation

We can use the same [redirect/2](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#redirect/2), [push_patch/2](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#push_patch/2), and [push_navigate/2](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#push_navigate/2) functions used in typical LiveViews. It's best to use these functions to share navigation handlers between the web and native live views or have more custom control over how to handle navigation.

We've created an example below of two LiveViews. The `MainLive` LiveView renders on the  `"/"` URL, and the `AboutLive` LiveView renders on the `"/about"` URL.

To view this example:

1. Evaluate **both** `MainLive` and `AboutLive` below.
2. Open your simulator and click the button to navigate between views on native
3. Visit http://localhost:4000/ and click the button to navigate between views on the web

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5NYWluTGl2ZSBkb1xuICB1c2UgUGhvZW5peC5MaXZlVmlld1xuICB1c2UgTGl2ZVZpZXdOYXRpdmUuTGl2ZVZpZXdcblxuICBAaW1wbCB0cnVlXG4gIGRlZiByZW5kZXIoJXtmb3JtYXQ6IDpzd2lmdHVpfSA9IGFzc2lnbnMpIGRvXG4gICAgflNXSUZUVUlcIlwiXCJcbiAgICA8QnV0dG9uIHBoeC1jbGljaz1cInRvLWFib3V0XCI+VG8gQWJvdXQ8L0J1dHRvbj5cbiAgICBcIlwiXCJcbiAgZW5kXG5cbiAgZGVmIHJlbmRlcihhc3NpZ25zKSBkb1xuICAgIH5IXCJcIlwiXG4gICAgPGJ1dHRvbiBwaHgtY2xpY2s9XCJ0by1hYm91dFwiPlRvIEFib3V0PC9idXR0b24+XG4gICAgXCJcIlwiXG4gIGVuZFxuXG4gIEBpbXBsIHRydWVcbiAgZGVmIGhhbmRsZV9ldmVudChcInRvLWFib3V0XCIsIF9wYXJhbXMsIHNvY2tldCkgZG9cbiAgICB7Om5vcmVwbHksIHB1c2hfbmF2aWdhdGUoc29ja2V0LCB0bzogXCIvYWJvdXRcIil9XG4gIGVuZFxuZW5kIiwicGF0aCI6Ii8ifQ","chunks":[[0,109],[111,451],[564,45],[611,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule Server.MainLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <Button phx-click="to-about">To About</Button>
    """
  end

  def render(assigns) do
    ~H"""
    <button phx-click="to-about">To About</button>
    """
  end

  @impl true
  def handle_event("to-about", _params, socket) do
    {:noreply, push_navigate(socket, to: "/about")}
  end
end
```

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5BYm91dExpdmUgZG9cbiAgdXNlIFBob2VuaXguTGl2ZVZpZXdcbiAgdXNlIExpdmVWaWV3TmF0aXZlLkxpdmVWaWV3XG5cbiAgQGltcGwgdHJ1ZVxuICBkZWYgcmVuZGVyKCV7Zm9ybWF0OiA6c3dpZnR1aX0gPSBhc3NpZ25zKSBkb1xuICAgIH5TV0lGVFVJXCJcIlwiXG4gICAgPEJ1dHRvbiBwaHgtY2xpY2s9XCJ0by1tYWluXCI+VG8gTWFpbjwvQnV0dG9uPlxuICAgIFwiXCJcIlxuICBlbmRcblxuXG4gIGRlZiByZW5kZXIoYXNzaWducykgZG9cbiAgICB+SFwiXCJcIlxuICAgIDxidXR0b24gcGh4LWNsaWNrPVwidG8tbWFpblwiPlRvIE1haW48L2J1dHRvbj5cbiAgICBcIlwiXCJcbiAgZW5kXG5cbiAgQGltcGwgdHJ1ZVxuICBkZWYgaGFuZGxlX2V2ZW50KFwidG8tbWFpblwiLCBfcGFyYW1zLCBzb2NrZXQpIGRvXG4gICAgezpub3JlcGx5LCBwdXNoX25hdmlnYXRlKHNvY2tldCwgdG86IFwiL1wiKX1cbiAgZW5kXG5lbmQiLCJwYXRoIjoiL2Fib3V0In0","chunks":[[0,109],[111,443],[556,50],[608,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule Server.AboutLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <Button phx-click="to-main">To Main</Button>
    """
  end

  def render(assigns) do
    ~H"""
    <button phx-click="to-main">To Main</button>
    """
  end

  @impl true
  def handle_event("to-main", _params, socket) do
    {:noreply, push_navigate(socket, to: "/")}
  end
end
```

## Navigation Links

We can use the [NavigationLink](https://liveview-native.github.io/liveview-client-swiftui/documentation/liveviewnative/navigationlink) view for native navigation, similar to how we can use the [.link](https://hexdocs.pm/phoenix_live_view/Phoenix.Component.html#link/1) component with the `navigate` attribute for web navigation.

We've created the same example of navigating between the `Main` and `About` pages, this time using links.

To view this example:

1. Evaluate **both** `MainLinkLive` and `AboutLinkLive` below.
2. Open your simulator and click the button to navigate between views on native
3. Visit http://localhost:4000/ and click the button to navigate between views on the web

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5NYWluTGlua0xpdmUgZG9cbiAgdXNlIFBob2VuaXguTGl2ZVZpZXdcbiAgdXNlIExpdmVWaWV3TmF0aXZlLkxpdmVWaWV3XG5cbiAgQGltcGwgdHJ1ZVxuICBkZWYgcmVuZGVyKCV7Zm9ybWF0OiA6c3dpZnR1aX0gPSBhc3NpZ25zKSBkb1xuICAgIH5TV0lGVFVJXCJcIlwiXG4gICAgPE5hdmlnYXRpb25MaW5rIGRlc3RpbmF0aW9uPXtcImFib3V0XCJ9PlxuICAgICAgICA8VGV4dD5UbyBBYm91dDwvVGV4dD5cbiAgICA8L05hdmlnYXRpb25MaW5rPlxuICAgIFwiXCJcIlxuICBlbmRcblxuICBkZWYgcmVuZGVyKGFzc2lnbnMpIGRvXG4gICAgfkhcIlwiXCJcbiAgICA8LmxpbmsgbmF2aWdhdGU9e1wiL2Fib3V0XCJ9PlRvIEFib3V0PC8ubGluaz5cbiAgICBcIlwiXCJcbiAgZW5kXG5lbmQiLCJwYXRoIjoiLyJ9","chunks":[[0,109],[111,373],[486,45],[533,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule Server.MainLinkLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <NavigationLink destination={"about"}>
        <Text>To About</Text>
    </NavigationLink>
    """
  end

  def render(assigns) do
    ~H"""
    <.link navigate={"/about"}>To About</.link>
    """
  end
end
```

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5BYm91dExpbmtMaXZlIGRvXG4gIHVzZSBQaG9lbml4LkxpdmVWaWV3XG4gIHVzZSBMaXZlVmlld05hdGl2ZS5MaXZlVmlld1xuXG4gIEBpbXBsIHRydWVcbiAgZGVmIHJlbmRlcigle2Zvcm1hdDogOnN3aWZ0dWl9ID0gYXNzaWducykgZG9cbiAgICB+U1dJRlRVSVwiXCJcIlxuICAgIDxOYXZpZ2F0aW9uTGluayBkZXN0aW5hdGlvbj17XCIvXCJ9PlxuICAgICAgICA8VGV4dD5UbyBNYWluPC9UZXh0PlxuICAgIDwvTmF2aWdhdGlvbkxpbms+XG4gICAgXCJcIlwiXG4gIGVuZFxuXG4gIGRlZiByZW5kZXIoYXNzaWducykgZG9cbiAgICB+SFwiXCJcIlxuICAgIDwubGluayBuYXZpZ2F0ZT17XCIvXCJ9PlRvIE1haW48Ly5saW5rPlxuICAgIFwiXCJcIlxuICBlbmRcbmVuZCIsInBhdGgiOiIvYWJvdXQifQ","chunks":[[0,109],[111,363],[476,50],[528,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule Server.AboutLinkLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <NavigationLink destination={"/"}>
        <Text>To Main</Text>
    </NavigationLink>
    """
  end

  def render(assigns) do
    ~H"""
    <.link navigate={"/"}>To Main</.link>
    """
  end
end
```

The `destination` attribute works the same as the `navigate` attribute on the web. The current LiveView will shut down, and a new one will mount without reloading the whole page or re-establishing a new socket connection.

## Routing

The `KinoLiveViewNative` smart cells used in this guide automatically define routes for us. Be aware there is no difference between how we define routes for LiveView or LiveView Native.

The routes for the main and about pages might look like the following in the router:

<!-- livebook:{"force_markdown":true} -->

```elixir
live "/", Server.MainLive
live "/about", Server.AboutLive
```

## Native Navigation Events

There are three main navigation functions in Phoenix LiveView. Each function sends a navigation event to the LiveView Native [LiveViewCoordinator](https://github.com/liveview-native/liveview-client-swiftui/blob/0e0fc6bbe5e95ef308e51551af0889acb09b87b3/Sources/LiveViewNative/Coordinators/LiveViewCoordinator.swift) through a channel.

* redirect -> sends the [`redirect` event](https://github.com/liveview-native/liveview-client-swiftui/blob/9895c3b16d84a2683dcb1f127994be6c1bdf4919/Sources/LiveViewNative/Coordinators/LiveViewCoordinator.swift#L274-L281).
* push_navigate -> sends a [`live_redirect` event](https://github.com/liveview-native/liveview-client-swiftui/blob/9895c3b16d84a2683dcb1f127994be6c1bdf4919/Sources/LiveViewNative/Coordinators/LiveViewCoordinator.swift#L258-L265).
* push_patch -> sends a [`live_patch` event](https://github.com/liveview-native/liveview-client-swiftui/blob/9895c3b16d84a2683dcb1f127994be6c1bdf4919/Sources/LiveViewNative/Coordinators/LiveViewCoordinator.swift#L266-L273).

The `LiveViewCoordinator` [sends those navigation requests to the LiveSessionCoordinator](https://github.com/liveview-native/liveview-client-swiftui/blob/0e0fc6bbe5e95ef308e51551af0889acb09b87b3/Sources/LiveViewNative/Coordinators/LiveSessionCoordinator.swift#L353) which handles them natively.

The LiveView Native [LiveSessionCoordinator](https://github.com/liveview-native/liveview-client-swiftui/blob/0e0fc6bbe5e95ef308e51551af0889acb09b87b3/Sources/LiveViewNative/Coordinators/LiveSessionCoordinator.swift) manages the current [navigation path](https://github.com/liveview-native/liveview-client-swiftui/blob/0e0fc6bbe5e95ef308e51551af0889acb09b87b3/Sources/LiveViewNative/Coordinators/LiveSessionCoordinator.swift#L43). The navigation path contains a list of [LiveNavigationEntries](https://github.com/liveview-native/liveview-client-swiftui/blob/0e0fc6bbe5e95ef308e51551af0889acb09b87b3/Sources/LiveViewNative/Coordinators/LiveNavigationEntry.swift) which acts as the history of pages the user has viewed.

<!-- livebook:{"break_markdown":true} -->

### Disconnected Mount

LiveViews are mounted twice to improve their performance. During the first `mount/3` callback, the template is immediately sent to the client. The socket connection is established during the second `mount/3` callback, which allows for interactivity on the page. This is applicable to both native and web applications. Currently, a loading indicator is automatically shown during the disconnected mount. However, there is an [open issue](https://github.com/liveview-native/liveview-client-swiftui/issues/1229) that may change this behavior.

Be aware that:

* The `redirect/2` doesn't trigger the disconnected mount as you might expect. There is an [open issue](https://github.com/liveview-native/liveview-client-swiftui/issues/1228) and this behavior may change in the future to make LiveView Native more in line with web behavior.
* We currently don't support `live_session/3` however there is a [PR in progress](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.Router.html#live_session/3)

Below we have an example of each type of navigation event so you can see their behavior. The `mount_value` helps make it more obvious when the page remounts. The `patch_value` helps make it more obvious when the `handle_params/3` callback triggers.

Evaluate the example below and press each button. Notice that:

1. `redirect/2` does not trigger the disconnected mount as it would on web.
2. `redirect/2` and `push_navigate/2` both trigger a connected `mount/3`.
3. `push_patch/2` does not trigger the `mount/3` callback, but does trigger the `handle_params/3` callback. This is often useful when using navigation to trigger page changes such as displaying a modal or overlay.

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5OYXZpZ2F0aW9uVHlwZXNMaXZlIGRvXG4gIHVzZSBQaG9lbml4LkxpdmVWaWV3XG4gIHVzZSBMaXZlVmlld05hdGl2ZS5MaXZlVmlld1xuXG4gIEBpbXBsIHRydWVcbiAgZGVmIG1vdW50KF9wYXJhbXMsIF9zZXNzaW9uLCBzb2NrZXQpIGRvXG4gICAgUHJvY2Vzcy5zbGVlcCgxMDAwKVxuXG4gICAgaWYgY29ubmVjdGVkPyhzb2NrZXQpIGRvXG4gICAgICBJTy5pbnNwZWN0KFwiQ09OTkVDVEVEIE1PVU5UXCIpXG4gICAgZWxzZVxuICAgICAgSU8uaW5zcGVjdChcIkRJU0NPTk5FQ1RFRCBNT1VOVFwiKVxuICAgIGVuZFxuXG4gICAgezpvayxcbiAgICAgYXNzaWduKHNvY2tldCxcbiAgICAgICBjb25uZWN0ZWQ6IGNvbm5lY3RlZD8oc29ja2V0KSxcbiAgICAgICBtb3VudF92YWx1ZTogRW51bS5yYW5kb20oMS4uMTAwKSxcbiAgICAgICBwYXRjaF92YWx1ZTogRW51bS5yYW5kb20oMS4uMTAwKVxuICAgICApfVxuICBlbmRcblxuICBAaW1wbCB0cnVlXG4gIGRlZiBoYW5kbGVfcGFyYW1zKF9wYXJhbXMsIF91cmwsIHNvY2tldCkgZG9cbiAgICBJTy5pbnNwZWN0KFwiSEFORExJTkcgUEFSQU1TXCIpXG5cbiAgICB7Om5vcmVwbHksIGFzc2lnbihzb2NrZXQsIDpwYXRjaF92YWx1ZSwgRW51bS5yYW5kb20oMS4uMTAwKSl9XG4gIGVuZFxuXG4gIEBpbXBsIHRydWVcbiAgZGVmIHJlbmRlcigle2Zvcm1hdDogOnN3aWZ0dWl9ID0gYXNzaWducykgZG9cbiAgICB+U1dJRlRVSVwiXCJcIlxuICAgIDxCdXR0b24gcGh4LWNsaWNrPVwicmVkaXJlY3RcIj5SZWRpcmVjdDwvQnV0dG9uPlxuICAgIDxCdXR0b24gcGh4LWNsaWNrPVwibmF2aWdhdGVcIj5OYXZpZ2F0ZTwvQnV0dG9uPlxuICAgIDxCdXR0b24gcGh4LWNsaWNrPVwicGF0Y2hcIj5QYXRjaDwvQnV0dG9uPlxuICAgIDxCdXR0b24gcGh4LWNsaWNrPVwiY3Jhc2hcIj5DcmFzaDwvQnV0dG9uPlxuICAgIDxUZXh0Pk1vdW50ZWQgPCU9IEBtb3VudF92YWx1ZSAlPjwvVGV4dD5cbiAgICA8VGV4dD5QYXRjaGVkIDwlPSBAcGF0Y2hfdmFsdWUgJT48L1RleHQ+XG4gICAgPFRleHQ+U29ja2V0IENvbm5lY3RlZDogPCU9IEBjb25uZWN0ZWQgJT48L1RleHQ+XG4gICAgXCJcIlwiXG4gIGVuZFxuXG4gIEBpbXBsIHRydWVcbiAgZGVmIHJlbmRlcihhc3NpZ25zKSBkb1xuICAgIH5TV0lGVFVJXCJcIlwiXG4gICAgPGJ1dHRvbiBwaHgtY2xpY2s9XCJyZWRpcmVjdFwiPlJlZGlyZWN0PC9idXR0b24+XG4gICAgPGJ1dHRvbiBwaHgtY2xpY2s9XCJuYXZpZ2F0ZVwiPk5hdmlnYXRlPC9idXR0b24+XG4gICAgPGJ1dHRvbiBwaHgtY2xpY2s9XCJwYXRjaFwiPlBhdGNoPC9idXR0b24+XG4gICAgPGJ1dHRvbiBwaHgtY2xpY2s9XCJjcmFzaFwiPkNyYXNoPC9idXR0b24+XG4gICAgPHA+TW91bnRlZCA8JT0gQG1vdW50X3ZhbHVlICU+PC9wPlxuICAgIDxwPlBhdGNoZWQgPCU9IEBwYXRjaF92YWx1ZSAlPjwvcD5cbiAgICA8cD5Tb2NrZXQgQ29ubmVjdGVkOiA8JT0gQGNvbm5lY3RlZCAlPjwvcD5cbiAgICBcIlwiXCJcbiAgZW5kXG5cbiAgQGltcGwgdHJ1ZVxuICBkZWYgaGFuZGxlX2V2ZW50KFwicmVkaXJlY3RcIiwgX3BhcmFtcywgc29ja2V0KSBkb1xuICAgIElPLmluc3BlY3QoXCJSRURJUkVDVElOR1wiKVxuICAgIHs6bm9yZXBseSwgcmVkaXJlY3Qoc29ja2V0LCB0bzogXCIvXCIpfVxuICBlbmRcblxuICBkZWYgaGFuZGxlX2V2ZW50KFwibmF2aWdhdGVcIiwgX3BhcmFtcywgc29ja2V0KSBkb1xuICAgIElPLmluc3BlY3QoXCJOQVZJR0FUSU5HXCIpXG4gICAgezpub3JlcGx5LCBwdXNoX25hdmlnYXRlKHNvY2tldCwgdG86IFwiL1wiKX1cbiAgZW5kXG5cbiAgZGVmIGhhbmRsZV9ldmVudChcInBhdGNoXCIsIF9wYXJhbXMsIHNvY2tldCkgZG9cbiAgICBJTy5pbnNwZWN0KFwiUEFUQ0hJTkdcIilcbiAgICB7Om5vcmVwbHksIHB1c2hfcGF0Y2goc29ja2V0LCB0bzogXCIvXCIpfVxuICBlbmRcblxuICBkZWYgaGFuZGxlX2V2ZW50KFwiY3Jhc2hcIiwgX3BhcmFtcywgc29ja2V0KSBkb1xuICAgIElPLmluc3BlY3QoXCJDUkFTSElOR1wiKVxuICAgIHJhaXNlIFwib29wc1wiXG4gIGVuZFxuZW5kIiwicGF0aCI6Ii8ifQ","chunks":[[0,109],[111,1943],[2056,45],[2103,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule Server.NavigationTypesLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def mount(_params, _session, socket) do
    Process.sleep(1000)

    if connected?(socket) do
      IO.inspect("CONNECTED MOUNT")
    else
      IO.inspect("DISCONNECTED MOUNT")
    end

    {:ok,
     assign(socket,
       connected: connected?(socket),
       mount_value: Enum.random(1..100),
       patch_value: Enum.random(1..100)
     )}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    IO.inspect("HANDLING PARAMS")

    {:noreply, assign(socket, :patch_value, Enum.random(1..100))}
  end

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <Button phx-click="redirect">Redirect</Button>
    <Button phx-click="navigate">Navigate</Button>
    <Button phx-click="patch">Patch</Button>
    <Button phx-click="crash">Crash</Button>
    <Text>Mounted <%= @mount_value %></Text>
    <Text>Patched <%= @patch_value %></Text>
    <Text>Socket Connected: <%= @connected %></Text>
    """
  end

  @impl true
  def render(assigns) do
    ~SWIFTUI"""
    <button phx-click="redirect">Redirect</button>
    <button phx-click="navigate">Navigate</button>
    <button phx-click="patch">Patch</button>
    <button phx-click="crash">Crash</button>
    <p>Mounted <%= @mount_value %></p>
    <p>Patched <%= @patch_value %></p>
    <p>Socket Connected: <%= @connected %></p>
    """
  end

  @impl true
  def handle_event("redirect", _params, socket) do
    IO.inspect("REDIRECTING")
    {:noreply, redirect(socket, to: "/")}
  end

  def handle_event("navigate", _params, socket) do
    IO.inspect("NAVIGATING")
    {:noreply, push_navigate(socket, to: "/")}
  end

  def handle_event("patch", _params, socket) do
    IO.inspect("PATCHING")
    {:noreply, push_patch(socket, to: "/")}
  end

  def handle_event("crash", _params, socket) do
    IO.inspect("CRASHING")
    raise "oops"
  end
end
```

