# LiveViewNative

[![Build Status](https://github.com/liveview-native/live_view_native/workflows/Elixir%20CI/badge.svg)](https://github.com/liveview-native/live_view_native/actions) [![Hex.pm](https://img.shields.io/hexpm/v/live_view_native.svg)](https://hex.pm/packages/live_view_native) [![Documentation](https://img.shields.io/badge/documentation-gray)](https://hexdocs.pm/live_view_native)

## About

LiveView Native is a platform for building native applications using [Elixir](https://elixir-lang.org/) and [Phoenix LiveView](https://github.com/phoenixframework/phoenix_live_view). It allows a single LiveView to serve both web and non-web clients by transforming platform-specific template code into native UIs:

```elixir
# lib/my_app_web/live/hello_live.ex
defmodule MyAppWeb.HelloLive do
  use MyAppWeb, :live_view
  use MyAppNative, :live_view
end

# liv/my_app_web/live/hello_live_swiftui.ex
defmodule MyAppWeb.HelloLive.SwiftUI do
  use MyAppNative, [:render_component, format: :swiftui]

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

## Getting started

In addition to `live_view_native` you may want to include some additional libraries:

```elixir
{:live_view_native, "~> 0.3.0-rc.2"},
{:live_view_native_stylesheet, "~> 0.3.0-rc.2"},
{:live_view_native_swiftui, "~> 0.3.0-rc.2"},
{:live_view_native_live_form, "~> 0.3.0-rc.2"}
```

Then run:

```
$ mix lvn.setup
```

and follow the instructions on how to complete the setup process.
