defmodule LiveViewNative.Component do
  @moduledoc """
  Upgrades a Live Component to a Native Live Component when inherited
  with `use LiveViewNative.Component` like so:

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
