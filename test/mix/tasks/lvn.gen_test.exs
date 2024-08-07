defmodule Mix.Tasks.Lvn.GenTest do
  use ExUnit.Case

  import Mix.Lvn.TestHelper

  alias Mix.Tasks.Lvn.Gen

  setup do
    Mix.Task.clear()
    :ok
  end

  describe "when a single app" do
    test "generates the `Native` module into the project's lib directory and injects config", config do
      in_tmp_live_project config.test, fn ->
        Gen.run([])

        assert_file "lib/live_view_native_native.ex", fn file ->
          assert file =~ "LiveViewNativeNative"
        end
      end
    end

    test "will raise with message if any arguments are given", config do
      in_tmp_live_project config.test, fn ->
        assert_raise(Mix.Error, fn() ->
          Gen.run(["gameboy"])
        end)

        refute_file "lib/live_view_native_native.ex"
      end
    end
  end

  describe "when an umbrella app" do
    test "generates the `Native` module into the project's lib directory", config do
      in_tmp_live_umbrella_project config.test, fn ->
        Gen.run([])

        assert_file "lib/live_view_native_native.ex", fn file ->
          assert file =~ "LiveViewNativeNative"
        end
      end
    end

    test "will raise with message if any arguments are given", config do
      in_tmp_live_umbrella_project config.test, fn ->
        assert_raise(Mix.Error, fn() ->
          Gen.run(["gameboy"])
        end)

        refute_file "lib/live_view_native_native.ex"
      end
    end
  end

  describe "Gettext support" do
    test "is available by default", config do
      in_tmp_live_project config.test, fn ->
        Gen.run([])

        assert_file "lib/live_view_native_native.ex", fn file ->
          assert file =~ "Gettext"
        end
      end
    end

    test "can be turned off via a switch", config do
      in_tmp_live_project config.test, fn ->
        Gen.run(["--no-gettext"])

        assert_file "lib/live_view_native_native.ex", fn file ->
          refute file =~ "Gettext"
        end
      end
    end
  end
end
