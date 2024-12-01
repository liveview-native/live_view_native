defmodule LiveViewNative.Template.ParserTest do
  use ExUnit.Case, async: false
  import LiveViewNative.Template.Parser

  alias LiveViewNative.Template.ParseError

  doctest LiveViewNative.Template.Parser

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

  test "will parse boolean attribute" do
    {:ok, nodes} = """
    <FooBar a="1" b c="true"/>
    """
    |> parse_document()

    assert nodes == [
      {"FooBar", [{"a", "1"}, {"b", "b"}, {"c", "true"}], []}
    ]
  end

  test "will parse attributes as a map" do
    {:ok, nodes} = """
    <FooBar a="123" b="321"   c =   "789"></FooBar>
    <FooBar a-b="456" a-b="789"></FooBar>
    <FooBar
      a = "987"
      b-c="654"
      ></FooBar>
    """
    |> parse_document(attributes_as_maps: true)

    assert nodes == [
      {"FooBar", %{"a" => "123", "b" => "321", "c" => "789"}, []},
      {"FooBar", %{"a-b" => "456"}, []},
      {"FooBar", %{"a" => "987", "b-c" => "654"}, []}
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

  test "will encode attriubte values" do
    {:ok, nodes} = """
    <FooBar baz="&lt;&gt;&amp;&quot;&#39;">&lt;&gt;&amp;&quot;&#39;</FooBar>
    """
    |> parse_document()

    assert nodes == [
      {"FooBar", [{"baz", "<>&\"'"}], ["<>&\"'"]}
    ]
  end

  test "empty" do
    {:ok, nodes} = parse_document("")

    assert nodes == []
  end

  test "will parse utf8 characters from text nodes and attribute nodes" do
    {:ok, nodes} = """
    <FooBar baz="a–b">a–b</FooBar>
    """
    |> parse_document()

    assert nodes == [
      {"FooBar", [{"baz", "a–b"}], ["a–b"]}
    ]
  end

  describe "parsing errors" do
    test "eof within a comment" do
      doc = "<!--"
      {:error, _message, [start: start_pos, end: end_pos]} = parse_document(doc)

      assert start_pos == end_pos
      assert start_pos == [line: 1, column: 5]

      assert_raise ParseError, fn ->
        parse_document!(doc)
      end
    end

    test "invalid tag name character" do
      doc = "<FooBar!></FooBar!>"
      {:error, _message, [start: start_pos, end: end_pos]} = parse_document(doc)

      assert start_pos == end_pos
      assert start_pos == [line: 1, column: 8]

      assert_raise ParseError, fn ->
        parse_document!(doc)
      end
    end

    test "eof during tag name parsing" do
      doc = "<FooBar"
      {:error, _message, [start: start_pos, end: end_pos]} = parse_document(doc)

      assert start_pos == end_pos
      assert start_pos == [line: 1, column: 8]

      assert_raise ParseError, fn ->
        parse_document!(doc)
      end
    end

    test "invalid attribute key name" do
      doc = """
        <FooBar
          a-*b="123"></FooBar>
        """
      {:error, _message, [start: start_pos, end: end_pos]} = parse_document(doc)

      assert start_pos == end_pos
      assert start_pos == [line: 2, column: 5]

      assert_raise ParseError, fn ->
        parse_document!(doc)
      end
    end

    test "eof during attribute key parsing" do
      doc = "<FooBar a"
      {:error, _message, [start: start_pos, end: end_pos]} = parse_document(doc)

      assert start_pos == end_pos
      assert start_pos == [line: 1, column: 10]

      assert_raise ParseError, fn ->
        parse_document!(doc)
      end
    end

     test "eof during attribute value parsing" do
       doc = "<FooBar a="
       {:error, _message, [start: start_pos, end: end_pos]} = parse_document(doc)

       assert start_pos == end_pos
       assert start_pos == [line: 1, column: 11]

       assert_raise ParseError, fn ->
         parse_document!(doc)
       end
     end

     test "catches parsing errors with invalid value format for attribute" do
       doc = "<FooBar a=></FooBar>"
       {:error, _message, [start: start_pos, end: end_pos]} = parse_document(doc)

       assert start_pos == end_pos
       assert start_pos == [line: 1, column: 11]

       assert_raise ParseError, fn ->
         parse_document!(doc)
       end
     end

     test "catches errors with not closing tag entity propery" do
       doc = "<FooBar <Baz/>"
       {:error, _message, [start: start_pos, end: end_pos]} = parse_document(doc)

       assert start_pos == end_pos
       assert start_pos == [line: 1, column: 9]

       assert_raise ParseError, fn ->
         parse_document!(doc)
       end
     end

     test "eof while parsing tag entity" do
       doc = ~s(<FooBar a="123")
       {:error, _message, [start: start_pos, end: end_pos]} = parse_document(doc)

       assert start_pos == end_pos
       assert start_pos == [line: 1, column: 16]

       assert_raise ParseError, fn ->
         parse_document!(doc)
       end
     end

     test "eof while parsing children" do
       doc = "<FooBar>"
       {:error, _message, [start: start_pos, end: end_pos]} = parse_document(doc)

       assert start_pos == end_pos
       assert start_pos == [line: 1, column: 9]

       assert_raise ParseError, fn ->
         parse_document!(doc)
       end
     end
  end
end
