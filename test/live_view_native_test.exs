defmodule LiveViewNativeTest do
  use ExUnit.Case

  test "platforms/0" do
    platforms = LiveViewNative.platforms()

    assert platforms
    assert is_map(platforms)
    assert platforms["web"]
    assert platforms["_live_view_native_test_internal"]
  end

  describe "platform/1" do
    test "when platform_id is a non-nil atom" do
      {:ok, platform_struct} = LiveViewNative.platform(:_live_view_native_test_internal)

      assert platform_struct
      assert platform_struct.platform_id == :_live_view_native_test_internal

      assert platform_struct.platform_config == %LiveViewNative.TestPlatform{
               testing_notes: "everything is ok"
             }
    end

    test "when platform_id is a binary" do
      {:ok, platform_struct} = LiveViewNative.platform("web")

      assert platform_struct
      assert platform_struct.platform_id == :web
      assert platform_struct.platform_config == %LiveViewNative.Platforms.Web{}
    end
  end

  describe "platform!/1" do
    test "when platform_id is valid" do
      platform_struct = LiveViewNative.platform!("web")

      assert platform_struct
      assert platform_struct.platform_id == :web
      assert platform_struct.platform_config == %LiveViewNative.Platforms.Web{}
    end

    test "when platform_id is invalid" do
      assert_raise RuntimeError, fn ->
        LiveViewNative.platform!("not-a-valid-platform-id")
      end
    end
  end

  describe "start_simulator!/1" do
    test "it starts a simulator for the given platform" do
      web_result = LiveViewNative.start_simulator!(:web)
      test_result = LiveViewNative.start_simulator!(:_live_view_native_test_internal)

      assert web_result == {:ok, :skipped}
      assert test_result == {:ok, "start_simulator/2 was called from LiveViewNative.TestPlatform"}
    end
  end
end
