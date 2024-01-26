# Create a SwiftUI Application

[![Run in Livebook](https://livebook.dev/badge/v1/blue.svg)](https://livebook.dev/run?url=https%3A%2F%2Fraw.githubusercontent.com%2Fliveview-native%2Flive_view_native%2Fmain%2Fguides%2Fnotebooks%create-a-swiftui-application.livemd)

## Overview

This guide will teach you how to set up a SwiftUI Application for LiveView Native.

Typically, we recommend using the `mix lvn.install` task as described in the [Installation Guide](https://hexdocs.pm/live_view_native/installation.html#5-enable-liveview-native) to add LiveView Native to a Phoenix project. However, we will walk through the steps of manually setting up an Xcode iOS project to learn how the iOS side of a LiveView Native application works.

In future lessons, you'll use this iOS application to view iOS examples in the Xcode simulator (or a physical device if you prefer.)

## Prerequisites

First, make sure you have followed the [Getting Started](./getting_started.md) guide. Then evaluate the smart cell below and visit http://localhost:4000 to ensure the Phoenix server runs properly. You should see the text `Hello from LiveView!`

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

## Create the iOS Application

Open Xcode and select Create New Project.

<!-- livebook:{"break_markdown":true} -->

![Xcode Create New Project](https://github.com/liveview-native/documentation_assets/blob/main/xcode-create-new-project.png?raw=true)

<!-- livebook:{"break_markdown":true} -->

Select the `iOS` and `App` options to create an iOS application. Then click `Next`.

<!-- livebook:{"break_markdown":true} -->

![Xcode Create Template For New Project](https://github.com/liveview-native/documentation_assets/blob/main/xcode-create-template-for-new-project.png?raw=true)

<!-- livebook:{"break_markdown":true} -->

Choose options for your new project that match the following image, then click `Next`.

### What do these options mean?

* **Product Name:** The name of the application. This can be any valid name. We've chosen `Guides`.
* **Organization Identifier:** A reverse DNS string that uniquely identifies your organization. If you don't have a company identifier, [Apple recomends](https://developer.apple.com/documentation/xcode/creating-an-xcode-project-for-an-app) using `com.example.your_name` where `your_name` is your organization or personal name.
* **Interface:**: The Xcode user interface to use. Select **SwiftUI** to create an app that uses the SwiftUI app lifecycle.
* **Language:** Determines which language Xcode should use for the project. Select `Swift`.


<!-- livebook:{"break_markdown":true} -->

![Xcode Choose Options For Your New Project](https://github.com/liveview-native/documentation_assets/blob/main/xcode-choose-options-for-your-new-project.png?raw=true)

<!-- livebook:{"break_markdown":true} -->

Select an appropriate folder location where you would like to store the iOS project, then click `Create`.

<!-- livebook:{"break_markdown":true} -->

![Xcode select folder location](https://github.com/liveview-native/documentation_assets/blob/main/xcode-select-folder-location.png?raw=true)

## Add the LiveView Client SwiftUI Package

In Xcode from the project you just created, select `File -> Add Package Dependencies`. Then, search for `liveview-client-swiftui`. Once you have selected the package, click `Add Package`.

The image below was created using version `0.1.2`. You should select whichever is the latest version of LiveView Native.

<!-- livebook:{"break_markdown":true} -->

![](https://github.com/liveview-native/documentation_assets/blob/main/xcode-select-liveview-client-swiftui-package.png?raw=true)

<!-- livebook:{"break_markdown":true} -->

Choose the Package Products for `liveview-client-swiftui`. Select the iOS app you previously created as the `LiveViewNative` target.

<!-- livebook:{"break_markdown":true} -->

![](https://github.com/liveview-native/documentation_assets/blob/main/xcode-choose-package-products-for-liveview-client-swiftui.png?raw=true)

<!-- livebook:{"break_markdown":true} -->

At this point, you'll need to enable permissions for plugins used by LiveView Native.
You should see the following prompt. Click `Show in Issues Navigator`.

<!-- livebook:{"break_markdown":true} -->

![Xcode some build plugins are disabled](https://github.com/liveview-native/documentation_assets/blob/main/xcode-some-build-plugins-are-disabled.png?raw=true)

<!-- livebook:{"break_markdown":true} -->

If you do not see the prompt, manually navigate to the issues section of the Xcode Navigator and you'll see the plugins with permission issues.

<!-- livebook:{"break_markdown":true} -->

![Xcode Issues Navigator displaying disabled plugins](https://github.com/liveview-native/documentation_assets/blob/main/xcode-build-in-plugin-errors.png?raw=true)

<!-- livebook:{"break_markdown":true} -->

The specific plugins are subject to change. Click on each plugin that needs to be enabled. You'll see the following prompt. Select `Trust & Enable All` to enable the plugin.

<!-- livebook:{"break_markdown":true} -->

![CasePathMacros was disabled prompt](https://github.com/liveview-native/documentation_assets/blob/main/xcode-casepathsmacros-was-disabled.png?raw=true)

## Setup the SwiftUI LiveView

The [ContentView](https://developer.apple.com/tutorials/swiftui-concepts/exploring-the-structure-of-a-swiftui-app#Content-view) contains the main view of our iOS application.

Replace the code in the `ContentView` file with the following to connect the SwiftUI application and the Phoenix application.

<!-- livebook:{"break_markdown":true} -->

```swift
import SwiftUI
import LiveViewNative

struct ContentView: View {
    var body: some View {
        LiveView(.localhost)
    }
}

// Optionally preview the native UI in Xcode
#Preview {
    ContentView()
}
```

<!-- livebook:{"break_markdown":true} -->

The code above sets up the SwiftUI LiveView. By default, the SwiftUI LiveView connects to any Phoenix app running on http://localhost:4000.

<!-- livebook:{"break_markdown":true} -->

<!-- Learn more at https://mermaid-js.github.io/mermaid -->

```mermaid
graph LR;
  subgraph I[iOS App]
   direction TB
   ContentView
   SL[SwiftUI LiveView]
  end
  subgraph P[Phoenix App]
    LiveView
  end
  SL --> P
  ContentView --> SL

  
```

<!-- livebook:{"break_markdown":true} -->

To avoid confusion in the step above, here's how our `ContentView` should now look in Xcode.

<!-- livebook:{"break_markdown":true} -->

![](https://github.com/liveview-native/documentation_assets/blob/main/xcode-replace-content-view.png?raw=true)

## Start the Active Scheme

Click the `start active scheme` button <i class="ri-play-fill"></i> to build the project and run it on the iOS simulator.

> A [build scheme](https://developer.apple.com/documentation/xcode/build-system) contains a list of targets to build, and any configuration and environment details that affect the selected action. For example, when you build and run an app, the scheme tells Xcode what launch arguments to pass to the app.
> 
> * https://developer.apple.com/documentation/xcode/build-system

If you encounter an issue with `LiveViewNativeMacros`, select `Trust & Enable` to resolve the problem. You may need to click on the error in the Xcode error console to see the prompt.

<!-- livebook:{"break_markdown":true} -->

![](https://github.com/liveview-native/documentation_assets/blob/main/xcode-live-view-native-macros-was-disabled.png?raw=true)

<!-- livebook:{"break_markdown":true} -->

The iOS Xcode simulator should start. If you encounter any issues, make sure you have installed all [Prerequisites](#prerequisites) and see the [Troubleshooting](#troubleshooting) section for help.

<!-- livebook:{"break_markdown":true} -->

<div style="height: 800; width: 100%; display: flex; height: 800px; justify-content: center; align-items: center;">
<img style="width: 100%; height: 100%; object-fit: contain" src="https://github.com/liveview-native/documentation_assets/blob/main/xcode-ios-simulator-no-connection.png?raw=true"/>
</div>

<!-- livebook:{"break_markdown":true} -->

After you start the active scheme, the simulator should open the iOS application and display `Hello from LiveView Native!`.

<!-- livebook:{"break_markdown":true} -->

<div style="height: 800; width: 100%; display: flex; height: 800px; justify-content: center; align-items: center;">
<img style="width: 100%; height: 100%; object-fit: contain" src="https://github.com/liveview-native/documentation_assets/blob/main/xcode-hello-from-liveview-native.png?raw=true"/>
</div>

## Live Reloading

The SwiftUI application will reload whenever changes occur on the connected Phoenix application.

Evaluate the following smart cell. The Xcode simulator should update automatically to display `Hello again from LiveView Native!`

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIE15QXBwLkhvbWVMaXZlIGRvXG4gIHVzZSBQaG9lbml4LkxpdmVWaWV3XG4gIHVzZSBMaXZlVmlld05hdGl2ZS5MaXZlVmlld1xuXG4gIEBpbXBsIHRydWVcbiAgZGVmIHJlbmRlcigle3BsYXRmb3JtX2lkOiA6c3dpZnR1aX0gPSBhc3NpZ25zKSBkb1xuICAgIH5TV0lGVFVJXCJcIlwiXG4gICAgPFRleHQ+XG4gICAgICBIZWxsbyBhZ2FpbiBmcm9tIExpdmVWaWV3IE5hdGl2ZSFcbiAgICA8L1RleHQ+XG4gICAgXCJcIlwiXG4gIGVuZFxuXG4gIGRlZiByZW5kZXIoYXNzaWducykgZG9cbiAgICB+SFwiXCJcIlxuICAgIDxkaXY+SGVsbG8gYWdhaW4gZnJvbSBMaXZlVmlldyE8L2Rpdj5cbiAgICBcIlwiXCJcbiAgZW5kXG5lbmQiLCJwYXRoIjoiLyJ9","chunks":[[0,109],[111,335],[448,45],[495,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

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
* Update your [Xcode](https://developer.apple.com/xcode/) version if it is not already the latest version
* Check for error messages in the Livebook smart cells.

You can also [raise an issue](https://github.com/liveview-native/live_view_native/issues/new) if you would like support from the LiveView Native team.

