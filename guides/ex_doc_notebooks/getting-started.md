# Getting Started

[![Run in Livebook](https://livebook.dev/badge/v1/blue.svg)](https://livebook.dev/run?url=https%3A%2F%2Fraw.githubusercontent.com%2Fliveview-native%2Flive_view_native%2Fmain%2Fguides%2Fnotebooks%getting-started.livemd)

## Overview

Our interactive guides provide a step-by-step tutorial for learning LiveView Native using Livebook. These guides assume that you already have some familiarity with Phoenix LiveView applications.

For the best experience, we recommend using Livebook to run these guides. Simply click on the "Run in Livebook" badge to import the guide into Livebook.

Each guide is designed to be completed independently, but we suggest following them chronologically for the most comprehensive learning experience.

## Prerequisites

To use these guides, you'll need to install the following prerequisites:

* [Elixir/Erlang](https://elixir-lang.org/install.html)
* [Livebook](https://livebook.dev/)
* [Xcode](https://developer.apple.com/xcode/)

While not necessary for our guides, we also recommend you install the following for general LiveView Native development:

* [Phoenix](https://hexdocs.pm/phoenix/installation.html)
* [PostgreSQL](https://www.postgresql.org/download/)
* [LiveView Native VS Code Extension](https://github.com/liveview-native/liveview-native-vscode)

## Hello World

If you are not already running this guide in Livebook, click on the "Run in Livebook" badge at the top of this page to import this guide into Livebook.

Then, you can evaluate the following smart cell and visit http://localhost:4000 to ensure this Livebook works correctly.

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5Ib21lTGl2ZSBkb1xuICB1c2UgUGhvZW5peC5MaXZlVmlld1xuICB1c2UgTGl2ZVZpZXdOYXRpdmUuTGl2ZVZpZXdcblxuICBAaW1wbCB0cnVlXG4gIGRlZiByZW5kZXIoJXtwbGF0Zm9ybV9pZDogOnN3aWZ0dWl9ID0gYXNzaWducykgZG9cbiAgICB+U1dJRlRVSVwiXCJcIlxuICAgIDxUZXh0PlxuICAgICAgSGVsbG8gZnJvbSBMaXZlVmlldyBOYXRpdmUhXG4gICAgPC9UZXh0PlxuICAgIFwiXCJcIlxuICBlbmRcblxuICBkZWYgcmVuZGVyKGFzc2lnbnMpIGRvXG4gICAgfkhcIlwiXCJcbiAgICA8cD5IZWxsbyBmcm9tIExpdmVWaWV3ITwvcD5cbiAgICBcIlwiXCJcbiAgZW5kXG5lbmQiLCJwYXRoIjoiLyJ9","chunks":[[0,109],[111,320],[433,45],[480,49]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule Server.HomeLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def render(%{platform_id: :swiftui} = assigns) do
    ~SWIFTUI"""
    <Text>
      Hello from LiveView Native!
    </Text>
    """
  end

  def render(assigns) do
    ~H"""
    <p>Hello from LiveView!</p>
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

