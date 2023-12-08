# Render Patterns

There are multiple ways to render native UIs with LiveView Native. This document covers various
patterns and when you might use them.

## `render/1` function clauses

The most common pattern that is often used throughout this guide is the function clause pattern.
Each function clause matches on the `:format`, allowing each platform to define its own UI:

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

## Function components

Platform-specific components can also be defined. For example:

```elixir
# lib/my_app_web/live/hello_live.ex
defmodule MyAppWeb.SharedComponents do
  use Phoenix.Component
  use LiveViewNative.Component

  import ElixirconfChatWeb.Modclasses.SwiftUi, only: [modclass: 3]

  def logo(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <VStack>
      <Image name="Logo" />
      <Text><%= @title %></Text>
    </VStack>
    """
  end

  def logo(%{} = assigns) do
    ~H"""
    <div>
      <img src="my-logo.png" />
      <h1><%= @title %></h1>
    </div>
    """
  end
end
```

## External template files

If you would prefer to break your render function out into separate template files, you can
conditionally render platform-specific templates using the `render_native/1` macro. External
template files are namespaced according to their `:format`:

<!-- tabs-open -->

### hello_live.ex

```elixir
defmodule MyAppWeb.HelloLive do
  use Phoenix.LiveView
  use MyAppWeb, :live_view

  @impl true
  def render(%{} = assigns) do
    render_native(assigns)
  end
end
```

### hello_live.html.heex
```heex
<div id="template-web">
  <div class="text-slate-800 bg-slate-50 h-screen w-screen grid grid-cols-1 gap-1 content-center items-center text-center">
    <div class="font-semibold mb-1">A web template, courtesy of hello_live.html.heex</div>
  </div>
</div>
```

### hello_live.swiftui.heex
```heex
<VStack id="template-ios">
  <HStack modifiers={padding(5)}>
    <Text>A SwiftUI template, courtesy of hello_live.swiftui.heex</Text>
  </HStack>
</VStack>
```

<!-- tabs-close -->

## Targeting specific devices

Conditional rendering based on device type is also supported, depending on the platform library you're using.
The following example for the SwiftUI platform renders different text on various devices:

```elixir
# lib/my_app_web/live/hello_live.ex
defmodule MyAppWeb.SharedComponents do
  use Phoenix.Component
  use LiveViewNative.Component

  import ElixirconfChatWeb.Modclasses.SwiftUi, only: [modclass: 3]

  def logo(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <VStack>
      <%= case @native.platform_config.user_interface_idiom do %>
        <% "mac" -> %>
          <Text>Hello macOS!</Text>
        <% "pad" -> %>
          <Text>Hello iPadOS!</Text>
        <% "watch" -> %>
          <Text>Hello watchOS!</Text>
        <% "tv" -> %>
          <Text>Hello tvOS!</Text>
        <% _ -> %>
          <Text>Hello iOS!</Text>
      <% end %>
    </VStack>
    """
  end
end
```
