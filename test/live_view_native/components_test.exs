defmodule LiveViewNative.ComponentsTest do
  use ExUnit.Case

  import Phoenix.LiveViewTest
  alias LiveViewNative.TestComponents
  import Meeseeks.CSS

  test "test_component/1 renders as expected" do
    html_context = LiveViewNativePlatform.Kit.compile(%LiveViewNative.Platforms.HTML{})
    test_context = LiveViewNativePlatform.Kit.compile(%LiveViewNative.TestPlatform{})
    html_result =
      render_component(&TestComponents.test_component/1, platform_id: :html, native: html_context)
      |> Meeseeks.parse(:html)
    test_result =
      render_component(&TestComponents.test_component/1, platform_id: :lvntest, native: test_context)
      |> Meeseeks.parse(:xml)

    local_component_result = Meeseeks.one(test_result, css("#local-component-test"))
    remote_component_result = Meeseeks.one(test_result, css("#remote-component-test"))
    imported_component_result = Meeseeks.one(test_result, css("#imported-component-test"))
    component_with_inner_block_result_content = Meeseeks.one(test_result, css("#component-with-inner-block-test #content"))
    component_with_inner_block_result_inner_block = Meeseeks.one(test_result, css("#component-with-inner-block-test #inner-block-test"))
    component_with_slot_result_content = Meeseeks.one(test_result, css("#component-with-slot-test #content"))
    component_with_slot_result_slot = Meeseeks.one(test_result, css("#component-with-slot-test #slot-test"))
    html_element_result = Meeseeks.one(html_result, css("#html-element-test"))

    assert Meeseeks.text(local_component_result) == "Local Component Rendered"
    assert Meeseeks.text(remote_component_result) == "Remote Component Rendered"
    assert Meeseeks.text(imported_component_result) == "Imported Component Rendered"
    assert Meeseeks.text(component_with_inner_block_result_content) == "Component With Inner Block Rendered"
    assert Meeseeks.text(component_with_inner_block_result_inner_block) == "Inner Block Rendered"
    assert Meeseeks.text(component_with_slot_result_content) == "Component With Slot Rendered"
    assert Meeseeks.text(component_with_slot_result_slot) == "Slot Rendered"
    assert Meeseeks.text(html_element_result) == "HTML Element Rendered"
  end
end
