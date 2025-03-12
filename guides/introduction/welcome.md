# Welcome

Welcome to the LiveView Native documentation. LiveView Native is a platform built on
[Phoenix LiveView](https://github.com/phoenixframework/phoenix_live_view) designed for
building native applications. A general overview of LiveView Native and its benefits
[can be seen in our README](https://github.com/live_view_native/live_view_native).

## What is LiveView Native?

LiveView Native is an extention of Phoenix LiveView, designed to serve
platform-specific server-rendered markup to a variety of supported clients.

Since LiveView Native is built on Phoenix LiveView, LiveView Native inherits all
the same rendering benefits of Phoenix LiveView while maintaining a familiar developer
experience – making it a good pick for both your new and existing LiveView servers.

To begin with LiveView Native, a basic understanding of Elixir and Phoenix LiveView
is recommended. [You can find the documentation for Phoenix LiveView here](https://hexdocs.pm/phoenix_live_view/welcome.html).

## How does LiveView Native work?

To understand the fundementals of LiveView Native, it is important to analyze LiveView Native
and its relationship to Phoenix LiveView and LiveView Native's rendering packages.

### Querying

Unlike Phoenix LiveView, when a client makes a request to a LiveView Native route, the route expects additional query
parameters to be provided to denote platform-specific information from the client. This information is what allows
LiveView Native to delegate the request to the appropriate rendering package and codepath, and
maintain support with Phoenix LiveView.

The query parameters are as follows.

| Query Parameter | Arguments                | Required? | Description                                            |
|-----------------|--------------------------|-----------|--------------------------------------------------------|
| `_format`       | swiftui, jetpack, html   | ✅        | The content type to be processed by LiveView Native    |
| `_interface`    | mobile, watch, tv        |           | The general device type                                |
| `os_version`    | `string`                 |           | The version of the client OS                           |
| `app_version`   | `string`                 |           | The version of the client application                  |

This is formatted as `/?_format=xx&_interface=xx&os_version=xx&app_version=xx`, and when no query parameters are provided,
will default to the corresponding Phoenix LiveView route (presuming a route is provided).

### Processing

Once a request is sucessfully delegated by LiveView Native, it will attempt to match on your LiveView route.

By design, LiveView Native does not ship with a default rendering package, and instead seperates
itself into a series of distinct packages. Each package ships with its own modifiers to handle its respective client,
and unlike many framework agnostic development frameworks, intentionally seperates your markup by platform.

This is to maintain instant feature parity with your platform(s) of choice, as LiveView Native is not concerned with
cross-platform "bridging." This allows LiveView Native to serve native code to the platform target
with no changes to the underlying client.

So long as your client supports the underlying components sent back, it will render!

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

The modules above show a distinct path to each format handled by its respective rendering package.
We start in our Phoenix LiveView, which handles our mount and event handling. From there, LiveView Native
delegates the request to our markup modules, which handle our rendering. We use the `~LVN` sigil to define a
NEEx template, which stands for Native+EEx. They are nearly identical to HEEx templates, but used to denote
the usage of native markup.

This is a similar procedure to standard LiveViews, with the only difference being the `LiveViewNative.Component.sigil_LVN/2` and our two arity
`render/2` function – containing a map we can use to match on device type and other metadata (Similar
to LiveView, we import above functions automatically when using `LiveViewNative.LiveView`).

The rest is quite akin to a standard LiveView, and will interop directly into your existing Phoenix LiveView
application. For more information on the component lifecycle, check `LiveViewNative.Component`.

### Handling

Once a sucessful response is sent back from the server, we need a client to process this data.
Similar to most native development, we need the respective platform's development tools to build and deploy
your LiveView Native client, but as we continue to build our tooling, we are begining to offer platform-specific applications
to test your project.

Corresponding documentation for each client is available in our supported rendering packages, and will walk you through
the setup needed to test in each environment.

## Supported Clients

LiveView Native enables client frameworks in the following.

| UI Framework     | Devices                                                     | Rendering Package                                                                     | Build Tool     | Testing Client                                              |
|------------------|-------------------------------------------------------------|---------------------------------------------------------------------------------------|----------------|-------------------------------------------------------------|
| SwiftUI          | iPhone, iPad, AppleTV, Apple Watch, MacOS, Apple Vision Pro | [LiveView Native SwiftUI](https://github.com/liveview-native/liveview-client-swiftui) | XCode          | [LVN Go](https://apps.apple.com/us/app/lvn-go/id6614695506) |
| JetPack Compose  | Android family                                              | [LiveView Native Jetpack](https://github.com/liveview-native/liveview-client-jetpack) | Android Studio |                                                             |
| HTML             |                                                             | [LiveView Native HTML](https://github.com/liveview-native/liveview-client-html)       |                |                                                             |
