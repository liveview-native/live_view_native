defmodule LiveViewNative.Utils do
  @moduledoc false

  def get_format(%{:_format => format}),
    do: format
  def get_format(_assigns),
    do: "html"

  def get_interface(%{:_interface => interface}),
    do: interface
  def get_interface(_session),
    do: %{}

  def stringify_format(format) when is_binary(format), do: format
  def stringify_format(format) when is_atom(format), do: Atom.to_string(format)

  def normalize_layouts(nil),
    do: []

  def normalize_layouts(layouts) do
    Enum.map(layouts, fn
      {format, {mod, template}} -> {format, {mod, template}}
      {format, mod} -> {format, {mod, :app}}
    end)
  end
end
