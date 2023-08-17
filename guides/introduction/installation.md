# Installation
To use LiveView Native, add it to your list of dependencies in `mix.exs`.

```elixir
def deps do
  [{:live_view_native, "~> 0.0.7"}]
end
```

## Adding platform libraries

The `live_view_native` Hex package isn't useful on its own. You also need to add any platform libraries you want your application to support.

You can add any number of platform libraries, allowing you to serve a variety of non-web clients from the same application.

<!-- tabs-open -->

### SwiftUI
Supported platforms:
* iOS 16+
* macOS 13+
* watchOS 9+

> #### Platform Documentation {: .info}
> For more information, see the platform-specific documentation: [`live_view_native_swift_ui`](https://github.com/liveview-native/liveview-client-swiftui)
```elixir
def deps do
  [
    # ...
    {:live_view_native_swift_ui, "~> 0.0.9"}
  ]
end
```
The list of supported platforms, along with their configuration, is defined within your application's Mix configuration:
```elixir
# config.exs
import Config

# ...

# Define platform support for LiveView Native
config :live_view_native,
  platforms: [
    LiveViewNativeSwiftUi.Platform
  ]

config :live_view_native, LiveViewNativeSwiftUi.Platform, app_name: "My App"
```

### Jetpack Compose
Supported platforms:
* Android

> #### Platform Documentation {: .info}
> For more information, see the platform-specific documentation: [`live_view_native_jetpack`](https://github.com/liveview-native/liveview-client-jetpack)
```elixir
def deps do
  [
    # ...
    {:live_view_native_jetpack, "~> 0.0.9"}
  ]
end
```
The list of supported platforms, along with their configuration, is defined within your application's Mix configuration:
```elixir
# config.exs
import Config

# ...

# Define platform support for LiveView Native
config :live_view_native,
  platforms: [
    LiveViewNativeJetpack.Platform
  ]

config :live_view_native, LiveViewNativeJetpack.Platform, app_name: "My App"
```

<!-- tabs-close -->

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