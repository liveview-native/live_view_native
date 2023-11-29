defmodule LiveViewNative.LiveView do
  @moduledoc """
  Upgrades a LiveView to a native LiveView.

  To use, inherit with `use LiveViewNative.LiveView`
  like so:

  Example:

  ```
  defmodule MyApp.MyLive do
    use MyAppWeb, :live_view
    use LiveViewNative.LiveView

    # ...
  end
  ```
  """
  defmacro __using__(opts \\ []) do
    quote location: :keep do
      on_mount {LiveViewNative.LiveSession, :live_view_native}

      use LiveViewNative.Extensions, role: :live_view
    end
  end
end
