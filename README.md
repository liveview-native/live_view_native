# LiveViewNative

[![Build Status](https://github.com/liveview-native/live_view_native/workflows/Elixir%20CI/badge.svg)](https://github.com/liveview-native/live_view_native/actions) [![Hex.pm](https://img.shields.io/hexpm/v/live_view_native.svg)](https://hex.pm/packages/live_view_native)

> ⚠️ LiveView Native is _prerelease software_ and not recommended for production use.

## Installation

To use LiveView Native, add it to your list of dependencies in `mix.exs`.

```elixir
def deps do
  [{:live_view_native, "~> 0.0.7"}]
end
```

## About

LiveView Native is a platform for building native applications using [Elixir](https://elixir-lang.org/) and [Phoenix LiveView](https://github.com/phoenixframework/phoenix_live_view). It allows a single LiveView to serve a variety of clients by transforming platform-specific template code into native user interfaces. Here is a basic example:

```elixir
# hello_live.ex
defmodule MyApp.HelloLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def render(assigns) do
    # render_native/1 is provided by LiveViewNative.LiveView.
    # It takes care of rendering the correct .heex template
    # for each platform 
    render_native(assigns)
  end
end
```

This allows us to define a specific template for each platform:

```html
<% # hello_live.html.heex %>
<div id="hello-web">
  <div class="text-slate-800 bg-slate-50 h-screen w-screen grid grid-cols-1 gap-1 content-center items-center text-center">
    <div class="font-semibold mb-1">Hello from the web!</div>
  </div>
</div>
```

```html
<% # hello_live.swiftui.heex %>
<VStack id="hello-ios">
  <HStack modifiers={padding(5)}>
    <Text>Hello from SwiftUI!</Text>
  </HStack>
</VStack>
```

This library provides a base SDK that allows Elixir developers to use LiveView Native within their own Phoenix projects. If you're a platform developer interested in adding native support for LiveView Native to your own client code, check out [live_view_native_platform](https://github.com/liveview-native/live_view_native_platform).

## Usage

The `live_view_native` Hex package isn't useful on its own. You also need to add any platform libraries you want your application to support. The supported platforms and their libraries are:

| Platform        | Clients                           | Dependency                                                                              |
| :-------------- | :-------------------------------- | :-------------------------------------------------------------------------------------- |
| SwiftUI         | iOS, iPadOS, macOS, watchOS, tvOS | [live_view_native_swift_ui](https://github.com/liveview-native/liveview-client-swiftui) |
| Jetpack Compose | Android                           | [live_view_native_jetpack](https://github.com/liveview-native/liveview-client-jetpack)  |

For example, if you want to support rendering LiveViews in SwiftUI, add its platform library as a dependency in your `mix.exs` file:

```elixir
def deps do
  [
    {:live_view_native, "~> 0.0.7"},
    {:live_view_native_swift_ui, "~> 0.0.7"}
  ]
end
```

You can add any number of platform libraries, allowing you to serve a variety of non-web clients from the same application. The list of supported platforms, along with their configuration, is defined within your application's Mix configuration:

```elixir
# config.exs
import Config

# ...

# Define platform support for LiveView Native
config :live_view_native,
  plugins: [
    LiveViewNativeSwiftUi
  ]
```

Finally, each platform has its own implementation details for connecting a native client application to a LiveView Native backend. For example, if you want to support `live_view_native_swift_ui` you'll need to [create an App in Xcode](https://liveview-native.github.io/liveview-client-swiftui/tutorials/liveviewnative/01-initial-list#Creating-the-App) and use the `LiveViewNative` Swift dependency to render a clientside [LiveView](https://liveview-native.github.io/liveview-client-swiftui/documentation/liveviewnative/liveview) that connects to your Phoenix server:

```swift
// MyApp.swift
import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

//  ContentView.swift
import SwiftUI
import LiveViewNative

struct ContentView: View {
    var body: some View {
        LiveView(.localhost)
    }
}
```

For more information on how to configure a LiveView Native project for a specific platform, please visit the documentation page for that platform library.

## Learn more

  * Official website: https://native.live
  * Docs: https://hexdocs.pm/live_view_native
  * Source: https://github.com/liveviewnative/live_view_native
