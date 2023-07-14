defmodule LiveViewNative.NativeBindingTest do
  use ExUnit.Case

  alias LiveViewNative.TestLiveViewBindings

  test "native bindings are discovered" do
    Code.ensure_compiled(LiveViewNative.TestLiveViewBindings)

    assert TestLiveViewBindings.__native_bindings__() == %{
      binding_1: {:string, [default: "hello, world"]},
      binding_2: {:float, [default: 42.5]},
      binding_3: {LiveViewNative.CustomBindingType, []},
      binding_4: {LiveViewNative.CustomStringBindingType, [default: "cast this"]}
    }
  end

  test "custom binding types cast" do
    Code.ensure_compiled(LiveViewNative.TestLiveViewBindings)

    assert LiveViewNative.Extensions.Bindings.cast_native_bindings(
      [test: {"a", "b"}],
      %{ test: {LiveViewNative.CustomBindingType, []} }
    ) == %{ test: %LiveViewNative.CustomBindingType{ a: "a", b: "b" } }
  end

  test "custom binding types load" do
    assert LiveViewNative.Extensions.Bindings.load_native_bindings(
      %{ "test" => %{ "a" => "a", "b" => "b" } },
      %{ test: {LiveViewNative.CustomBindingType, []} }
    ) == [test: %LiveViewNative.CustomBindingType{ a: "a", b: "b" }]
  end

  test "string type cast" do
    Code.ensure_compiled(LiveViewNative.TestLiveViewBindings)

    assert LiveViewNative.Extensions.Bindings.cast_native_bindings(
      [test: "value"],
      %{ test: {LiveViewNative.CustomStringBindingType, []} }
    ) == %{ test: "value" }
  end

  test "string type load" do
    assert LiveViewNative.Extensions.Bindings.load_native_bindings(
      %{ "test" => "value" },
      %{ test: {LiveViewNative.CustomStringBindingType, []} }
    ) == [test: "value"]
  end
end
