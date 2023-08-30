defmodule LiveViewNative.LiveComponent do
  @moduledoc """
  Upgrades a Live Component to a native Live Component.

  To use, inherit with `use LiveViewNative.LiveComponent`
  like so:

  ```
  defmodule MyApp.MyComponent do
    use MyAppWeb, :live_component
    use LiveViewNative.LiveComponent

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
