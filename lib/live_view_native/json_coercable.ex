defprotocol LiveViewNative.JSONCoercable do
  @type json_value ::
          atom()
          | boolean()
          | nil
          | String.t()
          | integer()
          | float()
          | %{(atom() | String.t()) => json_value()}
          | [json_value()]

  @spec to_json(term()) :: json_value()
  def to_json(value)

  @spec from_json(json_value()) :: term()
  def from_json(json_value)
end

alias LiveViewNative.JSONCoercable

defimpl JSONCoercable, for: Any do
  defmacro __deriving__(module, struct, fields) do
    quote location: :keep do
      defimpl JSONCoercable, for: unquote(module) do
        def to_json(value) do
          Enum.reduce(unquote(fields), %{}, fn {field, type}, acc ->
            json_value =
              value
              |> Map.get(field)
              |> JSONCoercable.to_json()

            Map.put(acc, field, json_value)
          end)
        end

        def from_json(json_value) when is_map(json_value) do
          Enum.reduce(unquote(fields), unquote(Macro.escape(struct)), fn {field, type}, acc ->
            value =
              Map.get_lazy(json_value, field, fn -> Map.get(json_value, Atom.to_string(field)) end)
              # need to concat to get the impl module ourselves, since protocol dispatch won't work with the json value type
              |> Module.concat(JSONCoercable, type).from_json()

            Map.put(acc, field, value)
          end)
        end

        def from_json(json_value) do
          raise ArgumentError,
                "cannot coerce struct #{unquote(module)} from non-map value: #{inspect(json_value)}"
        end
      end
    end
  end

  def to_json(value) do
    raise Protocol.UndefinedError,
      protocol: @protocol,
      value: value,
      description: "JSONCoercable must be explicitly implemented"
  end

  def from_json(json_value) do
    raise Protocol.UndefinedError,
      protocol: @protocol,
      json_value: json_value,
      description: "JSONCoercable must be explicitly implemented"
  end
end

defimpl JSONCoercable, for: Atom do
  def to_json(v) when v in [nil, false, true], do: v

  def to_json(value), do: Atom.to_string(value)

  def from_json(v) when v in [nil, false, true], do: v

  def from_json(json_value) when is_binary(json_value), do: String.to_existing_atom(json_value)
end

# binaries dispatch to BitString, but implement for String, so you can specify `String` in a coercable type
defimpl JSONCoercable, for: String do
  def to_json(value), do: value
  def from_json(json_value) when is_binary(json_value), do: json_value
end

# binaries dispatch to BitString, so implement it for that too, but limited to binaries
defimpl JSONCoercable, for: BitString do
  def to_json(value) when is_binary(value), do: value
  def from_json(json_value) when is_binary(json_value), do: json_value
end

defimpl JSONCoercable, for: Integer do
  def to_json(value), do: value
  def from_json(json_value) when is_integer(json_value), do: json_value
end

defimpl JSONCoercable, for: Float do
  def to_json(value), do: value
  def from_json(json_value) when is_float(json_value), do: json_value
  def from_json(json_value) when is_integer(json_value), do: json_value * 1.0
end

defimpl JSONCoercable, for: Map do
  def to_json(value) do
    Map.new(value, fn {k, v} -> {k, JSONCoercable.to_json(v)} end)
  end

  def from_json(json_value) when is_map(json_value) do
    # pass through values directly, since we don't have any info about the value type
    # this means that round-tripping a map through JSONCoercable may produce a map with different values
    json_value
  end
end

defimpl JSONCoercable, for: List do
  def to_json(value) do
    Enum.map(value, &JSONCoercable.to_json/1)
  end

  def from_json(json_value) when is_list(json_value) do
    # pass through values directly, same as with Map
    json_value
  end
end
