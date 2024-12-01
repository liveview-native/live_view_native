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

  def stringify(value) when is_binary(value), do: value
  def stringify(value) when is_atom(value), do: Atom.to_string(value)
  def stringify(value) when is_integer(value), do: Integer.to_string(value)
  def stringify(value) when is_float(value), do: Float.to_string(value)

  def normalize_layouts(nil),
    do: []

  def normalize_layouts(layouts) do
    Enum.map(layouts, fn
      {format, {mod, template}} -> {format, {mod, template}}
      {format, mod} -> {format, {mod, :app}}
    end)
  end
end
