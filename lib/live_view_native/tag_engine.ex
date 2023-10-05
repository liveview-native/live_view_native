defmodule LiveViewNative.TagEngine do
  @moduledoc """
  An implementation of `Phoenix.LiveView.TagEngine` that omits
  HTML-centric template rules.
  """

  @behaviour Phoenix.LiveView.TagEngine
  @phoenix_live_view_vsn Application.spec(:phoenix_live_view, :vsn) |> to_string()

  def classify_type(":inner_block"), do: {:error, "the slot name :inner_block is reserved"}
  def classify_type(":" <> name), do: {:slot, format_type(name, @phoenix_live_view_vsn)}

  def classify_type(<<first, _::binary>> = name) when first in ?A..?Z do
    if String.contains?(name, ".") do
      {:remote_component, format_type(name, @phoenix_live_view_vsn)}
    else
      {:tag, format_type(name, @phoenix_live_view_vsn)}
    end
  end

  def classify_type("." <> name),
    do: {:local_component, format_type(name, @phoenix_live_view_vsn)}

  def classify_type(name), do: {:tag, format_type(name, @phoenix_live_view_vsn)}

  def void?(_), do: false

  ###

  # `phoenix_live_view` 0.19 changed the `classify_type/1` callback
  # to return a string instead of an atom. This conditional should
  # be removed once `phoenix_live_view` 0.18 is no longer supported.
  defp format_type(name, "0.18." <> _patch_vsn), do: String.to_atom(name)
  defp format_type(name, _phoenix_live_view_vsn), do: name
end
