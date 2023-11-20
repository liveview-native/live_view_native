defmodule LiveViewNative.Component do
  @moduledoc """
  Upgrades a Phoenix Component to a native Phoenix Component.

  To use, inherit with `use LiveViewNative.Component`
  like so:

  Example:

  ```
  defmodule MyApp.MyComponent do
    use MyAppWeb, :live_component
    use LiveViewNative.Component

    # ...
  end
  ```
  """
  defmacro __using__(opts \\ []) do
    stylesheet = opts[:stylesheet]

    quote do
      use LiveViewNative.Extensions,
        role: :component,
        stylesheet: unquote(stylesheet)
    end
  end
end
