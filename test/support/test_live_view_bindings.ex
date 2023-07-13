defmodule LiveViewNative.TestLiveViewBindings do
  use LiveViewNative.Extensions.Bindings

  native_binding :binding_1, :string, default: "hello, world"
  native_binding :binding_2, :float, default: 42.5
  native_binding :binding_3, LiveViewNative.CustomBindingType
  native_binding :binding_4, LiveViewNative.CustomStringBindingType, default: "cast this"
end

defmodule LiveViewNative.CustomBindingType do
  @derive Jason.Encoder
  defstruct [:a, :b]

  use Ecto.Type
  def type, do: :map

  def load(map), do: struct(__MODULE__, for {key, value} <- map, into: %{} do
    {String.to_existing_atom(key), value}
  end)
  def dump(_), do: :error

  def cast({a, b}), do: {:ok, %__MODULE__{ a: a, b: b }}
  def cast(_), do: :error
end

defmodule LiveViewNative.CustomStringBindingType do
  use Ecto.Type
  def type, do: :string

  def load(string), do: string
  def dump(_), do: :error

  def cast(value) when is_bitstring(value), do: {:ok, value}
  def cast(_), do: :error
end
