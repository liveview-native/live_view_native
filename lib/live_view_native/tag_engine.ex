defmodule LiveViewNative.TagEngine do
  @moduledoc """
  An implementation of `Phoenix.LiveView.TagEngine` that omits
  HTML-centric template rules.
  """

  @behaviour Phoenix.LiveView.TagEngine

  def classify_type(":inner_block"), do: {:error, "the slot name :inner_block is reserved"}
  def classify_type(":" <> name), do: {:slot, String.to_atom(name)}

  def classify_type(<<first, _::binary>> = name) when first in ?A..?Z do
    if String.contains?(name, ".") do
      {:remote_component, String.to_atom(name)}
    else
      {:tag, name}
    end
  end

  def classify_type("." <> name),
    do: {:local_component, String.to_atom(name)}

  def classify_type(name), do: {:tag, name}

  def void?(_), do: false
end
