defmodule LiveViewNativeTest.HTMLInlineLive.HTML do
  use LiveViewNative.Component,
    format: :html

  def render(assigns, %{target: "mobile"}) do
    ~H"""
    <div id="mobile-inline">Mobile Target Inline HTML Override Render <%= @count %></div>
    """
  end

  def render(assigns, _interface) do
    ~H"""
    <div id="inline">Inline HTML Override Render <%= @count %></div>
    """
  end
end

defmodule LiveViewNativeTest.HTMLInlineLive do
  use Phoenix.LiveView,
    layout: {LiveViewNativeTest.Layouts, :app}

  use LiveViewNative.LiveView,
    formats: [:html],
    layouts: [
      html: {LiveViewNativeTest.Layouts, :override}
    ]

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :count, 100)}
  end

  def render(assigns), do: ~H""
end