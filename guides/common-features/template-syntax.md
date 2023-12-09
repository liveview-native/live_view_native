# Template Syntax

LiveView Native platforms use EEx templates which resemble the native APIs they're based
on as closely as possible. This is in contrast to frameworks that provide custom element
names which then get translated to native components.

Consider the following example for a SwiftUI view. It is represented in LiveView Native using
all of the same elements like `List`, `HStack`, etc. To do this we adapt the original SwiftUI
element and attribute names to the semantics of the EEx syntax using `~SWIFTUI`, like so:

<!-- tabs-open -->

### Elixir

LiveView Native components for SwiftUI use SwiftUI-like syntax.

```elixir
defmodule MyAppWeb.MyComponents do
  use Phoenix.LiveView
  use LiveViewNative.Component

  def album_detail(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <List>
      <%= for song <- @album.songs do %>
        <HStack>
          <Image name={@album.cover} />
          <VStack alignment="leading">
            <Text class="bold"><%= song.title %></Text>
            <Text><%= song.artist.name %></Text>
          </VStack>
        </HStack>
      <% end %>
    </List>
    """
  end
end
```

### Swift

The same component would be represented in SwiftUI like this:

```swift
import SwiftUI

struct AlbumDetail: View {
  var album: Album

  var body: some View {
    List(album.songs) { song in
      HStack {
        Image(album.cover)
        VStack(alignment: .leading) {
          Text(song.title)
            .fontWeight(.bold)
          Text(song.artist.name)
        }
      }
    }
  }
}
```

<!-- tabs-close -->

Here we can observe various semantic changes to port SwiftUI code to EEx:

1. SwiftUI view names are used as elements, like [List](https://developer.apple.com/documentation/swiftui/list) and [VStack](https://developer.apple.com/documentation/swiftui/vstack).
   - The argument syntax (i.e. `alignment: .leading` to `alignment="leading"`) is adapted as well.
2. The struct value `album` is an assign, `@album`, instead.
3. Instead of passing `album.songs` as an argument, we use a comprehension.
    - `<Text>` elements take their arguments as values, similar to HTML.

These conventions can generally be applied to all sorts of examples when using LiveView Native to build SwiftUI views.
Because LiveView Native is modular, each platform library will have its own way of "bridging the gap" between the Elixir
side of your app and the native side.

Officially supported platform libraries are designed with general platform-parity in mind; while some light abstractions
may be used in cases where the native syntax doesn't map perfectly onto LiveView templates, any names of elements,
attributes, structs, enums, types, etc. are typically carried over in identical or approximate (i.e. camel case to
snake case) form.

For more information on writing platform-specific template code, consult the documentation for each platform you want
your app to support.

<!-- tabs-open -->

### SwiftUI

Covers iOS 16+, macOS 13+ and watchOS 9+.

- [Platform library HexDocs](https://hexdocs.pm/live_view_native_swift_ui/)
- [Swift library docs](https://liveview-native.github.io/liveview-client-swiftui/documentation/liveviewnative/)
- [SwiftUI docs](https://developer.apple.com/documentation/swiftui/)
- [SwiftUI tutorials](https://developer.apple.com/tutorials/swiftui)
- [Xcode docs](https://developer.apple.com/documentation/xcode)

### Jetpack

Covers Android.

- [Platform library HexDocs](https://hexdocs.pm/live_view_native_jetpack/)
- [Jetpack Compose tutorial](https://developer.android.com/jetpack/compose/tutorial)

<!-- tabs-close -->
