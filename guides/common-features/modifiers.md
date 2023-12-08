# Modifiers

Platform libraries may provide any number of modifiers for customizing the look and feel of native
elements. These modifiers are automatically available as functions when rendering platform-specific
templates in a module that uses one of the following macros:

- `LiveViewNative.LiveView`
- `LiveViewNative.LiveComponent`
- `LiveViewNative.Component`

Modifiers are typically used to adjust styling (colors, typography, etc.), presentation, interactivity
and other properties of the native UI you're targeting.

## Modifier functions

Here's a simple example of calling modifier functions inline for elements with the `modifiers` attribute in SwiftUI:

<!-- tabs-open -->

### Source

```elixir
defmodule MyAppWeb.ModifiersExampleLive do
  use Phoenix.LiveView
  use MyAppWeb, :live_view

  @impl true
  def render(%{format: :swiftui} = assigns) do
    # This UI renders on the iPhone / iPad app
    ~SWIFTUI"""
    <VStack>
      <Text>This text is normal</Text>
      <Text modifiers={font_weight(:bold)}>This text is bold</Text>
      <Spacer modifiers={frame(height: 16)} />
      <HStack>
        <Image system-name="heart.fill" modifiers={
          background(alignment: :center, content: :heart_bg)
          |> foreground_style({:color, :white})
        }>
          <Circle template={:heart_bg} modifiers={
            frame(width: 32, height: 32)
            |> foreground_style({:color, :red})
          } />
        </Image>
      </HStack>
    </VStack>
    """
  end
end
```

### Result

![Modifiers example](./assets/images/modifiers-example.png)

<!-- tabs-close -->

Modifier functions may have different arities and take different types of arguments, which are generally based on the
original APIs they're based on. All modifier functions return a `%LiveViewNativePlatform.Env{}` struct (same as the
`@native` assign) which can be passed to other modifier functions, effectively allowing them to be chained together.

For more information of which modifiers a platform supports and how to use them, check the documentation for that
platform as well as the relevant source material for that platform. 

## Modifier Classes

Using a lot of modifiers in your templates can cause them to become overly verbose and difficult to maintain over
time. You also might want to share modifiers between many different views and elements instead of copying them
across templates. Modifier classes solve both of these problems by letting you decouple your modifiers from your
templates.

Here's the previous example, adjusted to use modifier classes defined in a separate module:

<!-- tabs-open -->

### modifiers_example_live.ex

```elixir
defmodule MyAppWeb.ModifiersExampleLive do
  use Phoenix.LiveView
  use MyAppWeb, :live_view

  import MyAppWeb.Modclasses, only: [modclass: 3]

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <VStack>
      <Text>This text is normal</Text>
      <Text modclass="bold">This text is bold</Text>
      <Spacer modclass="spacer" />
      <HStack>
        <Image modclass="heart" system-name="heart.fill">
          <Circle modclass="heart_bg" template={:heart_bg} />
        </Image>
      </HStack>
    </VStack>
    """
  end
end
```

### modclasses.ex

```elixir
defmodule MyAppWeb.Modclasses do
  use LiveViewNative.Modclasses, platform: :swiftui

  def modclass(native, "bold", _assigns) do
    font_weight(native, :bold)
  end

  def modclass(native, "spacer", _assigns) do
    frame(native, height: 16)
  end

  def modclass(native, "heart", _assigns) do
    native
    |> background(alignment: :center, content: :heart_bg)
    |> foreground_style({:color, :white})
  end

  def modclass(native, "heart_bg", _assigns) do
    native
    |> frame(width: 32, height: 32)
    |> foreground_style({:color, :red})
  end
end
```

### Result

![Modifiers example](./assets/images/modifiers-example.png)

<!-- tabs-close -->

An element can have any number of modifier classes, providing some composability for modifier functions:

<!-- tabs-open -->

### modifiers_example_live.ex

```elixir
defmodule MyAppWeb.ModifiersExampleLive do
  use Phoenix.LiveView
  use MyAppWeb, :live_view

  import MyAppWeb.Modclasses, only: [modclass: 3]

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <VStack>
      <Text>This text is normal</Text>
      <Text modclass="bold">This text is bold</Text>
      <Text modclass="italic">This text is bold</Text>
      <Text modclass="bold italic">This text is bold and italic</Text>
    </VStack>
    """
  end
end
```

### modclasses.ex

```elixir
defmodule MyAppWeb.Modclasses do
  use LiveViewNative.Modclasses, platform: :swiftui

  def modclass(native, "bold", _assigns) do
    font_weight(native, :bold)
  end

  def modclass(native, "italic", _assigns) do
    italic(native, %{})
  end
end
```

### Result

![Modclasses example](./assets/images/modclasses-example.png)

<!-- tabs-close -->

Modclasses within templates are translated at compile-time to their inline counterparts, so passing an assign or other
dynamic value to the `modclass` attribute won't work. To support dynamic modifier classes that reference assigns or the
modifier name itself, define any conditional logic within `modclass/3`.
