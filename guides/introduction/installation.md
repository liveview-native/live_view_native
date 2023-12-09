# Installation

There are a number of steps that must be completed before you can use LiveView Native. This document covers them, which are as follows:

1. Setup your Phoenix project with the minimum required versions of Elixir, Phoenix and LiveView
2. Add LiveView Native to your `mix.exs` dependencies
3. Add any number of platform libraries to enable support for native clients
4. Configure your project to use LiveView Native
5. Update your application's web module, router and layouts

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
    {:live_view_native, "~> 0.2"}
  ]
end
```

## 3. Add platform libraries

The `:live_view_native` dependency isn't useful on its own. You'll also need to add any _platform libraries_ you want your project to be compatible with. These libraries provide the platform-specific code that allows them to connect to your app and render LiveViews within their native environments.

This guide covers installation for the officially supported platforms, [SwiftUI](https://hexdocs.pm/live_view_native_swiftui) (iOS, macOS and watchOS) and [Jetpack](https://hexdocs.pm/live_view_native_jetpack) (Android).

<!-- tabs-open -->

### SwiftUI
Adds compatibility for iOS 16+, macOS 13+ and watchOS 9+.

```elixir
def deps do
  [
    # other dependencies here...
    {:live_view_native_swiftui, "~> 0.2"}
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

Make sure to fetch any dependencies you've added to your `mix.exs` before continuing:

```bash
mix deps.get
```

## 4. Configure LiveView Native

LiveView Native includes a Mix task that can automatically handle the process of configuring your project to support it. If that is not to your liking, manual setup is also an option. This guide includes instructions for both of these approaches.

<!-- tabs-open -->

### Guided (recommended)

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
    LiveViewNative.SwiftUI,
    LiveViewNative.Jetpack
  ]

# LiveView Native Stylesheet support
# Omit this if you're not using platforms that support LiveView
# Native stylesheets
config :live_view_native_stylesheet,
  parsers: [
    swiftui: LiveViewNative.SwiftUI.RulesParser
  ]
