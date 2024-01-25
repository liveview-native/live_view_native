# Deployment

With LiveView Native, there are two separate applications. There's the Phoenix Server, and the iOS Client. Each of these applicatins have their own separate deployment process.

## Phoenix Deployment

Phoenix already provides thorough and comprehensive [Deployment Documentation](https://hexdocs.pm/phoenix/deployment.html). You can follow their instructions to deploy your Phoenix application. In general, we recommend Deploying your Phoenix application first, as it will be required for the iOS application to function properly.

Service providers such as [Fly](https://hexdocs.pm/phoenix/fly.html) and [Gigalixir](https://hexdocs.pm/phoenix/gigalixir.html) simplify the deployment process so you can 

### Configuring the native.exs config

Assuming you used `mix lvn.install` to configure LiveView Native in your Phoenix application, you should have a `native.exs` file with contents similar to the following.

```elixir
# This file is responsible for configuring LiveView Native.
# It is auto-generated when running `mix lvn.install`.
import Config

config :live_view_native, plugins: [LiveViewNative.SwiftUI]

config :live_view_native_stylesheet, parsers: [swiftui: LiveViewNative.SwiftUI.RulesParser]
```

This file is imported in `config.exs`.

```elixir
# Import LiveView Native configuration
import_config "native.exs"
```

However, providers such as Fly might not automatically pick up custom config files such as the `native.exs` file used by LiveView Native.

In these cases, you'll have to either change your provider configuration to use the file or put the contents of `native.exs` directly where they are used in `config.exs`. 

**Dockerfile**

For example, if using a `Dockerfile`, ensure the `native.exs` file is copied along with any other configuration. This is a modified version of the same COPY command you'll find in FLY's `Dockerfile`.

```
# copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY config/config.exs config/${MIX_ENV}.exs config/native.exs config/
```


Alternatively, you may find it easier to move the contents of `native.exs` into your `config.exs` as this will work regardless of which deployment provider you are using.

```elixir
# Import LiveView Native configuration
# import_config "native.exs" (commented for clarity of example)
config :live_view_native, plugins: [LiveViewNative.SwiftUI] 

config :live_view_native_stylesheet, parsers: [swiftui: LiveViewNative.SwiftUI.RulesParser]
```

### Testing The Production App Locally

Once you've deployed your Phoenix application, you can test it locally by changing the development URL in the SwiftUI `ContentView`. Make sure to change `https://hello-world-native.fly.dev//` to your production URL.

```swift
struct ContentView: View {
    var body: some View {
        LiveView(.automatic(
//            development: .localhost(path: "/"),
            development: .custom(URL(string: "https://hello-world-native.fly.dev//")!),
            production: .custom(URL(string: "https://hello-world-native.fly.dev//")!)
        ))
    }
}
```

While not strictly necessary, this can improve your confidence in the production app when you submit your client application to the Apple App Store.

## Deploying to the Apple App Store

SwiftUI Applications are hosted on the Apple App Store. Deploying a LiveView Native client application is mostly the same process as deploying any other app to the Apple App Store.

### Production URL

The `ContentView` of your SwiftUI Application should contain both a `development` and a `production` URL. Ensure the `production` URL matches the URL of your Phoenix server.

```elixir
struct ContentView: View {

    var body: some View {
        LiveView(.automatic(
            development: .localhost(path: "/"),
            production: .custom(URL(string: "https://example.com/")!)
        ))
    }
}
```

The SwiftUI `LiveView` automatically determines which URL to communicate with depending on the build environment.

This configuration automatically selects which URL the SwiftUI `LiveView` will communicate with, either the local development server or the production server. Make sure you correctly set your production URL to match the URL of your Phoenix application.

### App Store Submission

View the Apple App Store [Submitting](https://developer.apple.com/app-store/submitting/) guide for more information on how to deploy your SwiftUI Application.
Using your iPhone, iPad, or Mac, you'll need to enroll with the [Apple Developer App](https://developer.apple.com/enroll/app) deploy and manage applications on the App Store.