defmodule LiveViewNative.TagEngineTest do
  use ExUnit.Case

  alias LiveViewNative.TagEngine

  describe "classify_type/1" do
    test "it returns a slot tuple when name starts with a colon" do
      assert TagEngine.classify_type(":custom_tag") == {:slot, :custom_tag}
    end

    test "it returns an error tuple when name is :inner_block" do
      assert TagEngine.classify_type(":inner_block") == {:error, "the slot name :inner_block is reserved"}
    end

    test "it returns a remote component tuple when name is a capitalized string (module name with function)" do
      assert TagEngine.classify_type("Foo.Bar.baz") == {:remote_component, :"Foo.Bar.baz"}
    end

    test "it returns a local component tuple when name starts with a period (local function)" do
      assert TagEngine.classify_type(".qux") == {:local_component, :qux}
    end

    test "it returns all other tagas as they are" do
      assert TagEngine.classify_type("test") == {:tag, "test"}
    end
  end

  describe "void?/1" do
    test "it returns false for all self-closing HTML tags" do
      for void <- ~w(area base br col hr img input link meta param command keygen source) do
        refute TagEngine.void?(void)
      end
    end
  end
end
