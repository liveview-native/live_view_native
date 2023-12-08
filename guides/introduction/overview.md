# Overview

LiveView Native is a framework for building native applications using Elixir and Phoenix LiveView. It allows a single application to serve a multitude of clients by transforming platform-specific template code into native user interfaces. Here's a basic example that serves web, iOS, iPadOS and macOS clients natively:

<!-- tabs-open -->

### Source

```elixir
# lib/my_app_web/live/hello_live.ex
defmodule MyAppWeb.HelloLive do
  use Phoenix.LiveView
  use MyAppWeb, :live_view

  @impl true
  def render(%{format: :swiftui} = assigns) do
    # This UI renders on the iPhone / iPad app
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

### iOS

![Hello World - iOS](./assets/images/hello-iphone.png)

### iPadOS
![Hello World - iPadOS](./assets/images/hello-ipad.png)

### macOS
![Hello World - macOS](./assets/images/hello-mac.png)

### Web
![Hello World - Web](./assets/images/hello-web.png)

<!-- tabs-close -->

By using LiveView Native in an existing Phoenix project, developers are able to deliver rich, real-time UIs for a multitude of web and non-web clients generated entirely by the server. Live sessions, state, event callbacks and glue code can be shared across all target platforms, with each platform having its own custom-tailored template or function component.

LiveView Native officially supports using LiveView for the following native clients:

- iOS 16+
- macOS 13+
- watchOS 9+
- Android

LiveView Native requires some foundational knowledge to use. You should already be familiar with [Elixir](https://elixir-lang.org/), the [Phoenix Framework](https://www.phoenixframework.org/) and [Phoenix LiveView](https://github.com/phoenixframework/phoenix_live_view). If you're looking to learn more about any of these subjects, there are a lot of great resources available. Some recommended materials include the [Elixir guides](https://elixir-lang.org/getting-started/introduction.html), [Elixir learning resources page](https://elixir-lang.org/learning.html), [Phoenix guides](https://hexdocs.pm/phoenix/overview.html), [Phoenix community page](https://hexdocs.pm/phoenix/community.html) and the [Phoenix LiveView HexDocs](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html). 

With those prerequisites out of the way, [let's get LiveView Native installed](./installation.md)!