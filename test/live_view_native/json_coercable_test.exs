defmodule LiveViewNative.JSONCoercableTest do
  use ExUnit.Case
  alias LiveViewNative.JSONCoercable
  import JSONCoercable

  defmodule Point do
    @derive {JSONCoercable, [x: Integer, y: Integer]}
    defstruct x: 0, y: 0
  end

  defmodule Nested do
    @derive {JSONCoercable, [point: Point, string: String]}
    defstruct point: %Point{x: 0, y: 0}, string: ""
  end

  defp coerce_to(type, json_value) do
    Module.concat(JSONCoercable, type).from_json(json_value)
  end

  test "coerces primitive types to json" do
    assert to_json(:hello) == "hello"
    assert to_json(false) == false
    assert to_json(nil) == nil
    assert to_json("world") == "world"
    assert to_json(123) == 123
    assert to_json(42.0) == 42.0
    assert to_json(%{foo: 123, bar: :baz}) == %{foo: 123, bar: "baz"}
    assert to_json([:hello]) == ["hello"]
  end

  test "coerces primitive types from json" do
    assert coerce_to(Atom, "hello") == :hello
    assert coerce_to(Atom, false) == false
    assert coerce_to(Atom, nil) == nil
    assert coerce_to(String, "world") == "world"
    assert coerce_to(Integer, 123) == 123
    assert coerce_to(Float, 42.0) == 42.0
    assert coerce_to(Map, %{"foo" => 123}) == %{"foo" => 123}
    assert coerce_to(List, ["hello"]) == ["hello"]
  end

  test "coerces simple structs" do
    assert to_json(%Point{x: 1, y: 2}) == %{x: 1, y: 2}
    assert coerce_to(Point, %{"x" => 1, "y" => 2}) == %Point{x: 1, y: 2}
  end

  test "coerces nested types" do
    assert to_json(%Nested{point: %Point{x: 3, y: 4}, string: "hello"}) == %{
             point: %{x: 3, y: 4},
             string: "hello"
           }

    assert coerce_to(Nested, %{"point" => %{"x" => 3, "y" => 4}, "string" => "hello"}) == %Nested{
             point: %Point{x: 3, y: 4},
             string: "hello"
           }
  end
end
