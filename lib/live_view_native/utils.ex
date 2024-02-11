defmodule LiveViewNative.Utils do
  @moduledoc false
  alias Phoenix.LiveView.Socket

  def get_format(%Socket{private: %{connect_info: %{private: %{phoenix_format: format}}}}), do: format
  def get_format(%Socket{private: %{connect_params: %{"_format" => format}}}), do: format
  def get_format(_socket), do: "html"

  def get_interface(%{socket: %Socket{private: %{connect_info: %{params: %{"_interface" => interface}}}}}), do: interface
  def get_interface(%{conn: %Plug.Conn{params: %{"_interface" => interface}}}), do: interface
  def get_interface(_socket), do: %{}

  def stringify_format(format) when is_binary(format), do: format
  def stringify_format(format) when is_atom(format), do: Atom.to_string(format)

  def normalize_layouts(layouts) do
    Enum.map(layouts, fn
      {format, {mod, template}} -> {format, {mod, template}}
      {format, mod} -> {format, {mod, :app}}
    end)
  end
end
