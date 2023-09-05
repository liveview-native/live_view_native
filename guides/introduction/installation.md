# Installation

There are a few steps that must be completed before you can use LiveView Native. This document covers them, which are as follows:

1. Setup a Phoenix project with the minimum required versions of Elixir, Phoenix and LiveView.
2. Add LiveView Native to your `mix.exs` dependencies.
3. Add any number of platform libraries to enable support for native clients.
4. Fetch dependencies.
5. Enable LiveView Native within your app.

## 1. Prepare your Phoenix app

To use LiveView Native, you must have an existing Phoenix project. If you don't have one, follow the [Up and Running](https://hexdocs.pm/phoenix/up_and_running.html) section of the official Phoenix guide to create one.

Next, make sure your project meets the following requirements:

- it uses **Elixir 1.15 or greater** — to enforce this, update your `mix.exs`:
```elixir
def project do
  [
    # ...
    elixir: "~> 1.15",
    # ...
  ]
end
```

- it uses **Phoenix >= 1.7** and **Phoenix LiveView >= 0.18** — your `mix.exs` should partially resemble this:
```elixir
def deps do
  [
    {:phoenix, "~> 1.7"},
    {:phoenix_live_view, "~> 0.18"},
    # other dependencies here...
  ]
end
```

If your project doesn't meet this criteria then it will need to be upgraded. Some helpful resources for this include the [Elixir installation page](https://elixir-lang.org/install.html), [Phoenix installation page](https://hexdocs.pm/phoenix/installation.html), as well as the changelogs for [Elixir](https://github.com/elixir-lang/elixir/blob/main/CHANGELOG.md), [Phoenix](https://github.com/phoenixframework/phoenix/blob/main/CHANGELOG.md) and [Phoenix LiveView](https://github.com/phoenixframework/phoenix_live_view/blob/main/CHANGELOG.md).

## 2. Add LiveView Native

Once you've met the requirements to use LiveView Native, simply add it to your list of dependencies in your project's mix.exs:

```elixir
def deps do
  [
    # other dependencies here...
    {:live_view_native, "~> 0.1"}
  ]
end
```

## 3. Add platform libraries

The `:live_view_native` dependency isn't useful on its own. You'll also need to add any _platform libraries_ you want your project to be compatible with. Platform libraries provide the native implementations that allow those platforms' clients to connect to your app and render LiveView paths as native user interfaces.

This guide only covers installation for the officially supported platforms, [SwiftUI](https://hexdocs.pm/live_view_native_swift_ui) (iOS, macOS and watchOS) and [Jetpack](https://hexdocs.pm/live_view_native_jetpack) (Android). For information on using a third-party platform, consult that library's documentation. 

<!-- tabs-open -->

### SwiftUI
Adds compatibility for iOS 16+, macOS 13+ and watchOS 9+.

```elixir
def deps do
  [
    # other dependencies here...
    {:live_view_native_swift_ui, "~> 0.1"}
  ]
end
```

### Jetpack

Adds compatibility for Android.

> #### Warning {: .warning}
> The Jetpack client is under development and is not yet usable in end-user applications.
> For more information, check the repo for `live_view_native_jetpack` [here](https://github.com/liveview-native/liveview-client-jetpack).

```elixir
def deps do
  [
    # other dependencies here...
    {:live_view_native_jetpack, "~> 0.0.0"}
  ]
end
```

<!-- tabs-close -->

## 4. Fetch dependencies

Next, fetch any new dependencies you added to your `mix.exs`.

```bash
mix deps.get
```

## 5. Enable LiveView Native

LiveView Native includes a Mix task that can automatically handle the process of configuring your project to support it. If that is not to your liking, manual setup is also an option. This guide includes instructions for both of these approaches.

<!-- tabs-open -->

### Automatic

Within your project directory, run the following command:

```bash
mix lvn.install
```

This command will prompt you to answer a few questions. If everything goes well, you should see a message that your project has been configured to use LiveView Native.

### Manual

After adding the `:live_view_native` Hex package and any platform libraries, define a key-value configuration in your [Config](https://hexdocs.pm/elixir/main/Config.html) file (this is typically found in `config/config.exs`). This configuration expects a `:plugins` option which takes a list of any platform libraries you want your application to support. Platform libraries are represented by their top-level namespace module:

```elixir
# config.exs

# Use LiveView Native to add support for native platforms
config :live_view_native,
  plugins: [
    # other plugins here...
    LiveViewNativeSwiftUi,
    LiveViewNativeJetpack
  ]
```

Next, create a project for each platform's native client using the official tools provided by each platform.

<!-- tabs-close -->

## Post-Installation

Once LiveView Native is installed and your application is properly configured, you should be able to run your
Phoenix app in development as usual:

```bash
iex -S mix phx.server
```

To confirm that LiveView Native has been properly installed, call the following function in an IEx
session. It should return a map describing all of the native platform libraries that have been installed
for your app.

```elixir
iex(1)> LiveViewNative.platforms()
```

Confirm that each platform listed (excluding `web`) has a platform-specific client app (i.e. Xcode,
Android Studio, etc.) for connecting to your LiveView Native backend. If you used `mix lvn.install`
to enable LiveView Native, these project files will be placed in the `native/` directory of your app.  

If everything looks good, continue on to writing [your first native LiveView](./your-first-native-liveview.md).