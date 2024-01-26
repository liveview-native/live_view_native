# Getting Started

[![Run in Livebook](https://livebook.dev/badge/v1/blue.svg)](https://livebook.dev/run?url=https%3A%2F%2Fraw.githubusercontent.com%2Fliveview-native%2Flive_view_native%2Fmain%2Fguides%2Fnotebooks%getting-started.livemd)

## Overview

Our interactive guides provide a step-by-step tutorial for learning LiveView Native using Livebook. These guides assume that you already have some familiarity with Phoenix LiveView applications.

For the best experience, we recommend using Livebook to run these guides. Simply click on the "Run in Livebook" badge to import the guide into Livebook.

Each guide can be completed independently, but we suggest following them chronologically for the most comprehensive learning experience.

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

<!-- livebook:{"attrs":"e30","chunks":[[0,109],[111,306],[419,45],[466,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule Server.ExampleLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <Text>Hello from LiveView Native!</Text>
    """
  end

  def render(assigns) do
    ~H"""
    <p>Hello from LiveView!</p>
    """
  end
end
```

Change `Hello from LiveView!` to `Hello again from LiveView!` in the above LiveView. Re-evaluate the cell and notice the application live reloads and automatically updates in the browser.

## Troubleshooting

Some common issues you may encounter are:

* Another server is already running on port 4000.
* Your version of Livebook needs to be updated.
* Your version of Elixir/Erlang needs to be updated.
* Your version of Xcode needs to be updated.
* This Livebook has cached outdated versions of dependencies

Ensure you have the latest versions of all necessary software installed, and ensure no other servers are running on port 4000.

To clear the cache, you can click the `Setup without cache` button revealed by clicking the dropdown next to the `setup` button at the top of the Livebook.

If that does not resolve the issue, you can [raise an issue](https://github.com/liveview-native/live_view_native/issues/new) to receive support from the LiveView Native team.

