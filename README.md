# LiveViewNative

[![Build Status](https://github.com/liveview-native/live_view_native/workflows/Elixir%20CI/badge.svg)](https://github.com/liveview-native/live_view_native/actions) [![Hex.pm](https://img.shields.io/hexpm/v/live_view_native.svg)](https://hex.pm/packages/live_view_native) [![Documentation](https://img.shields.io/badge/documentation-gray)](https://hexdocs.pm/live_view_native)

## About

LiveView Native is a platform for building native applications using [Elixir](https://elixir-lang.org/) and [Phoenix LiveView](https://github.com/phoenixframework/phoenix_live_view). It allows a single LiveView to serve both web and non-web clients by transforming platform-specific template code into native UIs:

```elixir
# lib/my_app_web/live/hello_live.ex
defmodule MyAppWeb.HelloLive do
  use Phoenix.LiveView
  use MyAppWeb, :live_view

  @impl true
  def render(%{format: :swiftui} = assigns) do
    # This UI renders on iOS
    ~SWIFTUI"""
    <VStack>
      <Text>
        Hello native!
      </Text>
    </VStack>
    """
  end

  @impl true
  def render(%{} = assigns) do
    # This UI renders on the web
    ~H"""
    <div class="flex w-full h-screen items-center">
      <span class="w-full text-center">
        Hello web!
      </span>
    </div>
    """
  end
end
```

To use LiveView Native in your Phoenix application, follow the instructions in the [getting started guide](https://hexdocs.pm/live_view_native/overview.html).

## Learn more

  * Official website: https://native.live
  * Docs: https://hexdocs.pm/live_view_native
  * Source: https://github.com/liveview-native/live_view_native
