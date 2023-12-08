defmodule LiveViewNative.TestComponents do
  use Phoenix.Component
  use LiveViewNative.Component

  attr :format, :atom

  def test_component(%{format: :lvntest} = assigns) do
    ~LVN"""
    <Container>
      <.local_component_example format={:lvntest} />
      <LiveViewNative.TestComponents.remote_component_example format={:lvntest} />
      <.imported_component_example format={:lvntest} />
      <.component_with_inner_block_example format={:lvntest}>
        <Text id="inner-block-test">Inner Block Rendered</Text>
      </.component_with_inner_block_example>
      <.component_with_slot_example format={:lvntest}>
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

  attr :format, :atom

  def local_component_example(%{format: :lvntest} = assigns) do
    ~LVN"""
    <Text id="local-component-test">Local Component Rendered</Text>
    """lvntest
  end

  attr :format, :atom

  def remote_component_example(%{format: :lvntest} = assigns) do
    ~LVN"""
    <Text id="remote-component-test">Remote Component Rendered</Text>
    """lvntest
  end

  attr :format, :atom

  def imported_component_example(%{format: :lvntest} = assigns) do
    ~LVN"""
    <Text id="imported-component-test">Imported Component Rendered</Text>
    """lvntest
  end

  attr :format, :atom
  slot :inner_block

  def component_with_inner_block_example(%{format: :lvntest} = assigns) do
    ~LVN"""
    <Container id="component-with-inner-block-test">
      <Text id="content">Component With Inner Block Rendered</Text>
      <%= render_slot(@inner_block) %>
    </Container>
    """lvntest
  end

  attr :format, :atom
  slot :item

  def component_with_slot_example(%{format: :lvntest} = assigns) do
    ~LVN"""
    <Container id="component-with-slot-test">
      <Text id="content">Component With Slot Rendered</Text>
      <%= render_slot(@item) %>
    </Container>
    """lvntest
  end
end
