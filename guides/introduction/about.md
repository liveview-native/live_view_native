# About

> #### Warning {: .warning}
> LiveView Native is _prerelease software_ and not recommended for production use.

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

<!-- tabs-open -->

### Web

```heex
<% # hello_live.html.heex %>
<div id="hello-web">
  <div class="text-slate-800 bg-slate-50 h-screen w-screen grid grid-cols-1 gap-1 content-center items-center text-center">
    <div class="font-semibold mb-1">Hello from the web!</div>
  </div>
</div>
```

### SwiftUI

```heex
<% # hello_live.swiftui.heex %>
<VStack id="hello-ios">
  <HStack modifiers={padding(5)}>
    <Text>Hello from SwiftUI!</Text>
  </HStack>
</VStack>
```

<!-- tabs-close -->

This library provides a base SDK that allows Elixir developers to use LiveView Native within their own Phoenix projects. If you're a platform developer interested in adding native support for LiveView Native to your own client code, check out [live_view_native_platform](https://github.com/liveview-native/live_view_native_platform).