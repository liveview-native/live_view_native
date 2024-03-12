Mix.Project.deps_paths[:phx_new]
|> Path.join("test/mix_helper.exs")
|> Code.require_file()

defmodule Mix.Lvn.TestHelper do
  import MixHelper, except: [
    assert_file: 1,
    assert_file: 2,
    refute_file: 1
  ]

  defdelegate assert_file(file), to: MixHelper
  defdelegate assert_file(file, match), to: MixHelper
  defdelegate refute_file(file), to: MixHelper

  def in_tmp_live_project(test, func) do
    in_tmp_project(test, fn ->
      File.mkdir_p!("lib")
      File.touch!("lib/live_view_native_web.ex")
      File.touch!("lib/live_view_native.ex")
      func.()
    end)
  end

  def in_tmp_live_umbrella_project(test, func) do
    in_tmp_umbrella_project(test, fn ->
      File.mkdir_p!("live_view_native/lib")
      File.mkdir_p!("live_view_native_web/lib")
      File.touch!("live_view_native/lib/live_view_native.ex")
      File.touch!("live_view_native_web/lib/live_view_native_web.ex")
      func.()
    end)
  end
end
