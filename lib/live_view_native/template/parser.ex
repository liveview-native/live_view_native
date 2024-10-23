defmodule LiveViewNative.Template.Parser do
  @first_chars ~c"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
  @chars ~c"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-"
  @whitespace ~c"\s\t\n\r"

  def parse_document(document) do
    parse(document, [line: 1, column: 1], [])
    |> case do
      {:ok, {_document, nodes, _cursor}} -> {:ok, nodes}
      error -> error
    end
  end

  def parse_document!(document) do
    case parse_document(document) do
      {:ok, {nodes, _cursor}} -> nodes
      {:error, message, _range} -> raise message
    end
  end

  defp parse(<<>>, cursor, nodes),
    do: {:ok, {"", Enum.reverse(nodes), cursor}}

  # these next two functions are special escape function that are only used to detect
  # the start of an end tag and eject from parsing children
  defp parse(<<"</", _document::binary>> = document, cursor, nodes) do
    {:ok, {document, Enum.reverse(nodes), cursor}}
  end

  defp parse(<<"/>", _document::binary>> = document, cursor, nodes) do
    {:ok, {document, Enum.reverse(nodes), cursor}}
  end

  defp parse(<<"<!--", document::binary>>, cursor, nodes) do
    cursor = incr_column(cursor, 4)

    parse_comment_node(document, cursor, [])
    |> case do
      {:ok, {document, node, cursor}} -> parse(document, cursor, [node | nodes])
      error -> error
    end
  end

  defp parse(<<"<", document::binary>>, cursor, nodes) do
    cursor = incr_column(cursor)

    parse_node(document, cursor)
    |> case do
      {:ok, {document, node, cursor}} -> parse(document, cursor, [node | nodes])
      error -> error
    end
  end

  defp parse(document, cursor, nodes) do
    parse_text_node(document, cursor, [])
    |> case do
      {:ok, {document, text_node, cursor}} ->
        if String.trim(text_node) == "" do
          parse(document, cursor, nodes)
        else
          parse(document, cursor, [text_node | nodes])
        end
      error -> error
    end
  end

  defp parse_text_node(<<"<", _document::binary>> = document, cursor, buffer) do
    return_text_node(document, cursor, buffer)
  end

  defp parse_text_node(<<>>, cursor, buffer) do
    return_text_node("", cursor, buffer)
  end

  defp parse_text_node(<<char, document::binary>>, cursor, buffer) do
    parse_text_node(document, move_cursor(cursor, char), [char | buffer])
  end

  defp return_text_node(document, cursor, buffer) do
    text_node =
      buffer
      |> Enum.reverse()
      |> List.to_string()

    {:ok, {document, text_node, cursor}}
  end

  defp parse_comment_node(<<>>, cursor, _buffer) do
    {:error, "unexpected end of file within comment", [start: cursor, end: cursor]}
  end

  defp parse_comment_node(<<"-->", document::binary>>, cursor, buffer) do
    cursor = incr_column(cursor, 3)

    comment =
      buffer
      |> Enum.reverse()
      |> List.to_string()

    {:ok, {document, [comment: comment], cursor}}
  end

  defp parse_comment_node(<<char, document::binary>>, cursor, buffer) do
    parse_comment_node(document, cursor, [char | buffer])
  end

  defp parse_node(document, cursor = start_cursor) do
    with {:ok, {document, tag_name, cursor}} <- parse_tag_name(document, cursor, []),
      {:ok, {document, attributes, cursor}} <- parse_attributes(document, cursor, []),
      {:ok, {document, cursor}} <- parse_tag_close(document, cursor, start_cursor),
      {:ok, {document, children, cursor}} <- parse_children(document, cursor),
      {:ok, {document, cursor}} <- parse_end_tag(document, cursor, [], tag_name, start_cursor) do
        {:ok, {document, {tag_name, attributes, children}, cursor}}
    else
      {:error, message, range} -> {:error, message, range}
    end
  end

  defp parse_tag_name(<<>>, cursor, _buffer) do
    {:error, "unexpected end of file while parsing attribute key", [start: cursor, end: cursor]}
  end

  defp parse_tag_name(<<char, document::binary>>, cursor, []) when char in @first_chars do
    cursor = incr_column(cursor)
    parse_tag_name(document, cursor, [char])
  end

  defp parse_tag_name(<<char, document::binary>>, cursor, buffer) when char in @chars do
    cursor = incr_column(cursor)
    parse_tag_name(document, cursor, [char | buffer])
  end

  defp parse_tag_name(<<"/>", _document::binary>> = document, cursor, buffer),
    do: return_tag_name(document, buffer, cursor)
  defp parse_tag_name(<<">", _document::binary>> = document, cursor, buffer),
    do: return_tag_name(document, buffer, cursor)
  defp parse_tag_name(<<char, _document::binary>> = document, cursor, buffer) when char in @whitespace do
    return_tag_name(document, buffer, cursor)
  end

  defp parse_tag_name(<<char, _document::binary>>, cursor, _buffer) do
    {:error, "invalid character in tag name: #{[char]}", [start: cursor, end: cursor]}
  end

  defp return_tag_name(document, buffer, cursor) do
    tag_name =
      buffer
      |> Enum.reverse()
      |> List.to_string()

    {:ok, {document, tag_name, cursor}}
  end

  defp parse_attributes(<<char, document::binary>>, cursor, buffer) when char in @whitespace do
    cursor = move_cursor(cursor, char)
    parse_attributes(document, cursor, buffer)
  end

  defp parse_attributes(<<"/>", _document::binary>> = document, cursor, buffer) do
    attributes = Enum.reverse(buffer)
    {:ok, {document, attributes, cursor}}
  end

  defp parse_attributes(<<">", _document::binary>> = document, cursor, buffer) do
    attributes = Enum.reverse(buffer)
    {:ok, {document, attributes, cursor}}
  end

  defp parse_attributes(document, cursor, buffer) do
    case parse_attribute(document, cursor) do
      {:ok, {document, attribute, cursor}} -> parse_attributes(document, cursor, [attribute | buffer])
      error -> error
    end
  end

  defp parse_attribute(document, cursor) do
    with {:ok, {document, key, cursor}} <- parse_attribute_key(document, cursor, []),
      {:ok, {document, value, cursor}} <- parse_attribute_value(document, cursor, []) do
        {:ok, {document, {key, value}, cursor}}
    else
      error -> error
    end
  end

  defp parse_attribute_key(<<char, document::binary>>, cursor, buffer) when char in @whitespace do
    cursor = move_cursor(cursor, char)
    parse_attribute_key(document, cursor, buffer)
  end

  defp parse_attribute_key(<<char, document::binary>>, cursor, []) when char in @first_chars do
    parse_attribute_key(document, incr_column(cursor), [char])
  end

  defp parse_attribute_key(<<char, document::binary>>, cursor, key_buffer) when char in @chars do
    parse_attribute_key(document, incr_column(cursor), [char | key_buffer])
  end

  defp parse_attribute_key(<<"=", document::binary>>, cursor, key_buffer) do
    key =
      key_buffer
      |> Enum.reverse()
      |> List.to_string()

    {document, cursor} = drain_whitespace(document, incr_column(cursor))

    {:ok, {document, key, cursor}}
  end

  defp parse_attribute_key(<<>>, cursor, _buffer) do
    {:error, "unexpected end of file while parsing attribute key", [start: cursor, end: cursor]}
  end

  defp parse_attribute_key(<<char, _document::binary>>, cursor, _buffer) do
    {:error, "invalid character in attribute key: #{[char]}", [start: cursor, end: cursor]}
  end

  defp parse_attribute_value(<<>>, cursor, _buffer) do
    {:error, "unexpected end of file while parsing attribute value", [start: cursor, end: cursor]}
  end

  defp parse_attribute_value(<<"\"\"", document::binary>>, cursor, []) do
    cursor = incr_column(cursor, 2)
    {:ok, {document, "", cursor}}
  end

  defp parse_attribute_value(<<"\"", char, document::binary>>, cursor, []) do
    cursor =
      cursor
      |> incr_column()
      |> move_cursor(char)

    parse_attribute_value(document, cursor, [char])
  end

  defp parse_attribute_value(<<"\"", document::binary>>, cursor, buffer) do
    value =
      buffer
      |> Enum.reverse()
      |> List.to_string()

    {:ok, {document, value, incr_column(cursor)}}
  end

  defp parse_attribute_value(_document, cursor, []) do
    {:error, "invalid value format for attribute", [start: cursor, end: cursor]}
  end

  defp parse_attribute_value(<<char, document::binary>>, cursor, buffer) do
    cursor = move_cursor(cursor, char)
    parse_attribute_value(document, cursor, [char | buffer])
  end

  defp parse_tag_close(<<">", document::binary>>, cursor, _start_cursor) do
    {:ok, {document, incr_column(cursor)}}
  end

  defp parse_tag_close(<<"/>", _document::binary>> = document, cursor, _start_cursor) do
    {:ok, {document, cursor}}
  end

  defp parse_tag_close(_document, cursor, start_cursor) do
    {:error, "tag entity not closed", [start: start_cursor, end: cursor]}
  end

  defp parse_children(document, cursor) do
    case parse(document, cursor, []) do
      {:ok, {"", _nodes, cursor}} -> {:error, "unexpected end of file", [start: cursor, end: cursor]}
      result -> result
    end
  end

  defp parse_end_tag(<<"</", document::binary>>, cursor, buffer, tag_name, start_cursor) do
    cursor = incr_column(cursor, 2)
    {document, cursor} = drain_whitespace(document, cursor)
    parse_end_tag(document, cursor, buffer, tag_name, start_cursor)
  end

  defp parse_end_tag(<<char, document::binary>>, cursor, [], tag_name, start_cursor) when char in @first_chars do
    cursor = incr_column(cursor)
    parse_end_tag(document, cursor, [char], tag_name, start_cursor)
  end

  defp parse_end_tag(<<char, document::binary>>, cursor, buffer, tag_name, start_cursor) when char in @chars do
    cursor = incr_column(cursor)
    parse_end_tag(document, cursor, [char | buffer], tag_name, start_cursor)
  end

  defp parse_end_tag(document, cursor, [], _tag_name, _start_cursor) do
    case document do
      <<">", document::binary>> -> {:ok, {document, incr_column(cursor)}}
      <<"/>", document::binary>> -> {:ok, {document, incr_column(cursor, 2)}}
      _document -> {:error, "invalid character for end tag", [start: cursor, end: cursor]}
    end
  end

  defp parse_end_tag(document, end_cursor, buffer, tag_name, start_cursor) do
    {document, cursor} = drain_whitespace(document, end_cursor)

    closing_tag_name =
      buffer
      |> Enum.reverse()
      |> List.to_string()

    if tag_name != closing_tag_name do
      {:error, "starting tagname does not match closing tagname", [start: start_cursor, end: end_cursor]}
    else
      parse_end_tag(document, cursor, [], tag_name, start_cursor)
    end
  end

  defp drain_whitespace(<<char, document::binary>>, cursor) when char in @whitespace do
    drain_whitespace(document, move_cursor(cursor, char))
  end

  defp drain_whitespace(document, cursor),
    do: {document, cursor}

  defp move_cursor(cursor, char) when char in [?\n] do
    incr_line(cursor)
  end
  defp move_cursor(cursor, _char),
    do: incr_column(cursor)

  defp incr_column([line: line, column: column], count \\ 1),
    do: [line: line, column: column + count]

  defp incr_line([line: line, column: _column], count \\ 1) do
    [line: line + count, column: 1]
  end
end
