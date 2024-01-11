# Stylesheets

[![Run in Livebook](https://livebook.dev/badge/v1/blue.svg)](https://livebook.dev/run?url=https%3A%2F%2Fraw.githubusercontent.com%2Fliveview-native%2Flive_view_native%2Fmain%2Fguides%2Fnotebooks%stylesheets.livemd)

## Overview

In this guide, you'll learn how to style your LiveView Native Views using stylesheets. You'll learn some of the inner workings of how LiveView Native uses stylesheets to implement modifiers, and how those modifiers style and customize SwiftUI Views. By the end of this lesson you'll be armed with the foundations of building beautiful native UIs.

## The Stylesheet DSL

SwiftUI uses **modifiers** to style and customize views. In SwiftUI syntax (not LiveView Native), each modifier is a function that can be chained on the View they modify. Here's a basic example using the [foregroundStyle](https://developer.apple.com/documentation/swiftui/text/foregroundstyle(_:)) modifier that makes some red text.

```swift
Text("Some Red Text").foregroundStyle(.red)
```

Multiple modifiers can be chained together. Here's an example using the [foregroundStyle](https://developer.apple.com/documentation/swiftui/text/foregroundstyle(_:)) and [frame](https://developer.apple.com/documentation/swiftui/view/frame(width:height:alignment:)) modifier.

```swift
Text("Some Red Text")
            .foregroundStyle(.red)
            .frame(height: 100, width: 100)
```

In LiveView Native, we define `~SHEET` sigil stylesheets that organize modifers by classes similar to how we use CSS to style elements on the web. These classes use an Elixir-oriented DSL (Domain Specific Language).

Here's the same modifiers above grouped into a `"color-red"` class in a LiveView Native Stylesheet:

<!-- livebook:{"force_markdown":true} -->

```elixir
~SHEET"""
  "color-red" do
    foregroundColor(.red)
    frame(height: 100, width: 100)
  end
"""
```

The DSL drops the `.` dot before each modifier, but otherwise remains mostly the same. For this reason, we don't separately document every modifier, as you can generally translate SwiftUI examples into the DSL syntax.

There can be edge cases for modifier argument values not-compatible with Elixir terms, but that's beyond the scope of this guide. For the most part, you can write your native templates in such as way that this is a non-issue.

For more, you can find documentation and examples of modifiers on [Apple's SwiftUI documentation](https://developer.apple.com/documentation/swiftui) which is comprehensive and thorough, though it may feel unfamiliar at first for Elixir Developers when compared to [HexDocs](https://hexdocs.pm/).

If you use Visual Studio Code, we strongly recommend you install the [LiveView Native Visual Studio Code Extension](https://github.com/liveview-native/liveview-native-vscode) which provides autocompletion and type information thus making modifiers significantly easier to write and lookup.

## Writing Stylesheets

This next section focuses on practical examples of building your own stylesheets as well as some useful patterns and general best-practices.

<!-- livebook:{"break_markdown":true} -->

### Stylesheet Modules

Stylesheet modules define classes within the `~SHEET` sigil. These modules must include `use LiveViewNative.Stylesheet, :swiftui` to access the `~SHEET` sigil.

Here's an example stylesheet using the `~SHEET` sigil. This stylesheet creates a `color-red` class. The `color-red` class applies the [foregroundStyle](https://developer.apple.com/documentation/swiftui/view/foregroundstyle(_:)) SwiftUI modifier. The modifier accepts an argument for color. In this example, we provide the [.red](https://developer.apple.com/documentation/swiftui/color/red) color.

```elixir
defmodule MyStyleSheet do
  use LiveViewNative.Stylesheet, :swiftui

  ~SHEET"""
  "color-red" do
    foregroundStyle(.red)
  end
  """
end
```

### Applying Stylesheet Classes to Views

`use` the stylesheet module within a LiveView module to access classes in the stylesheet.

The example below applies the `color-red` class we previously defined to display red text. Evaluate the cell and you can see it in your IOS simulator.

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5SZWRUZXh0TGl2ZSBkb1xuICB1c2UgUGhvZW5peC5MaXZlVmlld1xuICB1c2UgTGl2ZVZpZXdOYXRpdmUuTGl2ZVZpZXdcbiAgdXNlIE15U3R5bGVTaGVldFxuXG4gIEBpbXBsIHRydWVcbiAgZGVmIHJlbmRlcigle2Zvcm1hdDogOnN3aWZ0dWl9ID0gYXNzaWducykgZG9cbiAgICB+U1dJRlRVSVwiXCJcIlxuICAgIDxUZXh0IGNsYXNzPVwiY29sb3ItcmVkXCI+XG4gICAgICBUaGlzIHRleHQgaXMgcmVkIVxuICAgIDwvVGV4dD5cbiAgICBcIlwiXCJcbiAgZW5kXG5lbmQiLCJwYXRoIjoiLyJ9","chunks":[[0,109],[111,263],[376,45],[423,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule Server.RedTextLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView
  use MyStyleSheet

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <Text class="color-red">
      This text is red!
    </Text>
    """
  end
end
```

### Multiple Modifiers and Classes

Multiple modifiers can be applied within the same class like so.

<!-- livebook:{"force_markdown":true} -->

```elixir
~SHEET"""
"color-red" do
  foregroundStyle(.red)
  frame(height: 200, width: 200)
end
"""
```

<!-- livebook:{"break_markdown":true} -->

### Multiple Classes

You can define multiple classes within the same stylesheet. The same modifier can apply to the same view multiple times with different values. For example, the `frame` modifier can change both the height and the width of a view.

<!-- livebook:{"force_markdown":true} -->

```elixir
~SHEET"""
"tall" do
  frame(height: 200)
end

"wide" do
  frame(width: 200)
end
"""
```

The above classes could be applied to a view like so:

```html
<Text class="tall wide">Tall and Wide Text</Text>
```

<!-- livebook:{"break_markdown":true} -->

### Reusable Classes

It would be cumbersome to define a new class everytime we wanted to change the text color of an element, so we can instead dynamically inject variables within the class name.

Currently, when compiling dynamic classes it's necessary to tell the rules parser how to compile the value.

LiveView Native provides the following functions for that purpose:

* `to_boolean`
* `to_integer`
* `to_float`
* `to_ime`

Most of these functions should be self-explanatory other than the `to_ime` function. The `to_ime` function treats the injected value as a dot-accessed value. For example `red` would be treated as `.red` in the stylesheet.

Here's an example showing a a pattern for how we can create a `color-*` class to dynamically inject named colors.

```elixir
defmodule ReusableColorStyleSheet do
  use LiveViewNative.Stylesheet, :swiftui

  ~SHEET"""
  "color-" <> color_name do
    foregroundStyle(to_ime(color_name))
  end
  """
end
```

Here's how we can use that dynamic class in a LiveView to display some red text. Try changing `color-red` to `color-blue` or any other of SwiftUI's [fixed standard colors](https://developer.apple.com/documentation/uikit/uicolor/standard_colors#3174519).

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5EeW5hbWljQ29sb3JzTGl2ZSBkb1xuICB1c2UgUGhvZW5peC5MaXZlVmlld1xuICB1c2UgTGl2ZVZpZXdOYXRpdmUuTGl2ZVZpZXdcbiAgdXNlIFJldXNhYmxlQ29sb3JTdHlsZVNoZWV0XG5cbiAgQGltcGwgdHJ1ZVxuICBkZWYgcmVuZGVyKCV7Zm9ybWF0OiA6c3dpZnR1aX0gPSBhc3NpZ25zKSBkb1xuICAgIH5TV0lGVFVJXCJcIlwiXG4gICAgPFRleHQgY2xhc3M9XCJjb2xvci1yZWRcIj5DaGFuZ2UgdGhlIGNvbG9yIG9mIHRoaXMgdGV4dCE8L1RleHQ+XG4gICAgXCJcIlwiXG4gIGVuZFxuZW5kIiwicGF0aCI6Ii8ifQ","chunks":[[0,109],[111,281],[394,45],[441,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule Server.DynamicColorsLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView
  use ReusableColorStyleSheet

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <Text class="color-red">Change the color of this text!</Text>
    """
  end
end
```

### Unbroken Class Names

While we support reusable classes, similar to [Tailwind](https://tailwindcss.com/docs/content-configuration#dynamic-class-names), classes must be complete, unbroken strings in your source files.

For example, you **cannot** concatenate two strings together to form a class name in the LiveView as seen in the **broken** example below.

<!-- livebook:{"force_markdown":true} -->

```elixir
<Text class={"color-#{Enum.random(["red", "blue"])}"}>randomly colored text</Text>
```

<!-- livebook:{"break_markdown":true} -->

### Your Turn: Dynamic Height and Width Classes

You're going to create dynamic height `h-*` and width `w-*` classes. You'll need to wrap the dynamic value with `to_integer` so that the rules parser knows to treat the value as an integer. You can use the `frame` modifier to change the height and width of a view.

### Example Solution

```elixir
defmodule DynamicHeightAndWidthSheet do
  use LiveViewNative.Stylesheet, :swiftui

  ~SHEET"""
  "h-" <> height do
    frame(height: to_integer(height))
  end

  "w-" <> width do
    frame(width: to_integer(width))
  end
  """
end
```



Enter your solution below. We've provided some of the boilerplate for you, but none of the modifiers.

```elixir
defmodule DynamicHeightAndWidthSheet do
  use LiveViewNative.Stylesheet, :swiftui

  ~SHEET"""
  "h" <> height do
    
  end

  "w" <> width do
    
  end
  """
end
```

### Test Your Solution

You can use the LiveView below to test your stylesheet solution above.

The LiveView uses your stylesheet above to display four equally spaced Text views. If your solution works correctly, each view should be `100` pixels apart as seen in the image below.

<div style="height: 800; width: 100%; display: flex; height: 800px; justify-content: center; align-items: center;">
<img style="width: 100%; height: 100%; object-fit: contain" src="https://github.com/liveview-native/documentation_assets/blob/main/dynamic-height-and-width-example-screenshot.png?raw=true"/>
</div>

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiIyBEbyBub3QgY2hhbmdlIHRoaXMgTGl2ZVZpZXdcbmRlZm1vZHVsZSBTZXJ2ZXIuRHluYW1pY0hlaWdodEFuZFdpZHRoTGl2ZSBkb1xuICB1c2UgUGhvZW5peC5MaXZlVmlld1xuICB1c2UgTGl2ZVZpZXdOYXRpdmUuTGl2ZVZpZXdcbiAgdXNlIER5bmFtaWNIZWlnaHRBbmRXaWR0aFNoZWV0XG5cbiAgQGltcGwgdHJ1ZVxuICBkZWYgcmVuZGVyKCV7Zm9ybWF0OiA6c3dpZnR1aX0gPSBhc3NpZ25zKSBkb1xuICAgIH5TV0lGVFVJXCJcIlwiXG4gICAgPEhTdGFjayBjbGFzcz1cImgtMTAwXCI+XG4gICAgICA8VGV4dCBjbGFzcz1cInctMTAwXCI+QTwvVGV4dD5cbiAgICAgIDxUZXh0IGNsYXNzPVwidy0xMDBcIj5CPC9UZXh0PlxuICAgIDwvSFN0YWNrPlxuICAgIDxIU3RhY2sgY2xhc3M9XCJoLTEwMFwiPlxuICAgICAgPFRleHQgY2xhc3M9XCJ3LTEwMFwiPkM8L1RleHQ+XG4gICAgICA8VGV4dCBjbGFzcz1cInctMTAwXCI+RDwvVGV4dD5cbiAgICA8L0hTdGFjaz5cbiAgICBcIlwiXCJcbiAgZW5kXG5lbmQiLCJwYXRoIjoiLyJ9","chunks":[[0,109],[111,478],[591,45],[638,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
# Do not change this LiveView
defmodule Server.DynamicHeightAndWidthLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView
  use DynamicHeightAndWidthSheet

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <HStack class="h-100">
      <Text class="w-100">A</Text>
      <Text class="w-100">B</Text>
    </HStack>
    <HStack class="h-100">
      <Text class="w-100">C</Text>
      <Text class="w-100">D</Text>
    </HStack>
    """
  end
end
```
