defprotocol LiveViewNative.Template.Safe do
  @moduledoc """
  Defines the LVN Template safe protocol.

  This protocol relies on iodata, which provides
  better performance when sending or streaming data to the client.
  """

  def to_iodata(data)
end

defimpl LiveViewNative.Template.Safe, for: [List, Map] do
  def to_iodata(data) do
    data
    |> Jason.encode!()
    |> Phoenix.HTML.Engine.html_escape()
  end
end

defimpl LiveViewNative.Template.Safe, for: Atom do
  def to_iodata(nil), do: ""
  def to_iodata(atom), do: Phoenix.HTML.Engine.html_escape(Atom.to_string(atom))
end

defimpl LiveViewNative.Template.Safe, for: BitString do
  defdelegate to_iodata(data), to: Phoenix.HTML, as: :html_escape
end

defimpl LiveViewNative.Template.Safe, for: Time do
  defdelegate to_iodata(data), to: Time, as: :to_iso8601
end

defimpl LiveViewNative.Template.Safe, for: Date do
  defdelegate to_iodata(data), to: Date, as: :to_iso8601
end

defimpl LiveViewNative.Template.Safe, for: NaiveDateTime do
  defdelegate to_iodata(data), to: NaiveDateTime, as: :to_iso8601
end

defimpl LiveViewNative.Template.Safe, for: DateTime do
  def to_iodata(data) do
    # Call escape in case someone can inject reserved
    # characters in the timezone or its abbreviation
    Phoenix.HTML.Engine.html_escape(DateTime.to_iso8601(data))
  end
end

defimpl LiveViewNative.Template.Safe, for: Integer do
  defdelegate to_iodata(data), to: Integer, as: :to_string
end

defimpl LiveViewNative.Template.Safe, for: Float do
  defdelegate to_iodata(data), to: Float, as: :to_string
end

defimpl LiveViewNative.Template.Safe, for: Tuple do
  def to_iodata({:safe, data}), do: data
  def to_iodata(value), do: raise(Protocol.UndefinedError, protocol: @protocol, value: value)
end

defimpl LiveViewNative.Template.Safe, for: URI do
  def to_iodata(data), do: Phoenix.HTML.Engine.html_escape(URI.to_string(data))
end

defimpl LiveViewNative.Template.Safe, for: Phoenix.LiveView.Rendered do
  def to_iodata(%Phoenix.LiveView.Rendered{static: static, dynamic: dynamic}) do
    to_iodata(static, dynamic.(false), [])
  end

  def to_iodata(%_{} = struct) do
    LiveViewNative.Template.Safe.to_iodata(struct)
  end

  def to_iodata(nil) do
    raise "cannot convert .heex/.leex template with change tracking to iodata"
  end

  def to_iodata(other) do
    other
  end

  defp to_iodata([static_head | static_tail], [dynamic_head | dynamic_tail], acc) do
    to_iodata(static_tail, dynamic_tail, [to_iodata(dynamic_head), static_head | acc])
  end

  defp to_iodata([static_head], [], acc) do
    Enum.reverse([static_head | acc])
  end
end
