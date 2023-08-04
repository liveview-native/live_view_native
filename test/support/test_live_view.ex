if Mix.env() == :test do
  defmodule LiveViewNative.TestLiveView do
    use Phoenix.LiveView
    use LiveViewNative.LiveView

    @impl true
    def render(assigns) do
      render_native(assigns)
    end
  end
end
