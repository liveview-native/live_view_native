# Getting Started

[![Run in Livebook](https://livebook.dev/badge/v1/blue.svg)](https://livebook.dev/run?url=https%3A%2F%2Fraw.githubusercontent.com%2Fliveview-native%2Flive_view_native%2Fmain%2Fguides%2Fnotebooks%getting-started.livemd)
## Overview

Our Interactive Guides offer an interactive tutorial for LiveView Native using Livebook. They teach LiveView Native concepts step-by-step and assume some familiarity with [Phoenix LiveView](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html) applications.

We suggest using Livebook to run these guides for the best experience. Click the "Run in Livebook" badge to import the guide into Livebook.

Guides are isolated from each other so that you can complete guides in any order. However, we recommend completing the guides chronologically for the most comprehensive learning experience.

## Prerequisites

To use these guides, you'll need to install the following prerequisites:

* [Elixir/Erlang](https://elixir-lang.org/install.html)
* [Livebook](https://livebook.dev/)
* [Xcode](https://developer.apple.com/xcode/)

While not necessary for our guides, we also recommend you install the following for general LiveView Native development:

* [Phoenix](https://hexdocs.pm/phoenix/installation.html)
* [PostgreSQL](https://www.postgresql.org/download/)

## Hello World

If you are not already running this guide in Livebook, click on the "Run in Livebook" badge at the top of this page to import this guide into Livebook.

Then, you can evaluate the following smart cell and visit http://localhost:4000 to ensure this Livebook works correctly.

<!-- livebook:{"attrs":{"action":":index","code":"defmodule Server.HomeLive do\n  use Phoenix.LiveView\n  use LiveViewNative.LiveView\n\n  @impl true\n  def render(%{platform_id: :swiftui} = assigns) do\n    ~SWIFTUI\"\"\"\n    <Text>\n      Hello Again from LiveView Native!\n    </Text>\n    \"\"\"\n  end\n\n  def render(assigns) do\n    ~H\"\"\"\n    <div style=\"color: red;\">Hello from LiveView!</div>\n    \"\"\"\n  end\nend","path":"/"},"chunks":[[0,109],[111,350],[463,45],[510,49]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule Server.HomeLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def render(%{platform_id: :swiftui} = assigns) do
    ~SWIFTUI"""
    <Text>
      Hello Again from LiveView Native!
    </Text>
    """
  end

  def render(assigns) do
    ~H"""
    <div style="color: red;">Hello from LiveView!</div>
    """
  end
end
```

Change `Hello from LiveView!` to `Hello again from LiveView!` in the above LiveView. Notice the application live reloads and automatically updates in the browser.

## Troubleshooting

Some common issues you may encounter are:

* Another server is already running on port 4000.
* Your version of Livebook needs to be updated.
* Your version of Elixir/Erlang needs to be updated.
* Your version of Xcode needs to be updated.

Ensure you have the latest versions of all necessary software installed, and ensure no other servers are running on port 4000.
If that does not resolve the issue, you can [raise an issue](https://github.com/liveview-native/live_view_native/issues/new) to receive support from the LiveView Native team.

