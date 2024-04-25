# Stylesheets

[![Run in Livebook](https://livebook.dev/badge/v1/blue.svg)](https://livebook.dev/run?url=https%3A%2F%2Fraw.githubusercontent.com%2Fliveview-native%2Flive_view_native%2Fmain%2Fguides%livebooks%stylesheets.livemd)

## Overview

In this guide, you'll learn how to use stylesheets to customize the appearance of your LiveView Native Views. You'll also learn about the inner workings of how LiveView Native uses stylesheets to implement modifiers, and how those modifiers style and customize SwiftUI Views. By the end of this lesson, you'll have the fundamentals you need to create beautiful native UIs.

## The Stylesheet AST

LiveView Native parses through your application at compile time to create a stylesheet AST representation of all the styles in your application. This stylesheet AST is used by the LiveView Native Client application when rendering the view hierarchy to apply modifiers to a given view.

```mermaid
sequenceDiagram
    LiveView->>LiveView: Create stylesheet
    Client->>LiveView: Send request to "http://localhost:4000/?_format=swiftui"
    LiveView->>Client: Send LiveView Native template in response
    Client->>LiveView: Send request to "http://localhost:4000/assets/app.swiftui.styles"
    LiveView->>Client: Send stylesheet in response
    Client->>Client: Parses stylesheet into SwiftUI modifiers
    Client->>Client: Apply modifiers to the view hierarchy
```

We've setup this Livebook to be included when parsing the application for modifiers. You can visit http://localhost:4000/assets/app.swiftui.styles to see the Stylesheet AST created by all of the styles in this Livebook and any other styles used in the `kino_live_view_native` project.

LiveView Native watches for changes and updates the stylesheet, so those will be dynamically picked up and applied, You may notice a slight delay as the Livebook takes **5 seconds** to write it's contents to a file.

## Modifiers

SwiftUI employs **modifiers** to style and customize views. In SwiftUI syntax, each modifier is a function that can be chained onto the view they modify. LiveView Native has a minimal DSL (Domain Specific Language) for writing SwiftUI modifiers.

Modifers can be applied through a LiveView Native Stylesheet and applying them through classes as described in the [LiveView Native Stylesheets](#liveview-native-stylesheets) section, or can be applied directly through the `class` attribute as described in the [Utility Styles](#utility-styles) section.

<!-- livebook:{"break_markdown":true} -->

### SwiftUI Modifiers

Here's a basic example of making text red using the [foregroundStyle](https://developer.apple.com/documentation/swiftui/text/foregroundstyle(_:)) modifier:

```swift
Text("Some Red Text")
  .foregroundStyle(.red)
```

Many modifiers can be applied to a view. Here's an example using [foregroundStyle](https://developer.apple.com/documentation/swiftui/text/foregroundstyle(_:)) and [frame](https://developer.apple.com/documentation/swiftui/view/frame(width:height:alignment:)).

```swift
Text("Some Red Text")
  .foregroundStyle(.red)
  .font(.title)
```

<!-- livebook:{"break_markdown":true} -->

### Implicit Member Expression

Implicit Member Expression in SwiftUI means that we can implicityly access a member of a given type without explicitly specifying the type itself. For example, the `.red` value above is from the [Color](https://developer.apple.com/documentation/swiftui/color) structure.

```swift
Text("Some Red Text")
  .foregroundStyle(Color.red)
```

<!-- livebook:{"break_markdown":true} -->

### LiveView Native Modifiers

The DSL (Domain Specific Language) used in LiveView Native drops the `.` dot before each modifier, but otherwise remains largely the same. We do not document every modifier separately, since you can translate SwiftUI examples into the DSL syntax.

For example, Here's the same `foregroundStyle` modifier as it would be written in a LiveView Native stylesheet or class attribute, which we'll cover in a moment.

```swift
foregroundStyle(.red)
```

There are some exceptions where the DSL differs from SwiftUI syntax, which we'll cover in the sections below.

## Utility Styles

In addition to introducing stylesheets, LiveView Native `0.3.0` also introduced Utility classes, which will be our prefered method for writing styles in these Livebook guides.

The same SwiftUI syntax used inside of a stylesheet can be used directly inside of a `class` attribute. The example below defines the `foregroundStyle(.red)` modifier. Evaluate the example and view it in your simulator.

<!-- livebook:{"attrs":"eyJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlcldlYi5FeGFtcGxlTGl2ZS5Td2lmdFVJIGRvXG4gIHVzZSBTZXJ2ZXJOYXRpdmUsIFs6cmVuZGVyX2NvbXBvbmVudCwgZm9ybWF0OiA6c3dpZnR1aV1cblxuICBkZWYgcmVuZGVyKGFzc2lnbnMpIGRvXG4gICAgfkxWTlwiXCJcIlxuICAgIDxUZXh0IGNsYXNzPVwiZm9yZWdyb3VuZFN0eWxlKC5yZWQpXCI+SGVsbG8sIGZyb20gTGl2ZVZpZXcgTmF0aXZlITwvVGV4dD5cbiAgICBcIlwiXCJcbiAgZW5kXG5lbmRcblxuZGVmbW9kdWxlIFNlcnZlcldlYi5FeGFtcGxlTGl2ZSBkb1xuICB1c2UgU2VydmVyV2ViLCA6bGl2ZV92aWV3XG4gIHVzZSBTZXJ2ZXJOYXRpdmUsIDpsaXZlX3ZpZXdcblxuICBAaW1wbCB0cnVlXG4gIGRlZiByZW5kZXIoYXNzaWducyksIGRvOiB+SFwiXCJcbmVuZCIsInBhdGgiOiIvIn0","chunks":[[0,85],[87,377],[466,49],[517,51]],"kind":"Elixir.Server.SmartCells.LiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule ServerWeb.ExampleLive.SwiftUI do
  use ServerNative, [:render_component, format: :swiftui]

  def render(assigns) do
    ~LVN"""
    <Text class="foregroundStyle(.red)">Hello, from LiveView Native!</Text>
    """
  end
end

defmodule ServerWeb.ExampleLive do
  use ServerWeb, :live_view
  use ServerNative, :live_view

  @impl true
  def render(assigns), do: ~H""
end
```

### Multiple Modifiers

You can write multiple modifiers, separate each by a space or newline character.

```html
<Text class="foregroundStyle(.blue) font(.title)">Hello, from LiveView Native!</Text>
```

For newline characters, you'll need to wrap the string in curly brackets `{}`. Using multiple lines can better organize larger amounts of modifiers.

```html
<Text class={
  "
  foregroundStyle(.blue)
  font(.title)
  "
}>
Hello, from LiveView Native!
</Text>
```

## Dynamic Class Names

LiveView Native parses styles in your project to define a single stylesheet. You can find the AST representation of this stylesheet at http://localhost:4000/assets/app.swiftui.styles. This stylesheet is compiled on the server and then sent to the client. For this reason, class names must be fully-formed. For example, the following class using string interpolation is **invalid**.

```html
<Text class={"foregroundStyle(.#{Enum.random(["red", "blue"])})"}>
Invalid Example
</Text>
```

However, we can still use dynamic styles so long as the class names are fully formed.

```html
<Text class={"#{Enum.random(["foregroundStyle(.red)", "foregroundStyle(.blue)]")}"}>
Red or Blue Text
</Text>
```

Evaluate the example below multiple times while watching your simulator. Notice that the text is dynamically red or blue.

<!-- livebook:{"attrs":"eyJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlcldlYi5FeGFtcGxlTGl2ZS5Td2lmdFVJIGRvXG4gIHVzZSBTZXJ2ZXJOYXRpdmUsIFs6cmVuZGVyX2NvbXBvbmVudCwgZm9ybWF0OiA6c3dpZnR1aV1cblxuICBkZWYgcmVuZGVyKGFzc2lnbnMpIGRvXG4gICAgfkxWTlwiXCJcIlxuICAgIDxUZXh0IGNsYXNzPXtcIiN7RW51bS5yYW5kb20oW1wiZm9yZWdyb3VuZFN0eWxlKC5yZWQpXCIsIFwiZm9yZWdyb3VuZFN0eWxlKC5ibHVlKVwiXSl9XCJ9PlxuICAgIEhlbGxvLCBmcm9tIExpdmVWaWV3IE5hdGl2ZSFcbiAgICA8L1RleHQ+XG4gICAgXCJcIlwiXG4gIGVuZFxuZW5kXG5cbmRlZm1vZHVsZSBTZXJ2ZXJXZWIuRXhhbXBsZUxpdmUgZG9cbiAgdXNlIFNlcnZlcldlYiwgOmxpdmVfdmlld1xuICB1c2UgU2VydmVyTmF0aXZlLCA6bGl2ZV92aWV3XG5cbiAgQGltcGwgdHJ1ZVxuICBkZWYgcmVuZGVyKGFzc2lnbnMpLCBkbzogfkhcIlwiXG5lbmQiLCJwYXRoIjoiLyJ9","chunks":[[0,85],[87,435],[524,49],[575,51]],"kind":"Elixir.Server.SmartCells.LiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule ServerWeb.ExampleLive.SwiftUI do
  use ServerNative, [:render_component, format: :swiftui]

  def render(assigns) do
    ~LVN"""
    <Text class={"#{Enum.random(["foregroundStyle(.red)", "foregroundStyle(.blue)"])}"}>
    Hello, from LiveView Native!
    </Text>
    """
  end
end

defmodule ServerWeb.ExampleLive do
  use ServerWeb, :live_view
  use ServerNative, :live_view

  @impl true
  def render(assigns), do: ~H""
end
```

## Modifier Order

Modifier order matters. Changing the order that modifers are applied can have a significant impact on their behavior.

To demonstrate this concept, we're going to take a simple example of applying padding and background color.

If we apply the background color first, then the padding, The background is applied to original view, leaving the padding filled with whitespace.

<!-- livebook:{"force_markdown":true} -->

```elixir
background(.orange)
padding(20)
```

```mermaid
flowchart

subgraph Padding
 View
end

style View fill:orange
```

If we apply the padding first, then the background, the background is applied to the view with the padding, thus filling the entire area with background color.

<!-- livebook:{"force_markdown":true} -->

```elixir
padding(20)
background(.orange)
```

```mermaid
flowchart

subgraph Padding
 View
end

style Padding fill:orange
style View fill:orange
```

Evaluate the example below to see this in action.

<!-- livebook:{"attrs":"eyJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlcldlYi5FeGFtcGxlTGl2ZS5Td2lmdFVJIGRvXG4gIHVzZSBTZXJ2ZXJOYXRpdmUsIFs6cmVuZGVyX2NvbXBvbmVudCwgZm9ybWF0OiA6c3dpZnR1aV1cblxuICBkZWYgcmVuZGVyKGFzc2lnbnMpIGRvXG4gICAgfkxWTlwiXCJcIlxuICAgIDxUZXh0IGNsYXNzPVwiYmFja2dyb3VuZCgub3JhbmdlKSBwYWRkaW5nKClcIj5IZWxsbywgZnJvbSBMaXZlVmlldyBOYXRpdmUhPC9UZXh0PlxuICAgIDxUZXh0IGNsYXNzPVwicGFkZGluZygpIGJhY2tncm91bmQoLm9yYW5nZSlcIj5IZWxsbywgZnJvbSBMaXZlVmlldyBOYXRpdmUhPC9UZXh0PlxuICAgIFwiXCJcIlxuICBlbmRcbmVuZFxuXG5kZWZtb2R1bGUgU2VydmVyV2ViLkV4YW1wbGVMaXZlIGRvXG4gIHVzZSBTZXJ2ZXJXZWIsIDpsaXZlX3ZpZXdcbiAgdXNlIFNlcnZlck5hdGl2ZSwgOmxpdmVfdmlld1xuXG4gIEBpbXBsIHRydWVcbiAgZGVmIHJlbmRlcihhc3NpZ25zKSwgZG86IH5IXCJcIlxuZW5kIiwicGF0aCI6Ii8ifQ","chunks":[[0,85],[87,469],[558,49],[609,51]],"kind":"Elixir.Server.SmartCells.LiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule ServerWeb.ExampleLive.SwiftUI do
  use ServerNative, [:render_component, format: :swiftui]

  def render(assigns) do
    ~LVN"""
    <Text class="background(.orange) padding()">Hello, from LiveView Native!</Text>
    <Text class="padding() background(.orange)">Hello, from LiveView Native!</Text>
    """
  end
end

defmodule ServerWeb.ExampleLive do
  use ServerWeb, :live_view
  use ServerNative, :live_view

  @impl true
  def render(assigns), do: ~H""
end
```

## Injecting Views in Stylesheets

SwiftUI modifiers sometimes accept SwiftUI views as arguments. Here's an example using the `clipShape` modifier with a `Circle` view.

```swift
Image("logo")
  .clipShape(Circle())
```

However, LiveView Native does not support using SwiftUI views directly within a stylesheet. Instead, we have a few alternative options in cases like this where we want to use a view within a modifier.

<!-- livebook:{"break_markdown":true} -->

### Using Members on a Given Type

We can't use the [Circle](https://developer.apple.com/documentation/swiftui/circle) view directly. However, if you look at the [clipShape](https://developer.apple.com/documentation/swiftui/view/clipshape(_:style:)) documentation you'll notice it accepts the [Shape](https://developer.apple.com/documentation/swiftui/shape) type. This type defines the [circle](https://developer.apple.com/documentation/swiftui/shape/circle) property which we can use since it's equivalent to the [Circle](https://developer.apple.com/documentation/swiftui/circle) view for our purposes.

We can use `Shape.circle` instead of the `Circle` view. So, the following code is equivalent to the example above.

```swift
Image("logo")
  .clipShape(Shape.circle)
```

Using implicit member expression, we can simplify this code to the following:

```swift
Image("logo")
  .clipShape(.circle)
```

Which is simple to convert to the LiveView Native DSL using the rules we've already learned.

<!-- livebook:{"force_markdown":true} -->

```elixir
"example-class" do
  clipShape(.circle)
end
```

<!-- livebook:{"break_markdown":true} -->

### Injecting a View

For more complex cases, we can inject a view directly into a stylesheet.

Here's an example where this might be useful. SwiftUI has modifers that represent a named content area for views to be placed within. These views can even have their own modifiers, so it's not enough to use a simple static property on the [Shape](https://developer.apple.com/documentation/swiftui/shape) type.

```swift
Image("logo")
  .overlay(content: {
    Circle().stroke(.red, lineWidth: 4)
  })
```

To get around this issue, we instead inject a view into the stylesheet. First, define the modifier and use an atom to represent the view that's going to be injected.

<!-- livebook:{"force_markdown":true} -->

```elixir
"overlay-circle" do
  overlay(content: :circle)
end
```

Then use the `template` attribute on the view to be injected into the stylesheet. This view should be a child of the view with the given class.

```html
<Image class="overlay-circle">
  <Circle template="circle" >
</Image>
```

We can then apply modifiers to the child view through a class as we've already seen.

## Custom Colors

### SwiftUI Color Struct

The SwiftUI [Color](https://developer.apple.com/documentation/swiftui/color) structure accepts either the name of a color in the asset catalog or the RGB values of the color.

Therefore we can define custom RBG styles like so:

```swift
foregroundStyle(Color(.sRGB, red: 0.4627, green: 0.8392, blue: 1.0))
```

Evaluate the example below to see the custom color in your simulator.

<!-- livebook:{"attrs":"eyJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlcldlYi5FeGFtcGxlTGl2ZS5Td2lmdFVJIGRvXG4gIHVzZSBTZXJ2ZXJOYXRpdmUsIFs6cmVuZGVyX2NvbXBvbmVudCwgZm9ybWF0OiA6c3dpZnR1aV1cblxuICBkZWYgcmVuZGVyKGFzc2lnbnMpIGRvXG4gICAgfkxWTlwiXCJcIlxuICAgIDxUZXh0IGNsYXNzPVwiZm9yZWdyb3VuZFN0eWxlKENvbG9yKC5zUkdCLCByZWQ6IDAuNDYyNywgZ3JlZW46IDAuODM5MiwgYmx1ZTogMS4wKSlcIj5cbiAgICAgIEhlbGxvLCBmcm9tIExpdmVWaWV3IE5hdGl2ZSFcbiAgICA8L1RleHQ+XG4gICAgXCJcIlwiXG4gIGVuZFxuZW5kXG5cbmRlZm1vZHVsZSBTZXJ2ZXJXZWIuRXhhbXBsZUxpdmUgZG9cbiAgdXNlIFNlcnZlcldlYiwgOmxpdmVfdmlld1xuICB1c2UgU2VydmVyTmF0aXZlLCA6bGl2ZV92aWV3XG5cbiAgQGltcGwgdHJ1ZVxuICBkZWYgcmVuZGVyKGFzc2lnbnMpLCBkbzogfkhcIlwiXG5lbmQiLCJwYXRoIjoiLyJ9","chunks":[[0,85],[87,436],[525,49],[576,51]],"kind":"Elixir.Server.SmartCells.LiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule ServerWeb.ExampleLive.SwiftUI do
  use ServerNative, [:render_component, format: :swiftui]

  def render(assigns) do
    ~LVN"""
    <Text class="foregroundStyle(Color(.sRGB, red: 0.4627, green: 0.8392, blue: 1.0))">
      Hello, from LiveView Native!
    </Text>
    """
  end
end

defmodule ServerWeb.ExampleLive do
  use ServerWeb, :live_view
  use ServerNative, :live_view

  @impl true
  def render(assigns), do: ~H""
end
```

### Custom Colors in the Asset Catalogue

Custom colors can be defined in the [Asset Catalogue](https://developer.apple.com/documentation/xcode/managing-assets-with-asset-catalogs). Once defined in the asset catalogue of the Xcode application, the color can be referenced by name like so:

```swift
foregroundStyle(Color("MyColor"))
```

Generally using the asset catalog is more performant and customizable than using custom RGB colors with the [Color](https://developer.apple.com/documentation/swiftui/color) struct.

<!-- livebook:{"break_markdown":true} -->

### Your Turn: Custom Colors in the Asset Catalog

Custom colors can be defined in the asset catalog (https://developer.apple.com/documentation/xcode/managing-assets-with-asset-catalogs). Generat

To create a new color go to the `Assets` folder in your iOS app and create a new color set.

<!-- livebook:{"break_markdown":true} -->

![](https://github.com/liveview-native/documentation_assets/blob/main/asset-catalogue-create-new-color-set.png?raw=true)

<!-- livebook:{"break_markdown":true} -->

To create a color set, enter the RGB values or a hexcode as shown in the image below. If you don't see the sidebar with color options, click the icon in the top-right of your Xcode app and click the **Show attributes inspector** icon shown highlighted in blue.

<!-- livebook:{"break_markdown":true} -->

![](https://github.com/liveview-native/documentation_assets/blob/main/asset-catalogue-modify-my-color.png?raw=true)

<!-- livebook:{"break_markdown":true} -->

The defined color is now available for use within LiveView Native styles. However, the app needs to be re-compiled to pick up a new color set.

Re-build your SwiftUI Application before moving on. Then evaluate the code below. You should see your custom colored text in the simulator.

<!-- livebook:{"attrs":"eyJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlcldlYi5FeGFtcGxlTGl2ZS5Td2lmdFVJIGRvXG4gIHVzZSBTZXJ2ZXJOYXRpdmUsIFs6cmVuZGVyX2NvbXBvbmVudCwgZm9ybWF0OiA6c3dpZnR1aV1cblxuICBkZWYgcmVuZGVyKGFzc2lnbnMpIGRvXG4gICAgfkxWTlwiXCJcIlxuICAgIDxUZXh0IGNsYXNzPXtcImZvcmVncm91bmRTdHlsZShDb2xvcihcXFwiTXlDb2xvclxcXCIpKVwifT5IZWxsbywgZnJvbSBMaXZlVmlldyBOYXRpdmUhPC9UZXh0PlxuICAgIFwiXCJcIlxuICBlbmRcbmVuZFxuXG5kZWZtb2R1bGUgU2VydmVyV2ViLkV4YW1wbGVMaXZlIGRvXG4gIHVzZSBTZXJ2ZXJXZWIsIDpsaXZlX3ZpZXdcbiAgdXNlIFNlcnZlck5hdGl2ZSwgOmxpdmVfdmlld1xuXG4gIEBpbXBsIHRydWVcbiAgZGVmIHJlbmRlcihhc3NpZ25zKSwgZG86IH5IXCJcIlxuZW5kIiwicGF0aCI6Ii8ifQ","chunks":[[0,85],[87,393],[482,49],[533,51]],"kind":"Elixir.Server.SmartCells.LiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule ServerWeb.ExampleLive.SwiftUI do
  use ServerNative, [:render_component, format: :swiftui]

  def render(assigns) do
    ~LVN"""
    <Text class={"foregroundStyle(Color(\"MyColor\"))"}>Hello, from LiveView Native!</Text>
    """
  end
end

defmodule ServerWeb.ExampleLive do
  use ServerWeb, :live_view
  use ServerNative, :live_view

  @impl true
  def render(assigns), do: ~H""
end
```

## LiveView Native Stylesheets

In LiveView Native, we use `~SHEET` sigil stylesheets to organize modifers by classes using an Elixir-oriented DSL similar to CSS for styling web elements.

We group modifiers together within a class that can be applied to an element. Here's an example of how modifiers can be grouped into a "red-title" class in a stylesheet:

<!-- livebook:{"force_markdown":true} -->

```elixir
~SHEET"""
  "red-title" do
    foregroundColor(.red)
    font(.title)
  end
"""
```

We're mostly using Utility styles for these guides, but the stylesheet module does contain some important configuration to `@import` the utility styles module. It can also be used to group styles within a class if you have a set of modifiers you're repeatedly using and want to group together.

<!-- livebook:{"force_markdown":true} -->

```elixir
defmodule ServerWeb.Styles.App.SwiftUI do
  use LiveViewNative.Stylesheet, :swiftui
  @import LiveViewNative.SwiftUI.UtilityStyles

  ~SHEET"""
    "red-title" do
      foregroundColor(.red)
      font(.title)
    end
  """
end
```

Since the Phoenix server runs in a dependency for these guides, you don't have direct access to the stylesheet module.

## Apple Documentation

You can find documentation and examples of modifiers on [Apple's SwiftUI documentation](https://developer.apple.com/documentation/swiftui) which is comprehensive and thorough, though it may feel unfamiliar at first for Elixir Developers when compared to HexDocs.

<!-- livebook:{"break_markdown":true} -->

### Finding Modifiers

The [Configuring View Elements](https://developer.apple.com/documentation/swiftui/view#configuring-view-elements) section of apple documentation contains links to modifiers organized by category. In that documentation you'll find useful references such as [Style Modifiers](https://developer.apple.com/documentation/swiftui/view-style-modifiers), [Layout Modifiers](https://developer.apple.com/documentation/swiftui/view-layout), and [Input and Event Modifiers](https://developer.apple.com/documentation/swiftui/view-input-and-events).

You can also find the same modifiers with LiveView Native examples on the [LiveView Client SwiftUI Docs](https://liveview-native.github.io/liveview-client-swiftui/documentation/liveviewnative/paddingmodifier).

## Visual Studio Code Extension

If you use Visual Studio Code, we strongly recommend you install the [LiveView Native Visual Studio Code Extension](https://github.com/liveview-native/liveview-native-vscode) which provides autocompletion and type information thus making modifiers significantly easier to write and lookup.

## Your Turn: Syntax Conversion

Part of learning LiveView Native is learning SwiftUI. Fortunately we can leverage the existing SwiftUI ecosystem and convert examples into LiveView Native syntax.

You're going to convert the following SwiftUI code into a LiveView Native template. This example is inspired by the official [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui/creating-and-combining-views).

<!-- livebook:{"force_markdown":true} -->

```elixir
 VStack {
    VStack(alignment: .leading) {
        Text("Turtle Rock")
            .font(.title)
        HStack {
            Text("Joshua Tree National Park")
            Spacer()
            Text("California")
        }
        .font(.subheadline)

        Divider()

        Text("About Turtle Rock")
            .font(.title2)
        Text("Descriptive text goes here")
    }
    .padding()

    Spacer()
}
```

### Example Solution

```elixir
defmodule ServerWeb.ExampleLive.SwiftUI do
  use ServerNative, [:render_component, format: :swiftui]

  def render(assigns) do
    ~LVN"""
    <VStack alignment="leading" class="padding()">
      <Text class="font(.title)">Turtle Rock</Text>
      <HStack class="font(.subheadline)">
        <Text>Joshua Tree National Park</Text>
        <Spacer/>
        <Text>California</Text>
      </HStack>
      <Divider/>
      <Text class="font(.title2)">About Turtle Rock</Text>
      <Text>Descriptive text goes here</Text>
    </VStack>
    """
  end
end
```



Enter your solution below.

<!-- livebook:{"attrs":"eyJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlcldlYi5FeGFtcGxlTGl2ZS5Td2lmdFVJIGRvXG4gIHVzZSBTZXJ2ZXJOYXRpdmUsIFs6cmVuZGVyX2NvbXBvbmVudCwgZm9ybWF0OiA6c3dpZnR1aV1cblxuICBkZWYgcmVuZGVyKGFzc2lnbnMpIGRvXG4gICAgfkxWTlwiXCJcIlxuICAgIDwhLS0gVGVtcGxhdGUgQ29kZSBHb2VzIEhlcmUgLS0+XG4gICAgXCJcIlwiXG4gIGVuZFxuZW5kIn0","chunks":[[0,85],[87,193],[282,47],[331,51]],"kind":"Elixir.Server.SmartCells.RenderComponent","livebook_object":"smart_cell"} -->

```elixir
defmodule ServerWeb.ExampleLive.SwiftUI do
  use ServerNative, [:render_component, format: :swiftui]

  def render(assigns) do
    ~LVN"""
    <!-- Template Code Goes Here -->
    """
  end
end
```
