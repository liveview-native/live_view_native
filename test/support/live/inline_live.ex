defmodule LiveViewNativeTest.InlineLive.GameBoy do
  use LiveViewNative.Component,
    format: :gameboy,
    as: :render,
    layout: {LiveViewNativeTest.GameBoyLayouts, :app}

  def render(assigns, %{"target" => "tv"}) do
    ~LVN"""
    <GameBoyTV>TV Target Inline GameBoy Render <%= @count %></GameBoyTV>
    """
  end

  def render(assigns, _interface) do
    ~LVN"""
    <GameBoy>Inline GameBoy Render <%= @count %></GameBoy>
    """
  end
end

defmodule LiveViewNativeTest.InlineLive.Switch do
  use LiveViewNative.Component,
    format: :switch,
    as: :render,
    layout: {LiveViewNativeTest.SwitchLayouts, :app}

  def render(assigns, %{"target" => "tv"}) do
    ~LVN"""
    <SwitchTV>TV Target Inline Switch Render <%= @count %></SwitchTV>
    """
  end

  def render(assigns, _interface) do
    ~LVN"""
    <Switch>Inline Switch Render <%= @count %></Switch>
    """
  end
end

defmodule LiveViewNativeTest.InlineLive do
  use Phoenix.LiveView,
    layout: {LiveViewNativeTest.Layouts, :app}

  use LiveViewNative.LiveView,
    formats: [:gameboy, :switch],
    layouts: [
      gameboy: {LiveViewNativeTest.GameBoyLayouts, :app}
    ]

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :count, 100)}
  end

  def render(assigns) do
    ~H"""
    <div id="inline">original inline HTML works</div>
    """
  end
end
