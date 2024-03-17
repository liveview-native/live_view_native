# LiveViewNative

[![Build Status](https://github.com/liveview-native/live_view_native/workflows/Elixir%20CI/badge.svg)](https://github.com/liveview-native/live_view_native/actions) [![Hex.pm](https://img.shields.io/hexpm/v/live_view_native.svg)](https://hex.pm/packages/live_view_native) [![Documentation](https://img.shields.io/badge/documentation-gray)](https://hexdocs.pm/live_view_native)

## About

LiveView Native is a platform for building native applications using [Elixir](https://elixir-lang.org/) and [Phoenix LiveView](https://github.com/phoenixframework/phoenix_live_view). It allows a single LiveView to serve both web and non-web clients by transforming platform-specific template code into native UIs:

```elixir
# lib/my_app_web/live/hello_live.ex
defmodule MyAppWeb.HelloLive do
  use MyAppWeb, :live_view
  use LiveViewNative.LiveView,
    formats: [:swiftui],
    layouts: [
      swiftui: {MyAppWeb.Layouts.SwiftUI, :app}
    ]
end

# liv/my_app_web/live/hello_live_swiftui.ex
defmodule MyAppWeb.HelloLive.SwiftUI do
  use LiveViewNative.Component,
    format: :swiftui,
    as: :render

  def render(assigns, %{"target" => "watchos"}) do
    ~LVN"""
    <VStack>
      <Text>
        Hello WatchOS!
      </Text>
    </VStack>
    """
  end

  def render(assigns, _interface) do
    ~LVN"""
    <VStack>
      <Text>
        Hello SwiftUI!
      </Text>
    </VStack>
    """
  end
end
```

To use LiveView Native in your Phoenix application, follow the instructions in the [getting started guide](https://hexdocs.pm/live_view_native/overview.html).

## Learn more

  * Official website: https://native.live
  * Guides: https://hexdocs.pm/live_view_native/overview.html
  * Docs: https://hexdocs.pm/live_view_native
  * Forum: https://elixirforum.com/c/elixir-framework-forums/liveview-native-forum
  * Source: https://github.com/liveview-native/live_view_native
