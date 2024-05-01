defmodule Mix.Tasks.Lvn.Gen.LayoutTest do
  use ExUnit.Case

  import Mix.Lvn.TestHelper

  alias Mix.Tasks.Lvn.Gen

  setup do
    Mix.Task.clear()
    :ok
  end

  describe "when a single app" do
    test "generates layout file and the layout templates into the proper format directory", config do
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
          Gen.Layout.run(["other"])
        end)
        refute_file "lib/live_view_native_web/components/layouts_gameboy/app.other.neex"
        refute_file "lib/live_view_native_web/components/layouts_gameboy/root.other.neex"
        refute_file "lib/live_view_native_web/components/layouts.other.ex"
      end
    end
  end

  describe "when an umbrella app" do
    test "generates layout file and the layout templates into the proper format directory", config do
      in_tmp_live_umbrella_project config.test, fn ->
        File.cd!("live_view_native_web", fn ->
          Gen.Layout.run(["gameboy"])
          assert_file "lib/live_view_native_web/components/layouts_gameboy/app.gameboy.neex"
          assert_file "lib/live_view_native_web/components/layouts_gameboy/root.gameboy.neex", fn file ->
            assert file =~ "app.gameboy"
          end
          assert_file "lib/live_view_native_web/components/layouts.gameboy.ex", fn file ->
            assert file =~ "LiveViewNativeNative"
          end
        end)
      end
    end

    test "will raise with message if invalid format is given", config do
      in_tmp_live_umbrella_project config.test, fn ->
        File.cd!("live_view_native_web", fn ->
          assert_raise(Mix.Error, fn() ->
            Gen.Layout.run(["other"])
          end)
          refute_file "lib/live_view_native_web/components/layouts_gameboy/app.other.neex"
          refute_file "lib/live_view_native_web/components/layouts_gameboy/root.other.neex"
          refute_file "lib/live_view_native_web/components/layouts.other.ex"
        end)
      end
    end
  end
end
