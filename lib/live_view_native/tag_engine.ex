defmodule LiveViewNative.TagEngine do
  @behaviour Phoenix.LiveView.TagEngine

  def classify_type(":" <> name), do: {:slot, String.to_atom(name)}
  def classify_type(":inner_block"), do: {:error, "the slot name :inner_block is reserved"}

  def classify_type(<<first, _::binary>> = name) when first in ?A..?Z,
    do: {:remote_component, String.to_atom(name)}

  def classify_type("." <> name),
    do: {:local_component, String.to_atom(name)}

  def classify_type(name), do: {:tag, name}

  def void?(_), do: false
end