```

Next, create a project for each platform's native client using the official tools provided by each platform.
This step varies across platforms — for example, SwiftUI development uses [Xcode](https://developer.apple.com/xcode/)
and so you'll need to know how to [create a new Xcode project](https://developer.apple.com/documentation/xcode/creating-an-xcode-project-for-an-app),
add [`liveview-client-swiftui`](https://github.com/liveview-native/liveview-client-swiftui) as a [package dependency](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app), [configure your device targets](https://developer.apple.com/documentation/xcode/configuring-a-new-target-in-your-project)
and write the glue code in Swift to connect to your Phoenix application. For Jetpack this process involves working with
[Android Studio](https://developer.android.com/studio) and Kotlin to create the client, since those are the tools relevant
to Android development.

Manual configuration at this point is outside of the scope of these HexDocs but each platform library should have more
information within its own documentation. To find that, consult the official repositories for each platform library
that you need to create a native client app for.

<!-- tabs-close -->

## 5. Update your application code

After running `mix lvn.install` to configure the LiveView Native framework, you will need to integrate it with
your application. This will involve making the following changes to your Phoenix application's code:

- Using `LiveViewNative.LiveView` and `LiveViewNative.LiveComponent` in your web module
- Adding the `LiveViewNative.SessionPlug` plug to your router's `:browser` pipeline
- Allowing Phoenix to render native layouts by using `LiveViewNative.Layouts` in your layouts module and scoping `embed_templates/1` to `*.html` instead of `*`

These changes are required to use LiveView Native. The following subsections describe these changes in more detail
and how to properly apply them.

### 5a. Use LiveView Native in your web module

Most Phoenix-related modules in your application will `use` a web module that was automatically
generated for you when running `mix phx.gen`. By default, this module might be named something like
`MyAppWeb` and would be found at `lib/my_app_web/my_app_web.ex` (replacing `my_app` with the actual
name of your app). This is your app's _web module_.

Within the web module, you should find functions called `live_view` and `live_component`. Update these
functions so that inside each function's `quote` block it contains `use LiveViewNative.LiveView` and
`use LiveViewNative.LiveComponent` respectively. _Be sure to add only those two lines without changing
or deleting anything else_:

```elixir
defmodule MyAppWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, components, channels, and so on...
  """

  # (truncated for example purposes...)

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {MyAppWeb.Layouts, :app}

      # LiveView Native support
      use LiveViewNative.LiveView

      unquote(html_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      # LiveView Native support
      use LiveViewNative.LiveComponent

      unquote(html_helpers())
    end
  end

  # (truncated for example purposes...)
end
```

These two lines upgrade LiveViews and LiveComponents in your app with the ability to render native
UI code in addition to HTML. Once these changes are saved, move on to the second part of this section
which is updating your app's router to be able to handle native sessions.

### 5b. Add the LiveView Native session plug to your router.ex

Your Phoenix router defines the various paths to resources within your app, such as
API endpoints, static pages and of course LiveViews. Native clients that connect to
your app also pass through the router and you need to ensure that it can properly
handle these non-web connections.

Update your router (located somewhere like `lib/my_app_web/router.ex`) so that the 
`:browser` pipeline near the top of the file contains the `LiveViewNative.SessionPlug`:

```elixir
defmodule MyAppWeb.Router do
  use MyAppWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash

    # (truncated for example purposes...)

    # LiveView Native support
    plug LiveViewNative.SessionPlug
  end

  # (truncated for example purposes...)
end
```

With this plug, your router is now able to understand the initial request payloads that LiveView
Native clients send when connecting to your app. With that change to your router saved, you can now
move on to the third and final step of this installation guide, updating your layout module. 

### 5c. Allow your app to render native layouts 

Phoenix applications are made up of two layouts, a root layout and an app layout. Typically these
layouts are HTML-based which only works in a web environment. To avoid layout templates for the web
from rendering in non-web environments and to allow writing native layouts, you'll need to update
Phoenix's root layout module so that it's compatible with LiveView Native.

Open your app's main layout module, typically located at `lib/my_app_web/components/layouts.ex`,
and change any `embed_templates` lines so that the catch-all wildcard `*` is replaced with one that
only checks for files with the `*.html` extension. Also, add `use LiveViewNative.Layouts` near the
top of the file to add support for native layouts:

```elixir
defmodule MyAppWeb.Layouts do
  use MyAppWeb, :html
  use LiveViewNative.Layouts

  # changed from `embed_templates "layouts/*"`
  embed_templates "layouts/*.html"
end
```

If you have templates for other file extensions, like `.json` or `.txt`, you can add separate `embed_templates`
lines for those as well. The important point is to avoid the catch-all `*` as it will cause the default Phoenix
template system to try to compile HEEx templates with non-HTML syntax like files ending in `.swiftui.heex` and
`.jetpack.heex`. This will cause an error like this which prevents your app from compiling: 

```
== Compilation error in file lib/my_app_web/components/layouts.ex ==
** (Phoenix.LiveView.Tokenizer.ParseError) lib/my_app_web/components/layouts/root.swiftui.heex:1:1: invalid tag <NavigationStack>
  |
1 | <NavigationStack>
  | ^
    (phoenix_live_view 0.19.5) lib/phoenix_live_view/tag_engine.ex:1391: Phoenix.LiveView.TagEngine.raise_syntax_error!/3
    (phoenix_live_view 0.19.5) lib/phoenix_live_view/tag_engine.ex:452: Phoenix.LiveView.TagEngine.handle_token/2
    (elixir 1.15.6) lib/enum.ex:2510: Enum."-reduce/3-lists^foldl/2-0-"/3
    (phoenix_live_view 0.19.5) lib/phoenix_live_view/tag_engine.ex:182: Phoenix.LiveView.TagEngine.handle_body/1
    (phoenix_live_view 0.19.5) expanding macro: Phoenix.LiveView.HTMLEngine.compile/1
    lib/my_app_web/components/layouts/root.swiftui.heex: LvnExampleWeb.Layouts.root/1
```

Once your layout module has been updated appropriately, save the changes and continue.

## Post-Installation

If you've reached this section, you should have already done the following:

- Added `:live_view_native` and any platform libraries to your list of dependencies in `mix.exs`.
- Run `mix lvn.install` or configured LiveView Native manually.
- Updated your web module, router and layouts module with LiveView Native specific code.

If all of these steps have been completed properly, you should be able to run your Phoenix app in development as usual:

```bash
iex -S mix phx.server
```

To confirm that LiveView Native has been properly installed, call the following function in an IEx
session. It should return a map describing all of the native platform libraries that have been installed
for your app.

```elixir
iex(1)> LiveViewNative.platforms()
```

Confirm that each platform listed (excluding `html`) has a platform-specific client app (i.e. Xcode,
Android Studio, etc.) for connecting to your LiveView Native backend. If you used `mix lvn.install`
to enable LiveView Native, these project files will be placed in the `native/` directory of your app.  

If everything looks good, continue on to writing [your first native LiveView](./your-first-native-liveview.md).