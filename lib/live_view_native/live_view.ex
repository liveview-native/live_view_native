defmodule LiveViewNative.LiveView do
  @moduledoc """
  Upgrades a LiveView to a Native LiveView when inherited with
  `use LiveViewNative.LiveView` like so:

  ```
  defmodule MyApp.MyLive do
    use MyAppWeb, :live_view
    use LiveViewNative.LiveView

    # ...
  end
  ```
  """
  defmacro __using__(_opts \\ []) do
    quote do
      on_mount {LiveViewNative.LiveSession, :live_view_native}

      use LiveViewNative.Extensions
    end
  end
end
