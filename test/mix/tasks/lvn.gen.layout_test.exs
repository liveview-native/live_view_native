defmodule Mix.Tasks.Lvn.Gen.LayoutTest do
  use ExUnit.Case

  import Mix.Lvn.TestHelper

  alias Mix.Tasks.Lvn.Gen

  setup do
    Mix.Task.clear()
    :ok
  end

  test "generates the `Native` module into the project's lib directory", config do
    in_tmp_live_project config.test, fn ->
      Gen.Layout.run(["gameboy"])
      assert_file "lib/live_view_native_web/components/layouts_gameboy/app.gameboy.neex"
      assert_file "lib/live_view_native_web/components/layouts_gameboy/root.gameboy.neex", fn file ->
        assert file =~ "app.gameboy"
      end
      assert_file "lib/live_view_native_web/components/layouts.gameboy.ex", fn file ->
        assert file =~ "LiveViewNativeNative"
      end
    end
  end

  test "will raise with message if invalid format is given", config do
    in_tmp_live_project config.test, fn ->
      assert_raise(Mix.Error, fn() ->
        Gen.run(["other"])
      end)
      refute_file "lib/live_view_native_web/components/layouts_gameboy/app.other.neex"
      refute_file "lib/live_view_native_web/components/layouts_gameboy/root.other.neex"
      refute_file "lib/live_view_native_web/components/layouts.other.ex"
    end
  end
end
