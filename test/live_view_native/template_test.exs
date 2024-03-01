defmodule LiveViewNative.TemplateTest do
  use ExUnit.Case, async: false
  import LiveViewNative.Component, only: [sigil_LVN: 2]

  describe "value embedding" do
    test "can embed values with EEx statement" do
      assigns = %{foo: "bar"}

      assert ~LVN"""
      <Foo><%= @foo %></Foo>
      """
      |> render() =~ ~S(<Foo>bar</Foo>)
    end

    test "can embed values from maps" do
      data = %{"foo" => "bar"}
      assigns = %{data: data}

      assert ~LVN"""
      <Foo><%= @data["foo"] %></Foo>
      """
      |> render() =~ ~S(<Foo>bar</Foo>)
    end
  end

  describe "attributes" do
    test "won't stringify attribute names" do
      assigns = %{}

      assert ~LVN"""
      <Foo foo_bar="123" />
      """
      |> render() =~ ~S(<Foo foo_bar="123"></Foo>)
    end

    test "accepts string values" do
      assigns = %{}

      assert ~LVN"""
      <Foo foo={"bar"} />
      """
      |> render() =~ ~S(<Foo foo="bar"></Foo>)
    end

    test "accepts values from maps" do
      assigns = %{}

      assert ~LVN"""
      <Foo foo={%{"foo" => "bar"}["foo"]} />
      """
      |> render() =~ ~S(<Foo foo="bar"></Foo>)
    end

    test "accepts values from lists" do
      assigns = %{}

      assert ~LVN"""
      <Foo foo={[foo: "bar"][:foo]} />
      """
      |> render() =~ ~S(<Foo foo="bar"></Foo>)
    end

    test "accepts numbers for id" do
      assigns = %{}

      assert ~LVN"""
      <Foo id={123} />
      """
      |> render() =~ ~S(<Foo id="123"></Foo>)
    end

    test "accepts false for a value and doesn't drop the attribute" do
      assigns = %{}

      assert ~LVN"""
      <Foo bar={false}/>
      """
      |> render() =~ ~S(<Foo bar="false"></Foo>)
    end

    test "json encode maps" do
      assigns = %{}

      assert ~LVN"""
      <Foo data={%{a: 1}} b="asf" c={123} />
      """
      |> render() =~ ~S(<Foo data="{\"a\":1}" b="asf" c="123"></Foo>)
    end

    test "json encode list" do
      assigns = %{}

      assert ~LVN"""
        <Foo data={[1, 2, 3]}/>
        """
        |> render() =~ ~S(<Foo data="[1,2,3]"></Foo>)
    end
  end

  describe "tag name" do
    test "accepts camelCased tag names" do
      assigns = %{}

      assert ~LVN"""
      <FooBar/>
      """
      |> render() =~ "<FooBar></FooBar>"
    end
  end

  def render(template) do
    template
    |> LiveViewNative.Template.Safe.to_iodata()
    |> IO.iodata_to_binary()
  end
end
