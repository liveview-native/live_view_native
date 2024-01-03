defmodule LiveViewNativeTest.Switch do
  @behaviour LiveViewNative

  @impl true
  def format, do: :switch

  @impl true
  def module_suffix, do: :Switch

  @impl true
  def template_engine, do: LiveViewNative.Engine

  @impl true
  def tag_handler(_target), do: LiveViewNative.TagEngine

  @impl true
  def component, do: LiveViewNativeTest.Switch.Component
end