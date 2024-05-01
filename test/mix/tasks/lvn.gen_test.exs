defmodule Mix.Tasks.Lvn.GenTest do
  use ExUnit.Case

  import Mix.Lvn.TestHelper

  alias Mix.Tasks.Lvn.Gen

  setup do
    Mix.Task.clear()
    :ok
  end

  describe "when a single app" do
    test "generates the `Native` module into the project's lib directory", config do
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
        File.cd!("live_view_native_web", fn ->
          Gen.run([])
          assert_file "lib/live_view_native_native.ex", fn file ->
            assert file =~ "LiveViewNativeNative"
          end
        end)
      end
    end

    test "will raise with message if any arguments are given", config do
      in_tmp_live_umbrella_project config.test, fn ->
        File.cd!("live_view_native_web", fn ->
          assert_raise(Mix.Error, fn() ->
            Gen.run(["gameboy"])
          end)
          refute_file "lib/live_view_native_native.ex"
        end)
      end
    end
  end
end
