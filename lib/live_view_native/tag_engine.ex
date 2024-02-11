defmodule LiveViewNative.TagEngine do
  @moduledoc """
  An implementation of `Phoenix.LiveView.TagEngine` that omits
  HTML-centric template rules.

  For more information on TagEngine please see `Phoenix.LiveView.TagEngine`
  """

  @behaviour Phoenix.LiveView.TagEngine

  @doc false
  def classify_type(":inner_block"), do: {:error, "the slot name :inner_block is reserved"}
  def classify_type(":" <> name), do: {:slot, name}

  def classify_type(<<first, _::binary>> = name) when first in ?A..?Z do
    if String.contains?(name, ".") do
      {:remote_component, name}
    else
      {:tag, name}
    end
  end

  def classify_type("." <> name),
    do: {:local_component, name}

  def classify_type(name), do: {:tag, name}

  @doc false
  def void?(_), do: false
end
