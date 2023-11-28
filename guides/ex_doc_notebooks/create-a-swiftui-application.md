# Create a SwiftUI Application

[![Run in Livebook](https://livebook.dev/badge/v1/blue.svg)](https://livebook.dev/run?url=https%3A%2F%2Fraw.githubusercontent.com%2Fliveview-native%2Flive_view_native%2Fmain%2Fguides%2Fnotebooks%create-a-swiftui-application.livemd)
## Overview

This guide will teach you how to set up a SwiftUI Application for LiveView Native.

Typically, we recommend using the `mix lvn.install` task as described in the [Installation Guide](https://hexdocs.pm/live_view_native/installation.html#5-enable-liveview-native) to add LiveView Native to a Phoenix project. However, we will walk through the steps of manually setting up an Xcode IOS project to learn how the IOS side of a LiveView Native application works.

In future lessons, you'll use this IOS application to view IOS examples in the Xcode simulator (or a physical device if you prefer.)

## Prerequisites

First, make sure you have followed the [Getting Started](./getting_started.livemd) guide. Then evaluate the smart cell below and visit http://localhost:4000 to ensure the Phoenix server runs properly. You should see the text `Hello from LiveView!`

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIE15QXBwLkhvbWVMaXZlIGRvXG4gIHVzZSBQaG9lbml4LkxpdmVWaWV3XG4gIHVzZSBMaXZlVmlld05hdGl2ZS5MaXZlVmlld1xuXG4gIEBpbXBsIHRydWVcbiAgZGVmIHJlbmRlcigle3BsYXRmb3JtX2lkOiA6c3dpZnR1aX0gPSBhc3NpZ25zKSBkb1xuICAgIH5TV0lGVFVJXCJcIlwiXG4gICAgPFRleHQ+XG4gICAgICBIZWxsbyBmcm9tIExpdmVWaWV3IE5hdGl2ZSFcbiAgICA8L1RleHQ+XG4gICAgXCJcIlwiXG4gIGVuZFxuICBcbiAgZGVmIHJlbmRlcihhc3NpZ25zKSBkb1xuICAgIH5IXCJcIlwiXG4gICAgPGRpdj5IZWxsbyBmcm9tIExpdmVWaWV3ITwvZGl2PlxuICAgIFwiXCJcIlxuICBlbmRcbmVuZCIsInBhdGgiOiIvIn0","chunks":[[0,109],[111,325],[438,45],[485,49]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule MyApp.HomeLive do
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
    <div>Hello from LiveView!</div>
    """
  end
end
```

## Create the IOS Application

Open XCode and select Create New Project.

<!-- livebook:{"break_markdown":true} -->

![XCode Create New Project](https://github.com/BrooklinJazz/live_view_native_assets/blob/main/xcode-create-new-project.png?raw=true)

<!-- livebook:{"break_markdown":true} -->

Select the `iOS` and `App` options to create an iOS application. Then click `Next`.

<!-- livebook:{"break_markdown":true} -->

![Xcode Create Template For New Project](https://github.com/BrooklinJazz/live_view_native_assets/blob/main/xcode-create-template-for-new-project.png?raw=true)

<!-- livebook:{"break_markdown":true} -->

Choose options for your new project that match the following image, then click `Next`.

<details style="background-color: lightgreen; padding: 1rem; margin: 1rem 0;">
<summary>What do these options mean?</summary>

* **Product Name:** The name of the application. This can be any valid name. We've chosen `Guides`.
* **Organization Identifier:** A reverse DNS string that uniquely identifies your organization. If you don't have a company identifier, [Apple recomends](https://developer.apple.com/documentation/xcode/creating-an-xcode-project-for-an-app) using `com.example.your_name` where `your_name` is your organization or personal name.
* **Interface:**: Xcode generates an interface file that includes all your source code's internal and public declarations when using the Assistant editor, the Related Items, or the Navigate menu. Select `SwiftUI` since we're building a SwiftUI application.
* **Language:** Determines which language Xcode should use for the project. Select `Swift`.
</details>

<!-- livebook:{"break_markdown":true} -->

![Xcode Choose Options For Your New Project](https://github.com/BrooklinJazz/live_view_native_assets/blob/main/xcode-choose-options-for-your-new-project.png?raw=true)

<!-- livebook:{"break_markdown":true} -->

Select an appropriate folder location where you would like to store the iOS project, then click `Create`.

<!-- livebook:{"break_markdown":true} -->

![Xcode select folder location](https://github.com/BrooklinJazz/live_view_native_assets/blob/main/xcode-select-folder-location.png?raw=true)

## Add the LiveView Client SwiftUI Package

In Xcode from the project you just created, select `File -> Add Package Dependencies`. Then, search for `liveview-client-swiftui`. Once you have selected the package, click `Add Package`.

<!-- livebook:{"break_markdown":true} -->

![](https://github.com/BrooklinJazz/live_view_native_assets/blob/main/xcode-select-liveview-client-swiftui-package.png?raw=true)

<!-- livebook:{"break_markdown":true} -->

Choose the Package Products for `liveview-client-swiftui`. Select the iOS app you previously created as the `LiveViewNative` target.

<!-- livebook:{"break_markdown":true} -->

![](https://github.com/BrooklinJazz/live_view_native_assets/blob/main/xcode-choose-package-products-for-liveview-client-swiftui.png?raw=true)

<!-- livebook:{"break_markdown":true} -->

If the following prompt appears, select `Trust & Enable All` to enable the `liveview-client-swiftui` package we just added.

<!-- livebook:{"break_markdown":true} -->

![Xcode some build plugins are disabled](https://github.com/BrooklinJazz/live_view_native_assets/blob/main/xcode-some-build-plugins-are-disabled.png?raw=true)

## Setup the LiveSessionCoordinator and SwiftUI LiveView

The [ContentView](https://developer.apple.com/tutorials/swiftui-concepts/exploring-the-structure-of-a-swiftui-app#Content-view) contains the main view of our iOS application.

Replace the code in the `ContentView` file with the following to connect the SwiftUI application and the Phoenix application.

<!-- livebook:{"break_markdown":true} -->

```swift
import SwiftUI
import LiveViewNative

struct ContentView: View {
    @StateObject private var coordinator = LiveSessionCoordinator(
        {
            let prodURL = Bundle.main.object(forInfoDictionaryKey: "Phoenix Production URL") as? String

            #if DEBUG
            return URL(string: "http://localhost:4000")!
            #else
            return URL(string: URL || "https://example.com")!
            #endif
        }(),
        config: LiveSessionConfiguration(navigationMode: .replaceOnly)
    )
    
    var body: some View {
        LiveView(session: coordinator)
    }
}
```

<!-- livebook:{"break_markdown":true} -->

The code above sets up a [LiveSessionCoordinator](https://liveview-native.github.io/liveview-client-swiftui/documentation/liveviewnative/livesessioncoordinator), which is a session coordinator object that handles the initial connection and navigation on the iOS app. The code also renders a SwiftUI [LiveView](https://liveview-native.github.io/liveview-client-swiftui/documentation/liveviewnative/liveview), which renders the content sent by the Phoenix application on a given URL. By default, we've configured it to connect to any Phoenix app on http://localhost:4000.

<!-- livebook:{"break_markdown":true} -->

<!-- Learn more at https://mermaid-js.github.io/mermaid -->

```mermaid
graph LR;
  subgraph I[iOS App]
   direction TB
   ContentView
   SL[SwiftUI LiveView]
   SC[LiveSessionCoordinator]
  end
  subgraph P[Phoenix App]
    LiveView
  end
  I --> P
  ContentView --> SL
     ContentView --> SC

  
```

<!-- livebook:{"break_markdown":true} -->

To avoid confusion in the step above, here's how our `ContentView` should now look in Xcode.

<!-- livebook:{"break_markdown":true} -->

![](https://github.com/BrooklinJazz/live_view_native_assets/blob/main/xcode-replace-content-view.png?raw=true)

## Start the Active Scheme

Click the `start active scheme` button <i class="ri-play-fill"></i> to build the project and run it on the iOS simulator.

> A [build scheme](https://developer.apple.com/documentation/xcode/build-system) contains a list of targets to build, and any configuration and environment details that affect the selected action. For example, when you build and run an app, the scheme tells Xcode what launch arguments to pass to the app.
> 
> * https://developer.apple.com/documentation/xcode/build-system

If you encounter an issue with `LiveViewNativeMacros`, select `Trust & Enable` to resolve the problem.

<!-- livebook:{"break_markdown":true} -->

![](https://github.com/BrooklinJazz/live_view_native_assets/blob/main/xcode-live-view-native-macros-was-disabled.png?raw=true)

<!-- livebook:{"break_markdown":true} -->

The iOS Xcode simulator should start. If you encounter any issues, make sure you have installed all [Prerequisites](#prerequisites) and see the [Troubleshooting](#troubleshooting) section for help.

<!-- livebook:{"break_markdown":true} -->

<div style="height: 800; width: 100%; display: flex; height: 800px; justify-content: center; align-items: center;">
<img style="width: 100%; height: 100%; object-fit: contain" src="https://github.com/BrooklinJazz/live_view_native_assets/blob/main/xcode-ios-simulator-no-connection.png?raw=true"/>
</div>

<!-- livebook:{"break_markdown":true} -->

After you start the active scheme, the simulator should open the iOS application and display `Hello from LiveView Native!`.

<!-- livebook:{"break_markdown":true} -->

<div style="height: 800; width: 100%; display: flex; height: 800px; justify-content: center; align-items: center;">
<img style="width: 100%; height: 100%; object-fit: contain" src="https://github.com/BrooklinJazz/live_view_native_assets/blob/main/xcode-hello-from-liveview-native.png?raw=true"/>
</div>

## Live Reloading

The SwiftUI application will reload whenever changes occur on the connected Phoenix application.

Evaluate the following smart cell. The Xcode simulator should update automatically to display `Hello again from LiveView Native!`

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIE15QXBwLkhvbWVMaXZlIGRvXG4gIHVzZSBQaG9lbml4LkxpdmVWaWV3XG4gIHVzZSBMaXZlVmlld05hdGl2ZS5MaXZlVmlld1xuXG4gIEBpbXBsIHRydWVcbiAgZGVmIHJlbmRlcigle3BsYXRmb3JtX2lkOiA6c3dpZnR1aX0gPSBhc3NpZ25zKSBkb1xuICAgIH5TV0lGVFVJXCJcIlwiXG4gICAgPFRleHQ+XG4gICAgICBIZWxsbyBhZ2FpbiBmcm9tIExpdmVWaWV3IE5hdGl2ZSFcbiAgICA8L1RleHQ+XG4gICAgXCJcIlwiXG4gIGVuZFxuXG4gIGRlZiByZW5kZXIoYXNzaWducykgZG9cbiAgICB+SFwiXCJcIlxuICAgIDxkaXY+SGVsbG8gYWdhaW4gZnJvbSBMaXZlVmlldyE8L2Rpdj5cbiAgICBcIlwiXCJcbiAgZW5kXG5lbmQiLCJwYXRoIjoiLyJ9","chunks":[[0,109],[111,335],[448,45],[495,49]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule MyApp.HomeLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def render(%{platform_id: :swiftui} = assigns) do
    ~SWIFTUI"""
    <Text>
      Hello again from LiveView Native!
    </Text>
    """
  end

  def render(assigns) do
    ~H"""
    <div>Hello again from LiveView!</div>
    """
  end
end
```

## Troubleshooting

If you encountered any issues with the native application, here are some troubleshooting steps you can use:

* **Reset Package Caches:** In the Xcode application go to `File -> Packages -> Reset Package Caches`.
* **Update Packages:** In the Xcode application go to `File -> Packages -> Update to Latest Package Versions`.
* **Rebuild the Active Scheme**: In the Xcode application, press the `start active scheme` button <i class="ri-play-fill"></i> to rebuild the active scheme and run it on the Xcode simulator.
* Update your [XCode](https://developer.apple.com/xcode/) version if it is not already the latest version
* Check for error messages in the Livebook smart cells.

You can also [raise an issue](https://github.com/liveview-native/live_view_native/issues/new) if you would like support from the LiveView Native team.
