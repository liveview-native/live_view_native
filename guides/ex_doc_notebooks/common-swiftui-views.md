# Common SwiftUI Views

[![Run in Livebook](https://livebook.dev/badge/v1/blue.svg)](https://livebook.dev/run?url=https%3A%2F%2Fraw.githubusercontent.com%2Fliveview-native%2Flive_view_native%2Fmain%2Fguides%2Fnotebooks%common-swiftui-views.livemd)

## Overview

LiveViewNative aims to use minimal SwiftUI code. All patterns for building interactive UIs are the same as LiveView. However, unlike LiveView for the web, LiveView Native uses SwiftUI templates to build the native UI.

This lesson will teach you how to build SwiftUI templates using common SwiftUI views. We'll cover common uses of each view and give you practical examples you can use to build your own native UIs. This lesson is like a recipe book you can refer back to whenever you need an example of how to use a particular SwiftUI view.

## Platform Specific Render

LiveView Native utilizes a single LiveView for both the web and native views, but the templates are platform-specific. The native render function returns a `~SwiftUI` template, and the web render function returns a `~H` (HEEx) template.

Here's an example of both render functions in a LiveView Native LiveView.

<!-- livebook:{"force_markdown":true} -->

```elixir
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
```

In future examples, we're going to focus on the SwiftUI render function in all of our examples and ignore the web function.

## SwiftUI Views

In SwiftUI, a "View" is like a building block for what you see on your app's screen. It can be something simple like text or an image, or something more complex like a layout with multiple elements. Views are the pieces that make up your app's user interface.

Here's an example `Text` view that represents a text element.

```swift
Text("Hamlet")
```

LiveView Native uses the following syntax to represent the view above.

<!-- livebook:{"force_markdown":true} -->

```elixir
<Text>Hamlet</Text>
```

LiveView Native parses the `~SwiftUI` template into an AST representation, which is sent to the SwiftUI application for conversion back into SwiftUI syntax.

```mermaid
sequenceDiagram
    SwiftUI->>LiveView: Send request to "http://localhost:4000?_lvn[format]=swiftui"
    LiveView->>LiveView: Convert native template into AST
    LiveView->>SwiftUI: Send AST in response
    SwiftUI->>SwiftUI: Convert AST into SwiftUI syntax.
```

SwiftUI provides a wide range of Views that can be used in native templates. You can find a full reference of these views in the SwiftUI Documentation at https://developer.apple.com/documentation/swiftui/. In this guide, we will cover some of the most commonly used views to help you get started.

## Text

We've already seen the [Text](https://developer.apple.com/documentation/swiftui/text) view, but we'll start simple to get the interactive tutorial running.

Evaluate the cell below, then in Xcode, Start the iOS application you created in the [Create a SwiftUI Application](https://hexdocs.pm/live_view_native/create-a-swiftui-application.html) lesson and ensure you see the `"Hello, World!"` text.

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5UZXh0TGl2ZSBkb1xuICB1c2UgUGhvZW5peC5MaXZlVmlld1xuICB1c2UgTGl2ZVZpZXdOYXRpdmUuTGl2ZVZpZXdcblxuICBAaW1wbCB0cnVlXG4gIGRlZiByZW5kZXIoJXtmb3JtYXQ6IDpzd2lmdHVpfSA9IGFzc2lnbnMpIGRvXG4gICAgflNXSUZUVUlcIlwiXCJcbiAgICA8VGV4dD5IZWxsbyBmcm9tIExpdmVWaWV3IE5hdGl2ZSE8L1RleHQ+XG4gICAgXCJcIlwiXG4gIGVuZFxuZW5kIiwicGF0aCI6Ii8ifQ","chunks":[[0,109],[111,221],[334,45],[381,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule Server.TextLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <Text>Hello from LiveView Native!</Text>
    """
  end
end
```

## HStack and VStack

SwiftUI includes many [Layout](https://developer.apple.com/documentation/swiftui/layout-fundamentals) container views you can use to arrange your user Interface. Here are a few of the most commonly used:

* [VStack](https://developer.apple.com/documentation/swiftui/vstack): Vertically arranges nested views.
* [HStack](https://developer.apple.com/documentation/swiftui/hstack): Horizontally arranges nested views.

Below, we've created a simple 3X3 game board to demonstrate how to use `VStack` and `HStack` to build a layout of horizontal rows in a single vertical column.o

Here's a diagram to demonstrate how these rows and columns create our desired layout.

```mermaid
flowchart
subgraph VStack
  direction TB
  subgraph H1[HStack]
    direction LR
    1[O] --> 2[X] --> 3[X]
  end
  subgraph H2[HStack]
    direction LR
    4[X] --> 5[O] --> 6[O]
  end
  subgraph H3[HStack]
    direction LR
    7[X] --> 8[X] --> 9[O]
  end
  H1 --> H2 --> H3
end
```

Evaluate the example below and view the working 3X3 layout in your Xcode simulator.

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5TdGFja0V4YW1wbGVMaXZlIGRvXG4gIHVzZSBQaG9lbml4LkxpdmVWaWV3XG4gIHVzZSBMaXZlVmlld05hdGl2ZS5MaXZlVmlld1xuXG4gIEBpbXBsIHRydWVcbiAgZGVmIHJlbmRlcigle2Zvcm1hdDogOnN3aWZ0dWl9ID0gYXNzaWducykgZG9cbiAgICB+U1dJRlRVSVwiXCJcIlxuICAgIDxWU3RhY2s+XG4gICAgICA8SFN0YWNrPlxuICAgICAgICA8VGV4dD5PPC9UZXh0PlxuICAgICAgICA8VGV4dD5YPC9UZXh0PlxuICAgICAgICA8VGV4dD5YPC9UZXh0PlxuICAgICAgPC9IU3RhY2s+XG4gICAgICA8SFN0YWNrPlxuICAgICAgICA8VGV4dD5YPC9UZXh0PlxuICAgICAgICA8VGV4dD5PPC9UZXh0PlxuICAgICAgICA8VGV4dD5PPC9UZXh0PlxuICAgICAgPC9IU3RhY2s+XG4gICAgICA8SFN0YWNrPlxuICAgICAgICA8VGV4dD5YPC9UZXh0PlxuICAgICAgICA8VGV4dD5YPC9UZXh0PlxuICAgICAgICA8VGV4dD5PPC9UZXh0PlxuICAgICAgPC9IU3RhY2s+XG4gICAgPC9WU3RhY2s+XG4gICAgXCJcIlwiXG4gIGVuZFxuZW5kIiwicGF0aCI6Ii8ifQ","chunks":[[0,109],[111,511],[624,45],[671,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule Server.StackExampleLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <VStack>
      <HStack>
        <Text>O</Text>
        <Text>X</Text>
        <Text>X</Text>
      </HStack>
      <HStack>
        <Text>X</Text>
        <Text>O</Text>
        <Text>O</Text>
      </HStack>
      <HStack>
        <Text>X</Text>
        <Text>X</Text>
        <Text>O</Text>
      </HStack>
    </VStack>
    """
  end
end
```

### Your Turn: 3x3 board using columns

In the cell below, use `VStack` and `HStack` to create a 3X3 board using 3 columns instead of 3 rows as demonstrated above. The arrangement of `X` and `O` does not matter, however the content will not be properly aligned if you do not have exactly one character in each `Text` element.

```mermaid
flowchart
subgraph HStack
  direction LR
  subgraph V1[VStack]
    direction TB
    1[O] --> 2[X] --> 3[X]
  end
  subgraph V2[VStack]
    direction TB
    4[X] --> 5[O] --> 6[O]
  end
  subgraph V3[VStack]
    direction TB
    7[X] --> 8[X] --> 9[O]
  end
  V1 --> V2 --> V3
end
```

### Example Solution

```elixir
defmodule Server.BoardLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <HStack>
      <VStack>
        <Text>O</Text>
        <Text>X</Text>
        <Text>X</Text>
      </VStack>
      <VStack>
        <Text>X</Text>
        <Text>O</Text>
        <Text>O</Text>
      </VStack>
      <VStack>
        <Text>X</Text>
        <Text>X</Text>
        <Text>O</Text>
      </VStack>
    </HStack>
    """
  end
end
```



<!-- livebook:{"break_markdown":true} -->

### Enter Your Solution Below

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5Cb2FyZExpdmUgZG9cbiAgdXNlIFBob2VuaXguTGl2ZVZpZXdcbiAgdXNlIExpdmVWaWV3TmF0aXZlLkxpdmVWaWV3XG5cbiAgQGltcGwgdHJ1ZVxuICBkZWYgcmVuZGVyKCV7Zm9ybWF0OiA6c3dpZnR1aX0gPSBhc3NpZ25zKSBkb1xuICAgIH5TV0lGVFVJXCJcIlwiXG4gICAgPCEtLSBFbnRlciBzb2x1dGlvbiBiZWxvdyAtLT5cbiAgICBcIlwiXCJcbiAgZW5kXG5lbmQiLCJwYXRoIjoiLyJ9","chunks":[[0,109],[111,211],[324,45],[371,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule Server.BoardLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <!-- Enter solution below -->
    """
  end
end
```

## Grid

`VStack` and `HStack` do not provide vertical-alignment between horizontal rows. Notice in the following example that the rows/columns of the 3X3 board are not aligned, just centered.

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5BbGlnbm1lbnRFeGFtcGxlTGl2ZSBkb1xuICB1c2UgUGhvZW5peC5MaXZlVmlld1xuICB1c2UgTGl2ZVZpZXdOYXRpdmUuTGl2ZVZpZXdcblxuICBAaW1wbCB0cnVlXG4gIGRlZiByZW5kZXIoJXtmb3JtYXQ6IDpzd2lmdHVpfSA9IGFzc2lnbnMpIGRvXG4gICAgflNXSUZUVUlcIlwiXCJcbiAgICA8VlN0YWNrPlxuICAgICAgPEhTdGFjaz5cbiAgICAgICAgPFRleHQ+WDwvVGV4dD5cbiAgICAgICAgPFRleHQ+WDwvVGV4dD5cbiAgICAgIDwvSFN0YWNrPlxuICAgICAgPEhTdGFjaz5cbiAgICAgICAgPFRleHQ+WDwvVGV4dD5cbiAgICAgICAgPFRleHQ+TzwvVGV4dD5cbiAgICAgICAgPFRleHQ+TzwvVGV4dD5cbiAgICAgIDwvSFN0YWNrPlxuICAgICAgPEhTdGFjaz5cbiAgICAgICAgPFRleHQ+WDwvVGV4dD5cbiAgICAgICAgPFRleHQ+TzwvVGV4dD5cbiAgICAgIDwvSFN0YWNrPlxuICAgIDwvVlN0YWNrPlxuICAgIFwiXCJcIlxuICBlbmRcbmVuZCIsInBhdGgiOiIvIn0","chunks":[[0,109],[111,469],[582,45],[629,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule Server.AlignmentExampleLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <VStack>
      <HStack>
        <Text>X</Text>
        <Text>X</Text>
      </HStack>
      <HStack>
        <Text>X</Text>
        <Text>O</Text>
        <Text>O</Text>
      </HStack>
      <HStack>
        <Text>X</Text>
        <Text>O</Text>
      </HStack>
    </VStack>
    """
  end
end
```

Fortunately, we have a few common elements for creating a grid-based layout.

* [Grid](https://developer.apple.com/documentation/swiftui/grid): A grid that arranges its child views in rows and columns that you specify.
* [GridRow](https://developer.apple.com/documentation/swiftui/gridrow): A view that arranges its children in a horizontal line.

A grid layout vertically and horizontally aligns elements in the grid based on the number of elements in each row.

Evaluate the example below and notice that rows and columns are aligned.

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5HcmlkTGl2ZSBkb1xuICB1c2UgUGhvZW5peC5MaXZlVmlld1xuICB1c2UgTGl2ZVZpZXdOYXRpdmUuTGl2ZVZpZXdcblxuICBAaW1wbCB0cnVlXG4gIGRlZiByZW5kZXIoJXtmb3JtYXQ6IDpzd2lmdHVpfSA9IGFzc2lnbnMpIGRvXG4gICAgflNXSUZUVUlcIlwiXCJcbiAgICA8R3JpZD5cbiAgICAgIDxHcmlkUm93PlxuICAgICAgICA8VGV4dD5YWDwvVGV4dD5cbiAgICAgICAgPFRleHQ+WDwvVGV4dD5cbiAgICAgICAgPFRleHQ+WDwvVGV4dD5cbiAgICAgIDwvR3JpZFJvdz5cbiAgICAgIDxHcmlkUm93PlxuICAgICAgICA8VGV4dD5YPC9UZXh0PlxuICAgICAgICA8VGV4dD5YPC9UZXh0PlxuICAgICAgPC9HcmlkUm93PlxuICAgICAgPEdyaWRSb3c+XG4gICAgICAgIDxUZXh0Plg8L1RleHQ+XG4gICAgICAgIDxUZXh0Plg8L1RleHQ+XG4gICAgICAgIDxUZXh0Plg8L1RleHQ+XG4gICAgICA8L0dyaWRSb3c+XG4gICAgPC9HcmlkPlxuICAgIFwiXCJcIlxuICBlbmRcbmVuZCIsInBhdGgiOiIvIn0","chunks":[[0,109],[111,483],[596,45],[643,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule Server.GridLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <Grid>
      <GridRow>
        <Text>XX</Text>
        <Text>X</Text>
        <Text>X</Text>
      </GridRow>
      <GridRow>
        <Text>X</Text>
        <Text>X</Text>
      </GridRow>
      <GridRow>
        <Text>X</Text>
        <Text>X</Text>
        <Text>X</Text>
      </GridRow>
    </Grid>
    """
  end
end
```

## List

The SwiftUI [List](https://developer.apple.com/documentation/swiftui/list) view provides a system-specific interface, and has better performance for large amounts of scrolling elements.

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5MaXN0TGl2ZSBkb1xuICB1c2UgUGhvZW5peC5MaXZlVmlld1xuICB1c2UgTGl2ZVZpZXdOYXRpdmUuTGl2ZVZpZXdcblxuICBAaW1wbCB0cnVlXG4gIGRlZiByZW5kZXIoJXtmb3JtYXQ6IDpzd2lmdHVpfSA9IGFzc2lnbnMpIGRvXG4gICAgflNXSUZUVUlcIlwiXCJcbiAgICA8TGlzdD5cbiAgICAgIDxUZXh0Pkl0ZW0gMTwvVGV4dD5cbiAgICAgIDxUZXh0Pkl0ZW0gMjwvVGV4dD5cbiAgICAgIDxUZXh0Pkl0ZW0gMzwvVGV4dD5cbiAgICA8L0xpc3Q+XG4gICAgXCJcIlwiXG4gIGVuZFxuZW5kIiwicGF0aCI6Ii8ifQ","chunks":[[0,109],[111,277],[390,45],[437,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule Server.ListLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <List>
      <Text>Item 1</Text>
      <Text>Item 2</Text>
      <Text>Item 3</Text>
    </List>
    """
  end
end
```

### Multi-dimensional lists

Alternatively we can separate children within a `List` view in a `Section` view as seen in the example below. Views in the `Section` can have the `template` attribute with a `"header"` or `"footer"` value which controls how the content is displayed above or below the section.

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5MaXN0U2VjdGlvbnNMaXZlIGRvXG4gIHVzZSBQaG9lbml4LkxpdmVWaWV3XG4gIHVzZSBMaXZlVmlld05hdGl2ZS5MaXZlVmlld1xuXG4gIEBpbXBsIHRydWVcbiAgZGVmIHJlbmRlcigle2Zvcm1hdDogOnN3aWZ0dWl9ID0gYXNzaWducykgZG9cbiAgICB+U1dJRlRVSVwiXCJcIlxuICAgIDxMaXN0PlxuICAgICAgPFNlY3Rpb24+XG4gICAgICAgIDxUZXh0IHRlbXBsYXRlPVwiaGVhZGVyXCI+SGVhZGVyPC9UZXh0PlxuICAgICAgICBDb250ZW50XG4gICAgICAgIDxUZXh0IHRlbXBsYXRlPVwiZm9vdGVyXCI+Rm9vdGVyPC9UZXh0PlxuICAgICAgPC9TZWN0aW9uPlxuICAgIDwvTGlzdD5cbiAgICBcIlwiXCJcbiAgZW5kXG5lbmQiLCJwYXRoIjoiLyJ9","chunks":[[0,109],[111,348],[461,45],[508,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule Server.ListSectionsLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <List>
      <Section>
        <Text template="header">Header</Text>
        Content
        <Text template="footer">Footer</Text>
      </Section>
    </List>
    """
  end
end
```

## ScrollView

The SwiftUI [ScrollView](https://developer.apple.com/documentation/swiftui/scrollview) displays content within a scrollable region. ScrollView is often used in combination with [LazyHStack](https://developer.apple.com/documentation/swiftui/lazyvstack), [LazyVStack](https://developer.apple.com/documentation/swiftui/lazyhstack), [LazyHGrid](https://developer.apple.com/documentation/swiftui/lazyhgrid), and [LazyVGrid](https://developer.apple.com/documentation/swiftui/lazyhgrid) to create scrollable layouts optimized for displaying large amounts of data.

While `ScrollView` also works with typical `VStack` and `HStack` views, they are not optimal choices for large amounts of data.

<!-- livebook:{"break_markdown":true} -->

### ScrollView with VStack

Here's an example using a `ScrollView` and a `HStack` to create scrollable text arranged horizontally.

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5TY3JvbGxWaWV3RXhhbXBsZUxpdmUgZG9cbiAgdXNlIFBob2VuaXguTGl2ZVZpZXdcbiAgdXNlIExpdmVWaWV3TmF0aXZlLkxpdmVWaWV3XG5cbiAgQGltcGwgdHJ1ZVxuICBkZWYgcmVuZGVyKCV7Zm9ybWF0OiA6c3dpZnR1aX0gPSBhc3NpZ25zKSBkb1xuICAgIH5TV0lGVFVJXCJcIlwiXG4gICAgPFNjcm9sbFZpZXc+XG4gICAgICA8VlN0YWNrPlxuICAgICAgICA8JT0gZm9yIG4gPC0gMS4uMTAwIGRvICU+XG4gICAgICAgICAgPFRleHQ+SXRlbSA8JT0gbiAlPjwvVGV4dD5cbiAgICAgICAgPCUgZW5kICU+XG4gICAgICA8L1ZTdGFjaz5cbiAgICA8L1Njcm9sbFZpZXc+XG4gICAgXCJcIlwiXG4gIGVuZFxuZW5kIiwicGF0aCI6Ii8ifQ","chunks":[[0,109],[111,344],[457,45],[504,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule Server.ScrollViewExampleLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <ScrollView>
      <VStack>
        <%= for n <- 1..100 do %>
          <Text>Item <%= n %></Text>
        <% end %>
      </VStack>
    </ScrollView>
    """
  end
end
```

### ScrollView with HStack

By default, the [axes](https://developer.apple.com/documentation/swiftui/scrollview/axes) of a `ScrollView` is vertical. To make a horizontal `ScrollView`, set the `axes` attribute to `"horizontal"` as seen in the example below.

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5TY3JvbGxWaWV3RXhhbXBsZUxpdmUgZG9cbiAgdXNlIFBob2VuaXguTGl2ZVZpZXdcbiAgdXNlIExpdmVWaWV3TmF0aXZlLkxpdmVWaWV3XG5cbiAgQGltcGwgdHJ1ZVxuICBkZWYgcmVuZGVyKCV7Zm9ybWF0OiA6c3dpZnR1aX0gPSBhc3NpZ25zKSBkb1xuICAgIH5TV0lGVFVJXCJcIlwiXG4gICAgPFNjcm9sbFZpZXcgYXhlcz1cImhvcml6b250YWxcIj5cbiAgICAgIDxIU3RhY2s+XG4gICAgICAgIDwlPSBmb3IgbiA8LSAxLi4xMDAgZG8gJT5cbiAgICAgICAgICA8VGV4dD5JdGVtIDwlPSBuICU+PC9UZXh0PlxuICAgICAgICA8JSBlbmQgJT5cbiAgICAgIDwvSFN0YWNrPlxuICAgIDwvU2Nyb2xsVmlldz5cbiAgICBcIlwiXCJcbiAgZW5kXG5lbmQiLCJwYXRoIjoiLyJ9","chunks":[[0,109],[111,362],[475,45],[522,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule Server.ScrollViewExampleLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <ScrollView axes="horizontal">
      <HStack>
        <%= for n <- 1..100 do %>
          <Text>Item <%= n %></Text>
        <% end %>
      </HStack>
    </ScrollView>
    """
  end
end
```

### Optimized ScrollView with LazyHStack and LazyVStack

`VStack` and `HStack` are inefficient for large amounts of data because they render every child view. To demonstrate this, evaluate the example below. You should experience lag when you attempt to scroll.

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5MYWdFeGFtcGxlTGl2ZSBkb1xuICB1c2UgUGhvZW5peC5MaXZlVmlld1xuICB1c2UgTGl2ZVZpZXdOYXRpdmUuTGl2ZVZpZXdcblxuICBAaW1wbCB0cnVlXG4gIGRlZiByZW5kZXIoJXtmb3JtYXQ6IDpzd2lmdHVpfSA9IGFzc2lnbnMpIGRvXG4gICAgflNXSUZUVUlcIlwiXCJcbiAgICA8U2Nyb2xsVmlldz5cbiAgICAgIDxWU3RhY2s+XG4gICAgICAgIDwlPSBmb3IgbiA8LSAxLi4xMDAwMCBkbyAlPlxuICAgICAgICAgIDxUZXh0Pkl0ZW0gPCU9IG4gJT48L1RleHQ+XG4gICAgICAgIDwlIGVuZCAlPlxuICAgICAgPC9WU3RhY2s+XG4gICAgPC9TY3JvbGxWaWV3PlxuICAgIFwiXCJcIlxuICBlbmRcbmVuZCIsInBhdGgiOiIvIn0","chunks":[[0,109],[111,339],[452,45],[499,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule Server.LagExampleLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <ScrollView>
      <VStack>
        <%= for n <- 1..10000 do %>
          <Text>Item <%= n %></Text>
        <% end %>
      </VStack>
    </ScrollView>
    """
  end
end
```

To resolve the performance problem for large amounts of data, you can use the Lazy views. Lazy views only create items as needed. Items won't be rendered until they are present on the screen.

The next example demonstrates how using `LazyVStack` instead of `VStack` resolves the performance issue.

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5PcHRpbWl6ZWRTY3JvbGxWaWV3TGl2ZSBkb1xuICB1c2UgUGhvZW5peC5MaXZlVmlld1xuICB1c2UgTGl2ZVZpZXdOYXRpdmUuTGl2ZVZpZXdcblxuICBAaW1wbCB0cnVlXG4gIGRlZiByZW5kZXIoJXtmb3JtYXQ6IDpzd2lmdHVpfSA9IGFzc2lnbnMpIGRvXG4gICAgflNXSUZUVUlcIlwiXCJcbiAgICA8U2Nyb2xsVmlldz5cbiAgICAgIDxMYXp5VlN0YWNrPlxuICAgICAgICA8JT0gZm9yIG4gPC0gMS4uMTAwMDAgZG8gJT5cbiAgICAgICAgICA8VGV4dD5JdGVtIDwlPSBuICU+PC9UZXh0PlxuICAgICAgICA8JSBlbmQgJT5cbiAgICAgIDwvTGF6eVZTdGFjaz5cbiAgICA8L1Njcm9sbFZpZXc+XG4gICAgXCJcIlwiXG4gIGVuZFxuZW5kIiwicGF0aCI6Ii8ifQ","chunks":[[0,109],[111,356],[469,45],[516,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule Server.OptimizedScrollViewLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <ScrollView>
      <LazyVStack>
        <%= for n <- 1..10000 do %>
          <Text>Item <%= n %></Text>
        <% end %>
      </LazyVStack>
    </ScrollView>
    """
  end
end
```

## Spacers

[Spacers](https://developer.apple.com/documentation/swiftui/spacer) take up all remaining space in a container.

![Apple Documentation](https://docs-assets.developer.apple.com/published/189fa436f07ed0011bd0c1abeb167723/Building-Layouts-with-Stack-Views-4@2x.png)

> Image originally from https://developer.apple.com/documentation/swiftui/spacer

Evaluate the following example and notice the `Text` element is pushed to the right by the `Spacer`.

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5TcGFjZXJMaXZlIGRvXG4gIHVzZSBQaG9lbml4LkxpdmVWaWV3XG4gIHVzZSBMaXZlVmlld05hdGl2ZS5MaXZlVmlld1xuXG4gIEBpbXBsIHRydWVcbiAgZGVmIHJlbmRlcigle2Zvcm1hdDogOnN3aWZ0dWl9ID0gYXNzaWducykgZG9cbiAgICB+U1dJRlRVSVwiXCJcIlxuICAgIDxIU3RhY2s+XG4gICAgICA8U3BhY2VyLz5cbiAgICAgIDxUZXh0PlRoaXMgdGV4dCBpcyBwdXNoZWQgdG8gdGhlIHJpZ2h0PC9UZXh0PlxuICAgIDwvSFN0YWNrPlxuICAgIFwiXCJcIlxuICBlbmRcbmVuZCIsInBhdGgiOiIvIn0","chunks":[[0,109],[111,273],[386,45],[433,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule Server.SpacerLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <HStack>
      <Spacer/>
      <Text>This text is pushed to the right</Text>
    </HStack>
    """
  end
end
```

### Your Turn: Bottom Text Spacer

In the cell below, use `VStack` and `Spacer` to place text in the bottom of the native view.

### Example Solution

```elixir
defmodule Server.HomeLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <VStack>
      <Spacer/>
      <Text>Hello</Text>
    </VStack>
    """
  end
end
```



<!-- livebook:{"break_markdown":true} -->

### Enter Your Solution Below

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5Cb3R0b21UZXh0U3BhY2VyTGl2ZSBkb1xuICB1c2UgUGhvZW5peC5MaXZlVmlld1xuICB1c2UgTGl2ZVZpZXdOYXRpdmUuTGl2ZVZpZXdcblxuICBAaW1wbCB0cnVlXG4gIGRlZiByZW5kZXIoJXtmb3JtYXQ6IDpzd2lmdHVpfSA9IGFzc2lnbnMpIGRvXG4gICAgflNXSUZUVUlcIlwiXCJcbiAgICA8IS0tIEVudGVyIHNvbHV0aW9uIGJlbG93IC0tPlxuICAgIFwiXCJcIlxuICBlbmRcbmVuZCIsInBhdGgiOiIvIn0","chunks":[[0,109],[111,222],[335,45],[382,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule Server.BottomTextSpacerLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <!-- Enter solution below -->
    """
  end
end
```

## AsyncImage

`AsyncImage` is best for network images, or images served by the Phoenix server.

Here's an example of `AsyncImage` with a lorem picsum image from https://picsum.photos/400/600.

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5Bc3luY0ltYWdlTGl2ZSBkb1xuICB1c2UgUGhvZW5peC5MaXZlVmlld1xuICB1c2UgTGl2ZVZpZXdOYXRpdmUuTGl2ZVZpZXdcblxuICBAaW1wbCB0cnVlXG4gIGRlZiByZW5kZXIoJXtmb3JtYXQ6IDpzd2lmdHVpfSA9IGFzc2lnbnMpIGRvXG4gICAgflNXSUZUVUlcIlwiXCJcbiAgICA8QXN5bmNJbWFnZSB1cmw9XCJodHRwczovL3BpY3N1bS5waG90b3MvNDAwLzQwMFwiPjwvQXN5bmNJbWFnZT5cbiAgICBcIlwiXCJcbiAgZW5kXG5lbmQiLCJwYXRoIjoiLyJ9","chunks":[[0,109],[111,248],[361,45],[408,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule Server.AsyncImageLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <AsyncImage url="https://picsum.photos/400/400"></AsyncImage>
    """
  end
end
```

### Loading Spinner

`AsyncImage` displays a loading spinner while loading the image. Here's an example of using `AsyncImage` without a URL so that it loads forever.

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5Mb2FkaW5nU3Bpbm5lckxpdmUgZG9cbiAgdXNlIFBob2VuaXguTGl2ZVZpZXdcbiAgdXNlIExpdmVWaWV3TmF0aXZlLkxpdmVWaWV3XG5cbiAgQGltcGwgdHJ1ZVxuICBkZWYgcmVuZGVyKCV7Zm9ybWF0OiA6c3dpZnR1aX0gPSBhc3NpZ25zKSBkb1xuICAgIH5TV0lGVFVJXCJcIlwiXG4gICAgPEFzeW5jSW1hZ2UgdXJsPVwiXCI+PC9Bc3luY0ltYWdlPlxuICAgIFwiXCJcIlxuICBlbmRcbmVuZCIsInBhdGgiOiIvIn0","chunks":[[0,109],[111,223],[336,45],[383,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule Server.LoadingSpinnerLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <AsyncImage url=""></AsyncImage>
    """
  end
end
```

### Relative Path

For images served by the Phoenix server, LiveView Native evaluates URLs relative to the LiveView's host URL. This way you can use the path to static resources as you normally would in a Phoenix application.

For example, the path `/images/logo.png` evaluates as http://localhost:4000/images/logo.png below. This serves the LiveView Native logo.

Evaluate the example below to see the LiveView Native logo in the iOS simulator.

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5SZWxhdGl2ZVBhdGhMaXZlIGRvXG4gIHVzZSBQaG9lbml4LkxpdmVWaWV3XG4gIHVzZSBMaXZlVmlld05hdGl2ZS5MaXZlVmlld1xuXG4gIEBpbXBsIHRydWVcbiAgZGVmIHJlbmRlcigle2Zvcm1hdDogOnN3aWZ0dWl9ID0gYXNzaWducykgZG9cbiAgICB+U1dJRlRVSVwiXCJcIlxuICAgIDxBc3luY0ltYWdlIHVybD1cIi9pbWFnZXMvbG9nby5wbmdcIi8+XG4gICAgXCJcIlwiXG4gIGVuZFxuZW5kIiwicGF0aCI6Ii8ifQ","chunks":[[0,109],[111,225],[338,45],[385,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule Server.RelativePathLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <AsyncImage url="/images/logo.png"/>
    """
  end
end
```

## Image

The `Image` element is best for system images such as the built in [SF Symbols](https://developer.apple.com/design/human-interface-guidelines/sf-symbols) or images placed into the SwiftUI [asset catalogue](https://developer.apple.com/documentation/xcode/managing-assets-with-asset-catalogs).

<!-- livebook:{"break_markdown":true} -->

### System Images

You can use the `system-image` attribute to provide the name of system images to the `Image` element.

For the full list of SF Symbols you can download Apple's [Symbols 5](https://developer.apple.com/sf-symbols/) application.

Evaluate the cell below to see an example using the `square.and.arrow.up` symbol.

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5JbWFnZUxpdmUgZG9cbiAgdXNlIFBob2VuaXguTGl2ZVZpZXdcbiAgdXNlIExpdmVWaWV3TmF0aXZlLkxpdmVWaWV3XG5cbiAgQGltcGwgdHJ1ZVxuICBkZWYgcmVuZGVyKCV7Zm9ybWF0OiA6c3dpZnR1aX0gPSBhc3NpZ25zKSBkb1xuICAgIH5TV0lGVFVJXCJcIlwiXG4gICAgPEltYWdlIHN5c3RlbS1uYW1lPVwic3F1YXJlLmFuZC5hcnJvdy51cFwiIC8+XG4gICAgXCJcIlwiXG4gIGVuZFxuZW5kIiwicGF0aCI6Ii8ifQ","chunks":[[0,109],[111,225],[338,45],[385,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule Server.ImageLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <Image system-name="square.and.arrow.up" />
    """
  end
end
```

### Your Turn: Asset Catalogue

Instead of using built-in system images, you can place assets in your SwiftUI application. Follow this guide: https://developer.apple.com/documentation/xcode/managing-assets-with-asset-catalogs#Add-a-new-asset to create a new asset called Image.

Using the asset catalogue for SwiftUI assets provide many benefits such as device-specific image variants, dark mode images, high contrast image mode, performance optimization, and more.

Then evaluate the following example and you should see this image in your simulator. For a convenient image, you can right-click and save the following LiveView Native logo.

![LiveView Native Logo](https://github.com/liveview-native/documentation_assets/blob/main/logo.png?raw=true)

You will need to **rebuild the native application** to pick up the changes to the assets catalogue.

<!-- livebook:{"break_markdown":true} -->

### Enter Your Solution Below

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5Bc3NldENhdGFsb2d1ZUxpdmUgZG9cbiAgdXNlIFBob2VuaXguTGl2ZVZpZXdcbiAgdXNlIExpdmVWaWV3TmF0aXZlLkxpdmVWaWV3XG5cbiAgQGltcGwgdHJ1ZVxuICBkZWYgcmVuZGVyKCV7Zm9ybWF0OiA6c3dpZnR1aX0gPSBhc3NpZ25zKSBkb1xuICAgIH5TV0lGVFVJXCJcIlwiXG4gICAgPEltYWdlIG5hbWU9XCJJbWFnZVwiLz5cbiAgICBcIlwiXCJcbiAgZW5kXG5lbmQiLCJwYXRoIjoiLyJ9","chunks":[[0,109],[111,212],[325,45],[372,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule Server.AssetCatalogueLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <Image name="Image"/>
    """
  end
end
```

## Button

A Button is a clickable SwiftUI View.

The label of a button can be any view, such as a [Text](https://developer.apple.com/documentation/swiftui/text) view for text-only buttons or a [Label](https://developer.apple.com/documentation/swiftui/label) view for buttons with icons.

Evaluate the example below to see the SwiftUI [Button](https://developer.apple.com/documentation/swiftui/button) element.

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5CdXR0b25MaXZlIGRvXG4gIHVzZSBQaG9lbml4LkxpdmVWaWV3XG4gIHVzZSBMaXZlVmlld05hdGl2ZS5MaXZlVmlld1xuXG4gIEBpbXBsIHRydWVcbiAgZGVmIHJlbmRlcigle2Zvcm1hdDogOnN3aWZ0dWl9ID0gYXNzaWducykgZG9cbiAgICB+U1dJRlRVSVwiXCJcIlxuICAgIDxCdXR0b24+PFRleHQ+VGV4dCBCdXR0b248L1RleHQ+PC9CdXR0b24+XG4gICAgPEJ1dHRvbj48TGFiZWwgc3lzdGVtLWltYWdlPVwiYm9sdC5maWxsXCI+SWNvbiBCdXR0b248L0xhYmVsPjwvQnV0dG9uPlxuICAgIFwiXCJcIlxuICBlbmRcbmVuZCIsInBhdGgiOiIvIn0","chunks":[[0,109],[111,297],[410,45],[457,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
defmodule Server.ButtonLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <Button><Text>Text Button</Text></Button>
    <Button><Label system-image="bolt.fill">Icon Button</Label></Button>
    """
  end
end
```

## Further Resources

See the [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui) for a complete list of SwiftUI elements and the [LiveView Native SwiftUI Documentation](https://liveview-native.github.io/liveview-client-swiftui/documentation/liveviewnative/) for LiveView Native examples of the SwiftUI elements.

