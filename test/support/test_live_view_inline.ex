defmodule LiveViewNative.TestLiveViewInline do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def render(%{format: :lvntest} = assigns) do
    ~LVN"""
    <Text>Hello from the test platform</Text>
    """lvntest
  end

  def render(assigns) do
    ~H"""
    <div>Hello from the web</div>
    """
  end
end
