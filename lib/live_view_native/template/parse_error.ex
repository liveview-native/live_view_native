defmodule LiveViewNative.Template.ParseError do
  defexception [:message]

  @impl true
  def exception({document, message, [start: cursor, end: cursor]}) do
    msg = """
    #{message}

    #{document_line(document, cursor)}
    """

    %__MODULE__{message: msg}
  end

  def exception({document, message, [start: start_cursor, end: end_cursor]}) do
    msg = """
    #{message}

    Start:
    #{document_line(document, start_cursor)}

    End:
    #{document_line(document, end_cursor)}
    """

    %__MODULE__{message: msg}
  end

  defp document_line(document, [line: line, column: column]) do
    doc_line =
      document
      |> String.split("\n")
      |> Enum.at(line - 1)

    loc = "#{line}: "

    ~s|#{loc}#{doc_line}\n#{String.duplicate(" ", String.length(loc))}#{String.pad_leading("^", column, "-")}|
  end
end
