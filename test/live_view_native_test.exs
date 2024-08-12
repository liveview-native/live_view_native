defmodule LiveViewNative.Test do
  use ExUnit.Case

  alias LiveViewNativeTest.{GameBoy, Switch}

  test "fetch_plugin/1" do
    {:ok, plugin} = LiveViewNative.fetch_plugin(:gameboy)
    assert plugin.format == :gameboy

    {:ok, plugin} = LiveViewNative.fetch_plugin(:switch)
    assert plugin.format == :switch

    assert LiveViewNative.fetch_plugin(:other) == :error
  end

  test "fetch_plugin!/1" do
    plugin = LiveViewNative.fetch_plugin!(:gameboy)
    assert plugin.format == :gameboy

    plugin = LiveViewNative.fetch_plugin!(:switch)
    assert plugin.format == :switch

    assert_raise LiveViewNative.PluginError, fn ->
      LiveViewNative.fetch_plugin!(:other)
    end
  end

  test "plugins/0" do
    plugins = LiveViewNative.plugins()

    assert %GameBoy{} = plugins["gameboy"]
    assert %Switch{} = plugins["switch"]
  end

  test "available_formats/0" do
    formats = LiveViewNative.available_formats()

    assert Enum.member?(formats, :gameboy)
    assert Enum.member?(formats, :switch)
  end
end
