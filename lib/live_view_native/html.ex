defmodule LiveViewNative.HTML do
  def format, do: :html
  def module_suffix, do: :HTML
  def tag_handler, do: nil
  def component, do: LiveViewNative.HTML.Component
end