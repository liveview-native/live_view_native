Mix.Project.deps_paths[:phx_new]
|> Path.join("test/mix_helper.exs")
|> Code.require_file()

defmodule Mix.Tasks.Lvn.GenTest do
  use ExUnit.Case
  import MixHelper
  alias Mix.Tasks.Lvn.Gen

  setup do
    Mix.Task.clear()
    :ok
  end

  defp in_tmp_live_project(test, func) do
    in_tmp_project(test, fn ->
      File.mkdir_p!("lib")
      File.touch!("lib/phoenix_web.ex")
      File.touch!("lib/phoenix.ex")
      func.()
    end)
  end

  defp in_tmp_live_umbrella_project(test, func) do
    in_tmp_umbrella_project(test, fn ->
      File.mkdir_p!("phoenix/lib")
      File.mkdir_p!("phoenix_web/lib")
      File.touch!("phoenix/lib/phoenix.ex")
      File.touch!("phoenix_web/lib/phoenix_web.ex")
      func.()
    end)
  end

  test "generates the `Native` module into the project's lib directory", config do
    in_tmp_live_project config.test, fn ->
      Gen.run([])
      assert_file "lib/live_view_native_native.ex", fn file ->
        assert file =~ "LiveViewNativeNative"
      end
    end
  end
end
