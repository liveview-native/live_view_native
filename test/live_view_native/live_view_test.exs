defmodule LiveViewNative.LiveViewTest do
  use ExUnit.Case

  alias LiveViewNative.TestLiveView

  test "modules using LiveViewNative have a render_native/1 function" do
    Code.ensure_compiled(LiveViewNative.TestLiveView)

    assert function_exported?(TestLiveView, :render_native, 1)
  end

  test "calling render_native/1 renders the correct platform for `assigns`" do
    web_context = LiveViewNativePlatform.context(%LiveViewNative.Platforms.Web{})
    test_context = LiveViewNativePlatform.context(%LiveViewNative.TestPlatform{})
    web_result = TestLiveView.render(%{native: web_context})
    test_result = TestLiveView.render(%{native: test_context})

    assert web_result.static == ["<div>\n  <span>This is an HTML template</span>\n  <input>\n</div>"]
    assert test_result.static == ["<div>\n  <span>This is not an HTML template</span>\n  <input>\n    <faketag>(not actually HTML)</faketag>\n  </input>\n</div>"]
  end
end
