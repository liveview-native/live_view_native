defmodule LiveViewNative.ComponentsTest do
  use ExUnit.Case

  import Phoenix.LiveViewTest
  alias LiveViewNative.TestComponents

  defp one(fragment, selector) do
    [element | _tail] = Floki.find(fragment, selector)

    element
  end

  test "test_component/1 renders as expected" do
    html_context = LiveViewNativePlatform.Kit.compile(%LiveViewNative.Platforms.HTML{})
    test_context = LiveViewNativePlatform.Kit.compile(%LiveViewNative.TestPlatform{})

    html_result =
      render_component(&TestComponents.test_component/1, format: :html, native: html_context)
      |> Floki.parse_document!()

    test_result =
      render_component(&TestComponents.test_component/1,
        format: :lvntest,
        native: test_context
      )
      |> Floki.parse_document!()

    local_component_result = one(test_result, "#local-component-test")
    remote_component_result = one(test_result, "#remote-component-test")
    imported_component_result = one(test_result, "#imported-component-test")

    component_with_inner_block_result_content =
      one(test_result, "#component-with-inner-block-test #content")

    component_with_inner_block_result_inner_block =
      one(test_result, "#component-with-inner-block-test #inner-block-test")

    component_with_slot_result_content =
      one(test_result, "#component-with-slot-test #content")

    component_with_slot_result_slot =
      one(test_result, "#component-with-slot-test #slot-test")

    html_element_result = one(html_result, "#html-element-test")

    assert Floki.text(local_component_result) == "Local Component Rendered"
    assert Floki.text(remote_component_result) == "Remote Component Rendered"
    assert Floki.text(imported_component_result) == "Imported Component Rendered"

    assert Floki.text(component_with_inner_block_result_content) ==
             "Component With Inner Block Rendered"

    assert Floki.text(component_with_inner_block_result_inner_block) == "Inner Block Rendered"
    assert Floki.text(component_with_slot_result_content) == "Component With Slot Rendered"
    assert Floki.text(component_with_slot_result_slot) == "Slot Rendered"
    assert Floki.text(html_element_result) == "HTML Element Rendered"
  end
end
