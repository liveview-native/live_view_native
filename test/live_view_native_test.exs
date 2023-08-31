defmodule LiveViewNativeTest do
  use ExUnit.Case

  test "platforms/0" do
    platforms = LiveViewNative.platforms()

    assert platforms
    assert is_map(platforms)
    assert platforms["web"]
    assert platforms["lvntest"]
  end

  describe "platform/1" do
    test "when platform_id is a non-nil atom" do
      {:ok, platform_struct} = LiveViewNative.platform(:lvntest)

      assert platform_struct
      assert platform_struct.platform_id == :lvntest

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
end
