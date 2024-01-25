# Deployment

To deploy LiveView Native, both the Phoenix Server and the native client need to be deployed separately. Each Application has a separate deployment process. This guide provides links to other documentation that can aid in deploying the Phoenix app and the SwiftUI Client on the Apple App Store. Additionally, we have documented a few steps specifically for LiveView Native deployment.

## Phoenix Deployment

Phoenix provides detailed and comprehensive [Deployment Documentation](https://hexdocs.pm/phoenix/deployment.html). Follow their instructions to deploy your Phoenix application before deploying the SwiftUI application. This is important to ensure that the SwiftUI application functions properly and passes the App Store Review process.

The Phoenix Documentation includes how to work with providers such as [Fly](https://hexdocs.pm/phoenix/fly.html) and [Gigalixir](https://hexdocs.pm/phoenix/gigalixir.html) to simplify the deployment process.

### Including Custom Config Files

Deployment providers like Fly may not allow for customized configuration files like the `native.exs` file included when you run `mix lvn.install` in a Phoenix application. 

If you encounter issues like the one below that we faced when deploying to Fly, it's important to keep this in mind.

```sh
 => ERROR [builder  9/17] RUN mix deps.compile                                                                                                                                                        0.7s
------
 > [builder  9/17] RUN mix deps.compile:
#0 0.717 ** (File.Error) could not read file "/app/config/native.exs": no such file or directory
#0 0.717     (elixir 1.15.6) lib/file.ex:358: File.read!/1
#0 0.717     (elixir 1.15.6) lib/config.ex:275: Config.__import__!/1
#0 0.717     /app/config/config.exs:68: (file)
#0 0.717     (stdlib 5.1) erl_eval.erl:750: :erl_eval.do_apply/7
#0 0.717     (stdlib 5.1) erl_eval.erl:136: :erl_eval.exprs/6
```

In these cases, you must change your provider configuration to use the file or put the custom configuration directly in `config.exs`.

For example, if using a `Dockerfile`, ensure the `native.exs` file is copied along with any other configuration. The example below is a modified version of the same COPY command in Fly's default generated `Dockerfile`.

```dockerfile
# copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY config/config.exs config/${MIX_ENV}.exs config/native.exs config/
```

Alternatively, you may find it easier to move the contents of `native.exs` into your `config.exs` as this will work regardless of which deployment provider you use.

```elixir
# Import LiveView Native configuration
# import_config "native.exs" (commented for clarity of example)
config :live_view_native, plugins: [LiveViewNative.SwiftUI] 

config :live_view_native_stylesheet, parsers: [swiftui: LiveViewNative.SwiftUI.RulesParser]
```

### Testing the Production App Locally

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

The Apple App Store hosts native OS applications. Deploying a LiveView Native client application follows mostly the same process as deploying any other app to the Apple App Store.

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

The SwiftUI `LiveView` automatically determines which URL to communicate with, depending on the build environment.

This configuration automatically selects which URL the SwiftUI `LiveView` will communicate with, either the local development server or the production server.

### App Store Submission

View the App Store [Submitting](https://developer.apple.com/app-store/submitting/) guide for more information on deploying your client Application.

Using your iPhone, iPad, or Mac, you'll need to enroll with the [Apple Developer App](https://developer.apple.com/enroll/app) to deploy and manage applications on the App Store.

## Redeploying: Apple Developer Program License Agreement

As with any SSR (server-side rendering) technology, you may implement new features that do not require changes to your client application.

However, these changes may still require an Apple App Store Review to ensure you are compliant with the [Apple Developer Program License Agreement](https://developer.apple.com/support/terms/apple-developer-program-license-agreement/#ADPLA3.3).

For a more thorough understanding of when changes require an App Store Review, see section 3.3.1B

> Interpreted code may be downloaded to an Application but only so long as such code: (a) does not change the primary purpose of the Application by providing features or functionality that are inconsistent with the intended and advertised purpose of the Application as submitted to the App Store, (b) does not create a store or storefront for other code or applications, and (c) does not bypass signing, sandbox, or other security features of the OS.

Section 3.3.1C explicitly warns that you must go through an Apple App Store review when adding new features.

> Without Apple’s prior written approval or as permitted under **Section 3.3.9(A) (In-App Purchase API)**, an Application may not provide, unlock or enable additional features or functionality through distribution mechanisms other than the App Store, Custom App Distribution or TestFlight.