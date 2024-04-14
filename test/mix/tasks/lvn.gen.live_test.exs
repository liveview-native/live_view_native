defmodule Mix.Tasks.Lvn.Gen.LiveTest do
  use ExUnit.Case

  import Mix.Lvn.TestHelper

  alias Mix.Tasks.Lvn.Gen

  setup do
    Mix.Task.clear()
    :ok
  end

  test "generates a live file and the templates into the proper format directory", config do
    in_tmp_live_project config.test, fn ->
      Gen.Live.run(["gameboy", "Home"])
      assert_file "lib/live_view_native_web/live/gameboy/home_live.gameboy.neex"
      assert_file "lib/live_view_native_web/live/home_live.gameboy.ex", fn file ->
        assert file =~ "HomeLive.GameBoy"
        assert file =~ "use LiveViewNativeNative, [:render_component, format: :gameboy]"
      end
    end
  end

  test "will raise with message if invalid format is given", config do
    in_tmp_live_project config.test, fn ->
      assert_raise(Mix.Error, fn() ->
        Gen.Live.run(["other"])
      end)
      refute_file "lib/live_view_native_web/live/gameboy/home_live.gameboy.neex"
      refute_file "lib/live_view_native_web/live/home_live.gameboy.ex"
    end
  end
end
