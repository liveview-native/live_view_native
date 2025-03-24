# Welcome

Welcome to the LiveView Native documentation. LiveView Native is a platform built on
[Phoenix LiveView](https://github.com/phoenixframework/phoenix_live_view) designed for
building native applications. A general overview of LiveView Native and its benefits
[can be seen in our README](https://github.com/liveview-native/live_view_native).

## What is LiveView Native?

LiveView Native is an extention of Phoenix LiveView, designed to serve
platform-specific server-rendered markup to a variety of supported clients.

Since LiveView Native is built on Phoenix LiveView, LiveView Native inherits all
the same rendering benefits of Phoenix LiveView while maintaining a familiar developer
experience – making it a good pick for both your new and existing LiveView servers.

To begin with LiveView Native, a basic understanding of Elixir and Phoenix LiveView
is recommended. [You can find the documentation for Phoenix LiveView here](https://hexdocs.pm/phoenix_live_view/welcome.html).

## How does LiveView Native work?

To understand the fundamentals of LiveView Native, it is important to analyze LiveView Native
and its relationship to our clients and Phoenix LiveView.

### Querying the server

Unlike Phoenix LiveView, when a client makes a request to a LiveView Native route, the route expects additional query
parameters to be provided to denote platform-specific information from said device. This information is what allows
LiveView Native to delegate the request to the appropriate markup processor, and
maintain support with Phoenix LiveView.

The query parameters are as follows.

| Query Parameter | Arguments                | Required? | Description                                            |
|-----------------|--------------------------|-----------|--------------------------------------------------------|
| `_format`       | swiftui, jetpack, html   | ✅        | The content type to be processed by LiveView Native    |
| `_interface`    | mobile, watch, tv        |           | The general device type                                |

This is formatted as `/?_format[target]=swiftui&_interface[device]=watch`, and when no query parameters are provided,
will default to the corresponding Phoenix LiveView route (presuming a route is provided).

### Processing the data

Once a request is successfully delegated by LiveView Native, it will attempt to match on your LiveView route.

By design, LiveView Native does not ship with a client, and instead separates
itself into a series of distinct packages. Each package ships with its own modifiers to handle its respective client,
and unlike many framework agnostic development frameworks, intentionally separates your markup by platform.

| Platform | Framework                                                                             | Ready? |
|----------|---------------------------------------------------------------------------------------|--------|
| Apple    | [LiveView Native SwiftUI](https://github.com/liveview-native/liveview-client-swiftui) | ✅     |
| Android  | [LiveView Native Jetpack](https://github.com/liveview-native/liveview-client-jetpack) |        |
| Web      | [LiveView Native HTML](https://github.com/liveview-native/liveview-client-html)       | ✅     |

This is to maintain instant feature parity with your platform(s) of choice, as LiveView Native is not concerned with
a cross-platform abstraction layer (or an application bridge). This allows LiveView Native and its corresponding markup processor
to send back Phoenix events and native UI representations of your application.

This UI representation is also extendible via add-ons, which are actively being developed per supported client.

> #### Note {: .warning}
> Similar to Phoenix LiveView, LiveView Native follows secure best practices and will only send back markup.
> LiveView Native will never send back remote executable code.

Let's see an example.

```elixir
# This entry point to your LiveView, which can handle events from any platform
# lib/my_app_web/live/hello_live.ex
defmodule MyAppWeb.HelloLive do
  use MyAppWeb, :live_view
  use MyAppNative, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end

# This module will be called on if the format is :swift_ui
# lib/my_app_web/live/hello_live_swiftui.ex
defmodule MyAppWeb.HelloLive.SwiftUI do
  use MyAppNative, :live_view

  # Within formats, you can target sub-platforms, offering versatility in your views
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

# This module will be called on if the format is :jetpack
# lib/my_app_web/live/hello_live_jetpack.ex
defmodule MyAppWeb.HelloLive.Jetpack do
  use MyAppNative, :live_view

  def render(assigns, _interface) do
    ~LVN"""
    <Text>Hello Jetpack Compose!</Text>
    """
  end
end
```

The modules above show a distinct path to each format handled by its respective markup processor.
We start in our Phoenix LiveView, which handles our mount and event handling. From there, LiveView Native
delegates the request to our markup modules, which handle our rendering.

LiveView Native uses a two arity render function, which allows us to match on client information and
metadata. For more information see `LiveViewNative.Renderer.embed_templates/2`.

Within our render function, we use the `~LVN` sigil to define a NEEx template, which stands for Native+EEx. These are similar to HEEx templates, but
with a few key differences.

> #### NEEx vs HEEx {: .info}
> - Tag name casing is preserved, so up-cased attributes like `<Text>` will not be down-cased to `<text>`.
> - Boolean attributes are not permitted. For example, `<text on>` would mean on is `true` in HTML. In NEEx we cannot make that presumption because
> some upstream native clients default truth-y attributes to `false`. Instead everything must be explicit: `<Text on={true}>`.
> - LiveView Native supports all of the [HEEx special attributes](https://hexdocs.pm/phoenix_live_view/Phoenix.Component.html#sigil_H/2-special-attributes)
> in addition to LiveView Native specific special attributes. See `LiveViewNative.Component.sigil_LVN/2` for more information.

The rest is quite akin to a standard LiveView, and will interop directly into your existing Phoenix LiveView
application. For more information on the component lifecycle, check `LiveViewNative.Component`.

### Handling the response

Once a successful response is sent back from the server, we need a client to process this data.
Similar to most native development, we either need to compile the automatically generated native project files via
your platform-target's development tools, or we can use [LVN Go](https://dockyard.com/blog/2024/09/10/introducing-lvn-go) – our real-time, zero-deployment development environment.

> #### Note {: .warning}
> LVN Go is only available as a client on Apple devices, and currently does not support LVN 4.x.x.

Corresponding documentation for each client is available in our supported clients, and will walk you through
the setup needed to test in each environment.

## Supported Clients

LiveView Native enables client frameworks in the following.

| UI Framework     | Devices                                                     | Framework                                                                             | Build Tool     | Testing Client                                              |
|------------------|-------------------------------------------------------------|---------------------------------------------------------------------------------------|----------------|-------------------------------------------------------------|
| SwiftUI          | iPhone, iPad, AppleTV, Apple Watch, MacOS, Apple Vision Pro | [LiveView Native SwiftUI](https://github.com/liveview-native/liveview-client-swiftui) | XCode          | [LVN Go](https://apps.apple.com/us/app/lvn-go/id6614695506) |
| JetPack Compose  | Android family                                              | [LiveView Native Jetpack](https://github.com/liveview-native/liveview-client-jetpack) | Android Studio |                                                             |
| HTML             |                                                             | [LiveView Native HTML](https://github.com/liveview-native/liveview-client-html)       |                |                                                             |

## Questions?

Have a question or want some help with LiveView Native?

Check out the `#liveview-native` channel on the [Elixir Lang Slack](https://elixir-lang.slack.com/).
