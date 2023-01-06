defmodule LiveViewNativeWeb.StatusLive do
  use LiveViewNativeWeb, :live_view
  use LiveViewNative.LiveView

  @impl true
  def render(assigns) do
    render_native(assigns)
  end
end
