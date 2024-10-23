defmodule LiveViewNative.Template.ParserTest do
  use ExUnit.Case, async: false
  import LiveViewNative.Template.Parser

  test "will parse a tag" do
    {:ok, nodes} = """
    <FooBar></FooBar>
    <FooBar> </FooBar>
    <FooBar>
    </FooBar>
    """
    |> parse_document()

    assert nodes == [
      {"FooBar", [], []},
      {"FooBar", [], []},
      {"FooBar", [], []}
    ]
  end

  test "will parse a self-closing tags" do
    {:ok, nodes} = """
    <FooBar/>
    <FooBar />
    """
    |> parse_document()

    assert nodes == [
      {"FooBar", [], []},
      {"FooBar", [], []}
    ]
  end

  test "will parse attributes" do
    {:ok, nodes} = """
    <FooBar a="123" b="321"   c =   "789"></FooBar>
    <FooBar a-b="456"></FooBar>
    <FooBar
      a = "987"
      b-c="654"
      ></FooBar>
    """
    |> parse_document()

    assert nodes == [
      {"FooBar", [{"a", "123"}, {"b", "321"}, {"c", "789"}], []},
      {"FooBar", [{"a-b", "456"}], []},
      {"FooBar", [{"a", "987"}, {"b-c", "654"}], []}
    ]
  end

  test "will parse children" do
    {:ok, nodes} = """
    <Foo>  <Bar><Baz></Baz></Bar><Qux/></Foo>
    <Foo> a b <Bar/> c</Foo>
    """
    |> parse_document()

    assert nodes == [
      {"Foo", [], [
        {"Bar", [], [
          {"Baz", [], []}
        ]},
        {"Qux", [], []}
      ]},
      {"Foo", [], [
        " a b ",
        {"Bar", [], []},
        " c"
      ]}
    ]
  end

  test "can parse comments" do
    {:ok, nodes} = """
    <FooBar></FooBar>
    <!-- <FooBar></FooBar>
    <FooBar/>
    -->

    <FooBar>
      <!-- <FooBar/> -->
    </FooBar>
    """
    |> parse_document()

    assert nodes == [
      {"FooBar", [], []},
      [comment: " <FooBar></FooBar>\n<FooBar/>\n"],
      {"FooBar", [], [
        [comment: " <FooBar/> "]
      ]}
    ]
  end

  test "empty" do
    {:ok, nodes} = parse_document("")

    assert nodes == []
  end

  describe "parsing errors" do
    test "eof within a comment" do
      {:error, _message, [start: start_pos, end: end_pos]} = "<!--"
      |> parse_document()

      assert start_pos == end_pos
      assert start_pos == [line: 1, column: 5]
    end

    test "invalid tag name character" do
      {:error, _message, [start: start_pos, end: end_pos]} = """
      <FooBar!></FooBar!>
      """
      |> parse_document()

      assert start_pos == end_pos
      assert start_pos == [line: 1, column: 8]
    end

    test "eof during tag name parsing" do
      {:error, _message, [start: start_pos, end: end_pos]} = "<FooBar"
      |> parse_document()

      assert start_pos == end_pos
      assert start_pos == [line: 1, column: 8]
    end

    test "invalid attribute key name" do
      {:error, _message, [start: start_pos, end: end_pos]} = """
      <FooBar
        a-*b="123"></FooBar>
      """
      |> parse_document()

      assert start_pos == end_pos
      assert start_pos == [line: 2, column: 5]
    end

    test "eof during attribute key parsing" do
      {:error, _message, [start: start_pos, end: end_pos]} = """
      <FooBar a
      """
      |> parse_document()

      assert start_pos == end_pos
      assert start_pos == [line: 2, column: 1]
    end

     test "eof during attribute value parsing" do
       {:error, _message, [start: start_pos, end: end_pos]} = """
       <FooBar a="
       """
       |> parse_document()

       assert start_pos == end_pos
       assert start_pos == [line: 2, column: 1]
     end

     test "catches parsing errors with invalid value format for attribute" do
       {:error, _message, [start: start_pos, end: end_pos]} = """
       <FooBar a=
       """
       |> parse_document()

       assert start_pos == end_pos
       assert start_pos == [line: 2, column: 1]
     end

     test "catches errors with not closing tag entity propery" do
       {:error, _message, [start: start_pos, end: end_pos]} = """
       <FooBar <Baz/>
       """
       |> parse_document()

       assert start_pos == end_pos
       assert start_pos == [line: 1, column: 9]
     end

     test "eof while parsing tag entity" do
       {:error, _message, [start: start_pos, end: end_pos]} = "<FooBar a=\"123\""
       |> parse_document()

       assert start_pos == end_pos
       assert start_pos == [line: 1, column: 16]
     end

     test "eof while parsing children" do
       {:error, _message, [start: start_pos, end: end_pos]} = """
       <FooBar>
       """
       |> parse_document()

       assert start_pos == end_pos
       assert start_pos == [line: 2, column: 1]
     end
  end
end
