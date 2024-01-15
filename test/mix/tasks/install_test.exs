defmodule Mix.Tasks.Lvn.InstallTest do
  use ExUnit.Case
  doctest Mix.Tasks.Lvn.Install

  # infer_app_name broke on commit d6a3036e9ce32d309e1bd4438b64b13487e81e19
  # when it started to return an atom instead of a string.
  test "infer_app_name _ valid namespace" do
    assert Mix.Tasks.Lvn.Install.infer_app_namespace("mix.exs") == "LiveViewNative"
  end

  test "infer_app_name _ invalid namespace" do
    assert_raise RuntimeError,
                 "Could not infer Mix project namespace from mix.exs. Please provide it manually using the --namespace argument.",
                 fn ->
                   Mix.Tasks.Lvn.Install.infer_app_namespace("invalid namespace")
                 end
  end
end
