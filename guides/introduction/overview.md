# Overview

LiveView Native is a framework for building native applications using Elixir and Phoenix LiveView.
It upgrades your existing Phoenix project with the ability to write truly native user interfaces that
run on devices and platforms beyond the web.

Here's an example of a simple LiveView that renders both HTML and native SwiftUI views:

<!-- tabs-open -->

### hello_live.ex

```elixir
# lib/my_app_web/live/hello_live.ex
defmodule MyAppWeb.HelloLive do
  use Phoenix.LiveView
  use MyAppWeb, :live_view
  use MyAppWeb.HelloStyles

  @impl true
  def render(%{format: :swiftui} = assigns) do
    # This render function serves native SwiftUI views
    # It uses the `~SWIFTUI` sigil instead of `~H`
    ~SWIFTUI"""
    <VStack spacing={8}>
      <Button phx-click="hello">
        <Image class="fg-color-purple font-size-48 p-8" system-name="sparkles"></Image>
      </Button>
      <HStack spacing={4}>
        Hello world on <Text class="bold"><%= device_name(assigns) %></Text>!
      </HStack>
    </VStack>
    """
  end

  @impl true
  def render(%{} = assigns) do
    # This render function serves HTML
    ~H"""
    <div class="flex w-full h-screen items-center">
      <ul class="w-full text-center">
        <li>
          <button phx-click="hello">
            <.icon name="hero-sparkles-solid" class="text-purple-500 w-24 h-24 m-4" />
          </button>
        </li>
        <li>Hello world on <span class="font-bold"><%= device_name(assigns) %></span>!</li>
      </ul>
    </div>
    """
  end

  @impl true
  def handle_event("hello", _params, socket) do
    # This event handler can be shared across all platforms
    IO.puts "Hello world!"

    {:noreply, socket}
  end

  ###

  # This function can be called from both HTML and SwiftUI templates
  # The native device type is available as the `@target` assign
  defp device_name(%{target: :phone}), do: "iOS"
  defp device_name(%{target: :pad}), do: "iPadOS"
  defp device_name(%{target: :mac}), do: "macOS"
  defp device_name(%{target: :watch}), do: "watchOS"
  defp device_name(_), do: "the web"
end
```

### hello_styles.ex

```elixir
# lib/my_app_web/live/hello_styles.ex
defmodule MyAppWeb.HelloStyles do
  use LiveViewNative.Stylesheet, :swiftui

  ~SHEET"""
  "bold" do
    fontWeight(.bold)
  end

  "fg-color-" <> color do
    foregroundStyle(to_ime(color))
  end

  "font-size-" <> font_size do
    font(system(size: to_integer(font_size)))
  end

  "p-" <> padding do
    padding(to_integer(padding))
  end
  """

  def class(_other, _), do: {:unmatched, ""}
end
```

<!-- tabs-close -->

This code serves users whether they're using a web browser or native app running on an iPhone,
iPad, macOS desktop or Apple Watch. Each platform renders its own native widgets and UI elements,
allowing state, event callbacks and business logic to be shared.

<!-- tabs-open -->

### iPhone

![Hello World - iPhone](./assets/images/hello-iphone.png)

### iPad
![Hello World - iPad](./assets/images/hello-ipad.png)

###  Watch
![Hello World - macOS](./assets/images/hello-watch.png)

### Desktop (macOS)
![Hello World - macOS](./assets/images/hello-mac.png)

### Desktop (Web)
![Hello World - Web](./assets/images/hello-web.png)

<!-- tabs-close -->

The following native platforms are officially supported, and support for other platforms
can be provided by third-party platform libraries.

- iOS 16+
- macOS 13+
- watchOS 9+
- Android

LiveView Native requires some foundational knowledge to use. You should already be familiar with
[Elixir](https://elixir-lang.org/), the [Phoenix Framework](https://www.phoenixframework.org/) and
[Phoenix LiveView](https://github.com/phoenixframework/phoenix_live_view). If you're looking to learn
more about any of these subjects, there are a lot of great resources available. Some recommended
materials include the [Elixir guides](https://elixir-lang.org/getting-started/introduction.html),
[Elixir learning resources page](https://elixir-lang.org/learning.html), [Phoenix guides](https://hexdocs.pm/phoenix/overview.html),
[Phoenix community page](https://hexdocs.pm/phoenix/community.html) and the [Phoenix LiveView HexDocs](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html). 

With those prerequisites out of the way, [let's get LiveView Native installed](./installation.md)!
