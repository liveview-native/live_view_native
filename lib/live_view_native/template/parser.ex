defmodule LiveViewNative.Template.Parser do
  @moduledoc ~S'''
  Floki-compliant parser for LiveView Native template syntax

      iex> """
      ...> <Group>
      ...>   <Text class="bold">Hello</Text>
      ...>   <Text>world!</Text>
      ...> </Group>
      ...> """
      ...> |> LiveViewNative.Template.Parser.parse_document()
      {:ok, [{"Group", [], [{"Text", [{"class", "bold"}], ["Hello"]}, {"Text", [], ["world!"]}]}]}

  You can pass this AST into Floki for querying:

      iex> """
      ...> <Group>
      ...>   <Text class="bold">Hello</Text>"
      ...>   <Text>world!</Text>
      ...> </Group>
      ...> """
      ...> |> LiveViewNative.Template.Parser.parse_document!()
      ...> |> Floki.find("Text.bold")
      [{"Text", [{"class", "bold"}], ["Hello"]}]

  ## Floki Integration

  Floki support passing parser in by option, this parser is compliant with that API:

      iex> """
      ...> <Group>
      ...>   <Text class="bold">Hello</Text>"
      ...>   <Text>world!</Text>
      ...> </Group>
      ...> """
      ...> |> Floki.parse_document!(html_parser: LiveViewNative.Template.Parser)
      ...> |> Floki.find("Text.bold")
      [{"Text", [{"class", "bold"}], ["Hello"]}]

  Or you can configure as the default:

  ```elixir
  config :floki, :html_parser, LiveViewNative.Tempalte.Parser
  ```
  '''

  alias LiveViewNative.Template.ParseError

  @first_chars ~c"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
  @chars ~c"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-"
  @attribute_key @chars ++ ~c":"
  @whitespace ~c"\s\t\n\r"
  @entities [
    {?<, "&lt;"},
    {?>, "&gt;"},
    {?&, "&amp;"},
    {?", "&quot;"},
    {?', "&#39;"}
  ]

  @doc """
  Parses an LVN document from a string.

  This is the main function to get a tree from a LVN string.

  ## Options

    * `:attributes_as_maps` - Change the behaviour of the parser to return the attributes
      as maps, instead of a list of `{"key", "value"}`. Default to `false`.

  ## Examples

      iex> LiveViewNative.Template.Parser.parse_document("<Group><Text></Text><Text>Hello</Text></Group>")
      {:ok, [{"Group", [], [{"Text", [], []}, {"Text", [], ["Hello"]}]}]}

      iex> LiveViewNative.Template.Parser.parse_document(
      ...>   ~S(<Group><Text></Text><Text class="main">Hello</Text></Group>),
      ...>   attributes_as_maps: true
      ...>)
      {:ok, [{"Group", %{}, [{"Text", %{}, []}, {"Text", %{"class" => "main"}, ["Hello"]}]}]}
  """
  def parse_document(document, args \\ []) do
    parse(document, [line: 1, column: 1], [], args)
    |> case do
      {:ok, {_document, nodes, _cursor}} -> {:ok, nodes}
      error -> error
    end
  end

  @doc """
  Parses a LVN Document from a string.

  Similar to `parse_document/1`, but raises `LiveViewNative.Template.ParseError` if there was an
  error parsing the document.

  ## Example

      iex> LiveViewNative.Template.Parser.parse_document!("<Group><Text></Text><Text>hello</Text></Group>")
      [{"Group", [], [{"Text", [], []}, {"Text", [], ["hello"]}]}]

  """
  def parse_document!(document, args \\ []) do
    case parse_document(document, args) do
      {:ok, nodes} -> nodes
      {:error, message, range} -> raise ParseError, {document, message, range}
    end
  end

  defp parse(<<>>, cursor, nodes, _args),
    do: {:ok, {"", Enum.reverse(nodes), cursor}}

  # these next two functions are special escape function that are only used to detect
  # the start of an end tag and eject from parsing children
  defp parse(<<"</", _document::binary>> = document, cursor, nodes, _args) do
    {:ok, {document, Enum.reverse(nodes), cursor}}
  end

  defp parse(<<"/>", _document::binary>> = document, cursor, nodes, _args) do
    {:ok, {document, Enum.reverse(nodes), cursor}}
  end

  defp parse(<<"<!--", document::binary>>, cursor, nodes, args) do
    cursor = move_cursor(cursor, ~c"<!--")

    parse_comment_node(document, cursor, [], args)
    |> case do
      {:ok, {document, node, cursor}} -> parse(document, cursor, [node | nodes], args)
      error -> error
    end
  end

  defp parse(<<"<!doctype ", document::binary>>, cursor, [], args) do
    cursor = move_cursor(cursor, ~c"<!doctype ")

    ignore_doctype(document, cursor, args)
    |> case do
      {:ok, {document, cursor}} -> parse(document, cursor, [], args)
      error -> error
    end
  end

  defp parse(<<"<!DOCTYPE ", document::binary>>, cursor, [], args) do
    cursor = move_cursor(cursor, ~c"<!DOCTYPE ")

    ignore_doctype(document, cursor, args)
    |> case do
      {:ok, {document, cursor}} -> parse(document, cursor, [], args)
      error -> error
    end
  end

  defp parse(<<"<", document::binary>>, cursor, nodes, args) do
    cursor = move_cursor(cursor, ?<)

    parse_node(document, cursor, args)
    |> case do
      {:ok, {document, node, cursor}} -> parse(document, cursor, [node | nodes], args)
      error -> error
    end
  end

  defp parse(document, cursor, nodes, args) do
    parse_text_node(document, cursor, [], args)
    |> case do
      {:ok, {document, text_node, cursor}} ->
        if String.trim(text_node) == "" do
          parse(document, cursor, nodes, args)
        else
          parse(document, cursor, [text_node | nodes], args)
        end
      error -> error
    end
  end

  defp ignore_doctype(<<">", document::binary>>, cursor, _args) do
    cursor = move_cursor(cursor, ?>)
    {:ok, {document, cursor}}
  end

  defp ignore_doctype(<<char::utf8, document::binary>>, cursor, args) when char in @chars do
    cursor = move_cursor(cursor, char)
    ignore_doctype(document, cursor, args)
  end

  defp parse_text_node(<<"<", _document::binary>> = document, cursor, buffer, args) do
    return_text_node(document, cursor, buffer, args)
  end

  defp parse_text_node(<<>>, cursor, buffer, args) do
    return_text_node("", cursor, buffer, args)
  end

  for {char, entity} <- @entities do
    defp parse_text_node(<<unquote(entity), document::binary>>, cursor, buffer, args) do
      parse_text_node(document, move_cursor(cursor, unquote(entity)), [buffer, unquote(char)], args)
    end
  end

  defp parse_text_node(<<char::utf8, document::binary>>, cursor, buffer, args) do
    parse_text_node(document, move_cursor(cursor, char), [buffer, char], args)
  end

  defp return_text_node(document, cursor, buffer, _args) do
    text_node = List.to_string(buffer)

    {:ok, {document, text_node, cursor}}
  end

  defp parse_comment_node(<<>>, cursor, _buffer, _args) do
    {:error, "unexpected end of file within comment", [start: cursor, end: cursor]}
  end

  defp parse_comment_node(<<"-->", document::binary>>, cursor, buffer, _args) do
    cursor = move_cursor(cursor, ~c"-->")

    comment = List.to_string(buffer)

    {:ok, {document, {:comment, comment}, cursor}}
  end

  defp parse_comment_node(<<char, document::binary>>, cursor, buffer, args) do
    parse_comment_node(document, cursor, [buffer, char], args)
  end

  defp parse_node(document, cursor = start_cursor, args) do
    with {:ok, {document, tag_name, cursor}} <- parse_tag_name(document, cursor, [], args),
      {:ok, {document, attributes, cursor}} <- parse_attributes(document, cursor, [], args),
      {:ok, {document, cursor}} <- parse_tag_close(document, cursor, start_cursor, args),
      {:ok, {document, children, cursor}} <- parse_children(document, cursor, args),
      {:ok, {document, cursor}} <- parse_end_tag(document, cursor, [], tag_name, start_cursor, args) do
        {:ok, {document, {tag_name, attributes, children}, cursor}}
    else
      {:error, message, range} -> {:error, message, range}
    end
  end

  defp parse_tag_name(<<>>, cursor, _buffer, _args) do
    {:error, "unexpected end of file while parsing attribute key", [start: cursor, end: cursor]}
  end

  defp parse_tag_name(<<char::utf8, document::binary>>, cursor, [], args) when char in @first_chars do
    cursor = move_cursor(cursor, char)
    parse_tag_name(document, cursor, [char], args)
  end

  defp parse_tag_name(<<char::utf8, document::binary>>, cursor, buffer, args) when char in @chars do
    cursor = move_cursor(cursor, char)
    parse_tag_name(document, cursor, [buffer, char], args)
  end

  defp parse_tag_name(<<"/>", _document::binary>> = document, cursor, buffer, args),
    do: return_tag_name(document, buffer, cursor, args)
  defp parse_tag_name(<<">", _document::binary>> = document, cursor, buffer, args),
    do: return_tag_name(document, buffer, cursor, args)
  defp parse_tag_name(<<char, _document::binary>> = document, cursor, buffer, args) when char in @whitespace do
    return_tag_name(document, buffer, cursor, args)
  end

  defp parse_tag_name(<<char, _document::binary>>, cursor, _buffer, _args) do
    {:error, "invalid character in tag name: #{[char]}", [start: cursor, end: cursor]}
  end

  defp return_tag_name(document, buffer, cursor, _args) do
    tag_name = List.to_string(buffer)

    {:ok, {document, tag_name, cursor}}
  end

  defp parse_attributes(<<char, document::binary>>, cursor, buffer, args) when char in @whitespace do
    cursor = move_cursor(cursor, char)
    parse_attributes(document, cursor, buffer, args)
  end

  defp parse_attributes(<<"/>", _document::binary>> = document, cursor, buffer, args) do
    return_attributes(document, buffer, cursor, args)
  end

  defp parse_attributes(<<">", _document::binary>> = document, cursor, buffer, args) do
    return_attributes(document, buffer, cursor, args)
  end

  defp parse_attributes(document, cursor, buffer, args) do
    case parse_attribute(document, cursor, args) do
      {:ok, {document, attribute, cursor}} -> parse_attributes(document, cursor, [attribute | buffer], args)
      error -> error
    end
  end

  defp parse_attribute(document, cursor, args) do
    with {:ok, {document, key, cursor}} <- parse_attribute_key(document, cursor, [], args),
      {:ok, {document, cursor}} <- parse_attribute_assignment(document, cursor, key, args),
      {:ok, {document, value, cursor}} <- parse_attribute_value(document, cursor, nil, nil, args) do
        {:ok, {document, {key, value}, cursor}}
    else
      {:boolean, {document, key, cursor}} -> {:ok, {document, {key, key}, cursor}}
      error -> error
    end
  end

  defp return_attributes(document, buffer, cursor, args) do
    attributes = if Keyword.get(args, :attributes_as_maps, false) do
      Enum.into(buffer, %{})
    else
      Enum.reverse(buffer)
    end
    {:ok, {document, attributes, cursor}}
  end

  defp parse_attribute_key(<<char, document::binary>>, cursor, [], args) when char in @whitespace do
    parse_attribute_key(document, move_cursor(cursor, char), [], args)
  end

  defp parse_attribute_key(<<char, document::binary>>, cursor, [], args) when char in @first_chars do
    parse_attribute_key(document, move_cursor(cursor, char), [char], args)
  end

  defp parse_attribute_key(<<char, _document::binary>> = document, cursor, key_buffer, _args) when char not in @attribute_key do
    key = List.to_string(key_buffer)

    {:ok, {document, key, cursor}}
  end

  defp parse_attribute_key(<<char, document::binary>>, cursor, key_buffer, args) when char in @attribute_key do
    parse_attribute_key(document, move_cursor(cursor, char), [key_buffer, char], args)
  end

  defp parse_attribute_key(<<>>, cursor, _buffer, _args) do
    {:error, "unexpected end of file while parsing attribute key", [start: cursor, end: cursor]}
  end

  defp parse_attribute_key(<<char, _document::binary>>, cursor, _buffer, _args) do
    {:error, "invalid character in attribute key: #{[char]}", [start: cursor, end: cursor]}
  end

  defp parse_attribute_assignment(<<char, document::binary>>, cursor, key, args) when char in @whitespace do
    parse_attribute_assignment(document, move_cursor(cursor, char), key, args)
  end

  defp parse_attribute_assignment(<<"=", document::binary>>, cursor, _key, _args) do
    {:ok, {document, move_cursor(cursor, ?=)}}
  end

  defp parse_attribute_assignment(<<char, _document::binary>> = document, cursor, key, _args) when char in @first_chars do
    {:boolean, {document, key, cursor}}
  end

  defp parse_attribute_assignment(<<char, _document::binary>>, cursor, key, _args) do
    {:error, "invalid character: #{[char]} in attribute key: #{key}", [start: cursor, end: cursor]}
  end

  defp parse_attribute_value(<<>>, cursor, _buffer, _closing_char, _args) do
    {:error, "unexpected end of file while parsing attribute value", [start: cursor, end: cursor]}
  end

  defp parse_attribute_value(<<"\"\"", document::binary>>, cursor, nil, nil, _args) do
    {:ok, {document, "", move_cursor(cursor, ~c'""')}}
  end

  defp parse_attribute_value(<<"''", document::binary>>, cursor, nil, nil, _args) do
    {:ok, {document, "", move_cursor(cursor, ~c'""')}}
  end

  defp parse_attribute_value(<<"\"", char, document::binary>>, cursor, nil, nil, args) do
    parse_attribute_value(to_string([char]) <> document, move_cursor(cursor, ?"), [], ?", args)
  end

  defp parse_attribute_value(<<"'", char, document::binary>>, cursor, nil, nil, args) do
    parse_attribute_value(to_string([char]) <> document, move_cursor(cursor, ?"), [], ?', args)
  end

  defp parse_attribute_value(<<char, document::binary>>, cursor, nil, nil, args) when char in @whitespace do
    parse_attribute_value(document, move_cursor(cursor, char), nil, nil, args)
  end

  defp parse_attribute_value(<<_char, _document::binary>>, cursor, nil, nil, _args) do
    {:error, "value must be wrapped by \" quotes", [start: cursor, end: cursor]}
  end

  defp parse_attribute_value(<<"\"", document::binary>>, cursor, buffer, ?", _args) do
    value = List.to_string(buffer)

    {:ok, {document, value, move_cursor(cursor, ?")}}
  end

  defp parse_attribute_value(<<"'", document::binary>>, cursor, buffer, ?', _args) do
    value = List.to_string(buffer)

    {:ok, {document, value, move_cursor(cursor, ?')}}
  end

  defp parse_attribute_value(_document, cursor, nil, _closing_char, _args) do
    {:error, "invalid value format for attribute", [start: cursor, end: cursor]}
  end

  for {char, entity} <- @entities do
    defp parse_attribute_value(<<unquote(entity), document::binary>>, cursor, buffer, closing_char, args) do
      parse_attribute_value(document, move_cursor(cursor, unquote(entity)), [buffer, unquote(char)], closing_char, args)
    end
  end

  defp parse_attribute_value(<<char::utf8, document::binary>>, cursor, buffer, closing_char, args) do
    parse_attribute_value(document, move_cursor(cursor, char), [buffer, char], closing_char, args)
  end

  defp parse_tag_close(<<">", document::binary>>, cursor, _start_cursor, _args) do
    {:ok, {document, move_cursor(cursor, ?>)}}
  end

  defp parse_tag_close(<<"/>", _document::binary>> = document, cursor, _start_cursor, _args) do
    {:ok, {document, cursor}}
  end

  defp parse_tag_close(_document, cursor, start_cursor, _args) do
    {:error, "tag entity not closed", [start: start_cursor, end: cursor]}
  end

  defp parse_children(document, cursor, args) do
    case parse(document, cursor, [], args) do
      {:ok, {"", _nodes, cursor}} -> {:error, "unexpected end of file", [start: cursor, end: cursor]}
      result -> result
    end
  end

  defp parse_end_tag(<<"</", document::binary>>, cursor, buffer, tag_name, start_cursor, args) do
    cursor = move_cursor(cursor, ~c"</")
    {document, cursor} = drain_whitespace(document, cursor)
    parse_end_tag(document, cursor, buffer, tag_name, start_cursor, args)
  end

  defp parse_end_tag(<<char, document::binary>>, cursor, [], tag_name, start_cursor, args) when char in @first_chars do
    parse_end_tag(document, move_cursor(cursor, char), [char], tag_name, start_cursor, args)
  end

  defp parse_end_tag(<<char, document::binary>>, cursor, buffer, tag_name, start_cursor, args) when char in @chars do
    parse_end_tag(document, move_cursor(cursor, char), [buffer, char], tag_name, start_cursor, args)
  end

  defp parse_end_tag(document, cursor, [], _tag_name, _start_cursor, _args) do
    case document do
      <<">", document::binary>> -> {:ok, {document, move_cursor(cursor, ?>)}}
      <<"/>", document::binary>> -> {:ok, {document, move_cursor(cursor, ~c"/>")}}
      _document -> {:error, "invalid character for end tag", [start: cursor, end: cursor]}
    end
  end

  defp parse_end_tag(document, end_cursor, buffer, tag_name, start_cursor, args) do
    {document, cursor} = drain_whitespace(document, end_cursor)

    closing_tag_name = List.to_string(buffer)

    if tag_name != closing_tag_name do
      {:error, "starting tagname does not match closing tagname", [start: start_cursor, end: end_cursor]}
    else
      parse_end_tag(document, cursor, [], tag_name, start_cursor, args)
    end
  end

  defp drain_whitespace(<<char, document::binary>>, cursor) when char in @whitespace do
    drain_whitespace(document, move_cursor(cursor, char))
  end

  defp drain_whitespace(document, cursor),
    do: {document, cursor}

  defp move_cursor(cursor, chars) when is_list(chars),
    do: Enum.reduce(chars, cursor, &move_cursor(&2, &1))

  defp move_cursor(cursor, char) when char in [?\n],
    do: [line: cursor[:line] + 1, column: 1]

  defp move_cursor(cursor, _char),
    do: [line: cursor[:line], column: cursor[:column] + 1]
end
