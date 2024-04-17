# Getting Started

```elixir
notebook_path = __ENV__.file |> String.split("#") |> hd()

Mix.install(
  [
    {:kino_live_view_native, github: "liveview-native/kino_live_view_native"}
  ],
  config: [
    server: [
      {ServerWeb.Endpoint,
       [
         server: true,
         url: [host: "localhost"],
         adapter: Phoenix.Endpoint.Cowboy2Adapter,
         render_errors: [
           formats: [html: ServerWeb.ErrorHTML, json: ServerWeb.ErrorJSON],
           layout: false
         ],
         pubsub_server: Server.PubSub,
         live_view: [signing_salt: "JSgdVVL6"],
         http: [ip: {127, 0, 0, 1}, port: 4000],
         secret_key_base: String.duplicate("a", 64),
         live_reload: [
           patterns: [
             ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg|styles)$",
             ~r/#{notebook_path}$/
           ]
         ]
       ]}
    ],
    kino: [
      group_leader: Process.group_leader()
    ],
    phoenix: [
      template_engines: [neex: LiveViewNative.Engine]
    ],
    phoenix_template: [format_encoders: [swiftui: Phoenix.HTML.Engine]],
    mime: [
      types: %{"text/swiftui" => ["swiftui"], "text/styles" => ["styles"]}
    ],
    live_view_native: [plugins: [LiveViewNative.SwiftUI]],
    live_view_native_stylesheet: [
      content: [
        swiftui: [
          "lib/**/*swiftui*",
          notebook_path
        ]
      ],
      output: "priv/static/assets"
    ]
  ],
  force: true
)
```

## Overview

Our livebook guides provide step-by-step lessons to help you learn LiveView Native using Livebook. These guides assume that you already have some familiarity with Phoenix LiveView applications.

You can read these guides online, or for the best experience we recommend you click on the "Run in Livebook" badge to import and run these guides locally with Livebook.

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

<!-- livebook:{"attrs":"eyJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlcldlYi5FeGFtcGxlTGl2ZS5Td2lmdFVJIGRvXG4gIHVzZSBTZXJ2ZXJOYXRpdmUsIFs6cmVuZGVyX2NvbXBvbmVudCwgZm9ybWF0OiA6c3dpZnR1aV1cblxuICBkZWYgcmVuZGVyKGFzc2lnbnMsIF9pbnRlcmZhY2UpIGRvXG4gICAgfkxWTlwiXCJcIlxuICAgIDxUZXh0PkhlbGxvLCBmcm9tIExpdmVWaWV3IE5hdGl2ZSE8L1RleHQ+XG4gICAgXCJcIlwiXG4gIGVuZFxuZW5kXG5cbmRlZm1vZHVsZSBTZXJ2ZXJXZWIuRXhhbXBsZUxpdmUgZG9cbiAgdXNlIFNlcnZlcldlYiwgOmxpdmVfdmlld1xuICB1c2UgU2VydmVyTmF0aXZlLCA6bGl2ZV92aWV3XG5cbiAgQGltcGwgdHJ1ZVxuICBkZWYgcmVuZGVyKGFzc2lnbnMpIGRvXG4gICAgfkhcIlwiXCJcbiAgICA8cD5IZWxsbyBmcm9tIExpdmVWaWV3ITwvcD5cbiAgICBcIlwiXCJcbiAgZW5kXG5lbmQiLCJwYXRoIjoiLyJ9","chunks":[[0,85],[87,408],[497,49],[548,51]],"kind":"Elixir.Server.SmartCells.LiveViewNative","livebook_object":"smart_cell"} -->

```elixir
require Server.Livebook
import Server.Livebook
import Kernel, except: [defmodule: 2]

defmodule ServerWeb.ExampleLive.SwiftUI do
  use ServerNative, [:render_component, format: :swiftui]

  def render(assigns, _interface) do
    ~LVN"""
    <Text>Hello, from LiveView Native!</Text>
    """
  end
end

defmodule ServerWeb.ExampleLive do
  use ServerWeb, :live_view
  use ServerNative, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <p>Hello from LiveView!</p>
    """
  end
end
|> Server.SmartCells.LiveViewNative.register("/")

import Server.Livebook, only: []
import Kernel
:ok
```

In an upcoming lesson, you'll set up an iOS application with Xcode so you can run code native examples.

## Your Turn: Live Reloading

Change `Hello from LiveView!` to `Hello again from LiveView!` in the above LiveView. Re-evaluate the cell and notice the application live reloads and automatically updates in the browser.

## Kino LiveView Native

To run a Phoenix Server setup with LiveView Native from within Livebook we built the [Kino LiveView Native](https://github.com/liveview-native/kino_live_view_native) library.

Whenever you run one of our Livebooks, a server starts on localhost:4000. Ensure you have no other servers running on port 4000

Kino LiveView Native defines the **LiveView Native: LiveView** and **LiveViewNative: Render Component** smart cells within these guides.

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
