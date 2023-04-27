defmodule LiveViewNative.TestLiveViewInline do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def render(%{platform_id: :lvntest} = assigns) do
    ~Z"""
    <Text>Hello from the test platform</Text>
    """lvntest
  end

  def render(assigns) do
    ~H"""
    <div>Hello from the web</div>
    """
  end
end
