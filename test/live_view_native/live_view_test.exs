defmodule LiveViewNative.LiveViewTest do
  use ExUnit.Case

  alias LiveViewNative.TestLiveView
  alias LiveViewNative.TestLiveViewInline

  test "modules using LiveViewNative have a render_native/1 function" do
    Code.ensure_compiled(LiveViewNative.TestLiveView)

    assert function_exported?(TestLiveView, :render_native, 1)
  end

  test "calling render_native/1 renders the correct platform for `assigns`" do
    web_context = LiveViewNativePlatform.Kit.compile(%LiveViewNative.Platforms.Web{})
    test_context = LiveViewNativePlatform.Kit.compile(%LiveViewNative.TestPlatform{})
    web_result = TestLiveView.render(%{platform_id: :web, native: web_context})
    test_result = TestLiveView.render(%{platform_id: :lvntest, native: test_context})

    assert web_result.static == [
             "<div>\n  <span>This is an HTML template</span>\n  <input>\n</div>"
           ]

    assert test_result.static == [
             "<div>\n  <span>This is not an HTML template</span>\n  <input>\n    <faketag>(not actually HTML)</faketag>\n  </input>\n</div>"
           ]
  end

  test "calling render/1 renders platform-specific templates inline" do
    web_context = LiveViewNativePlatform.Kit.compile(%LiveViewNative.Platforms.Web{})
    test_context = LiveViewNativePlatform.Kit.compile(%LiveViewNative.TestPlatform{})
    web_result = TestLiveViewInline.render(%{platform_id: :web, native: web_context})
    test_result = TestLiveViewInline.render(%{platform_id: :lvntest, native: test_context})

    assert web_result.static == ["<div>Hello from the web</div>"]
    assert test_result.static == ["<Text>Hello from the test platform</Text>"]
  end
end
