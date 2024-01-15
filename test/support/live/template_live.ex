defmodule LiveViewNativeTest.TemplateLive.GameBoy do
  use LiveViewNative.Component,
    format: :gameboy,
    as: :render,
    layout: {LiveViewNativeTest.GameBoyLayouts, :app}
end

defmodule LiveViewNativeTest.TemplateLive.Switch do
  use LiveViewNative.Component,
    format: :switch,
    as: :render,
    layout: {LiveViewNativeTest.SwitchLayouts, :app}
end

defmodule LiveViewNativeTest.TemplateLive do
  use Phoenix.LiveView,
    layout: {LiveViewNativeTest.Layouts, :app}

  use LiveViewNative.LiveView,
    formats: [:gameboy, :switch],
    layouts: [
      gameboy: {LiveViewNativeTest.GameBoyLayouts, :app}
    ]

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :count, 200)}
  end
end