defmodule LiveViewNative.TagEngine do
  @behaviour Phoenix.LiveView.TagEngine

  @impl true
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

  @impl true
  def preprocess_tokens(tokens) do
    Enum.map(tokens, &expand_template_attributes/1)
  end

  @impl true
  def void?(_), do: false

  ###
  defp expand_template_attributes({:tag, element, [_ | _] = attrs, metadata}) do
    {:tag, element, Enum.map(attrs, &expand_template_attribute/1), metadata}
  end

  defp expand_template_attributes(token), do: token

  defp expand_template_attribute({attr_name, nil, metadata} = attr) do
    if String.starts_with?(attr_name, "#") do
      template_name = String.replace_leading(attr_name, "#", ":")

      {"template", {:expr, template_name, metadata}, metadata}
    else
      attr
    end
  end

  defp expand_template_attribute(attr), do: attr
end
