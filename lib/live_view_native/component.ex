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
  defmacro __using__(_opts \\ []) do
    quote do
      use LiveViewNative.Extensions
    end
  end
end
