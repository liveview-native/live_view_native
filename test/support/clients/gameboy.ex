defmodule LiveViewNativeTest.GameBoy do
  @behaviour LiveViewNative

  @impl true
  def format, do: :gameboy

  @impl true
  def module_suffix, do: :GameBoy

  @impl true
  def template_engine, do: LiveViewNative.Engine

  @impl true
  def tag_handler(_target), do: LiveViewNative.TagEngine

  @impl true
  def component, do: LiveViewNativeTest.GameBoy.Component
end