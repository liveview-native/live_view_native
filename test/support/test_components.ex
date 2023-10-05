defmodule LiveViewNative.TestComponents do
  use Phoenix.Component
  use LiveViewNative.Component

  attr :platform_id, :atom

  def test_component(%{platform_id: :lvntest} = assigns) do
    ~LVN"""
    <Container>
      <.local_component_example platform_id={:lvntest} />
      <LiveViewNative.TestComponents.remote_component_example platform_id={:lvntest} />
      <.imported_component_example platform_id={:lvntest} />
      <.component_with_inner_block_example platform_id={:lvntest}>
        <Text id="inner-block-test">Inner Block Rendered</Text>
      </.component_with_inner_block_example>
      <.component_with_slot_example platform_id={:lvntest}>
      <:item>
        <Text id="slot-test">Slot Rendered</Text>
      </:item>
      </.component_with_slot_example>
    </Container>
    """lvntest
  end

  def test_component(%{} = assigns) do
    ~H"""
    <div id="html-element-test">HTML Element Rendered</div>
    """
  end

  attr :platform_id, :atom

  def local_component_example(%{platform_id: :lvntest} = assigns) do
    ~LVN"""
    <Text id="local-component-test">Local Component Rendered</Text>
    """lvntest
  end

  attr :platform_id, :atom

  def remote_component_example(%{platform_id: :lvntest} = assigns) do
    ~LVN"""
    <Text id="remote-component-test">Remote Component Rendered</Text>
    """lvntest
  end

  attr :platform_id, :atom

  def imported_component_example(%{platform_id: :lvntest} = assigns) do
    ~LVN"""
    <Text id="imported-component-test">Imported Component Rendered</Text>
    """lvntest
  end

  attr :platform_id, :atom
  slot :inner_block

  def component_with_inner_block_example(%{platform_id: :lvntest} = assigns) do
    ~LVN"""
    <Container id="component-with-inner-block-test">
      <Text id="content">Component With Inner Block Rendered</Text>
      <%= render_slot(@inner_block) %>
    </Container>
    """lvntest
  end

  attr :platform_id, :atom
  slot :item

  def component_with_slot_example(%{platform_id: :lvntest} = assigns) do
    ~LVN"""
    <Container id="component-with-slot-test">
      <Text id="content">Component With Slot Rendered</Text>
      <%= render_slot(@item) %>
    </Container>
    """lvntest
  end
end
