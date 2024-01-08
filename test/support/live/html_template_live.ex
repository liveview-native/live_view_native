defmodule LiveViewNativeTest.HTMLTemplateLive.HTML do
  use LiveViewNative.Component,
    format: :html,
    as: :render
end

defmodule LiveViewNativeTest.HTMLTemplateLive do
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