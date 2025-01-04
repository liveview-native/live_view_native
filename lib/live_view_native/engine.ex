defmodule LiveViewNative.Engine do
  @moduledoc """
  The LiveViewNative.Engine that powers `.neex` templates and the `~LVN` sigil.

  It works by adding a LiveView Native template parsing and validation layer on top
  of `Phoenix.LiveView.TagEngine`.
  """

  @behaviour Phoenix.Template.Engine

  @impl true
  def compile(path, name) do
    IO.warn("""
    LiveViewNative.Engine has been deprecatd in favor of LiveViewNative.Template.Engine.
    In config/config.exs update config :phoenix, :template_engines

      - neex: LiveViewNative.Engine
      + neex: LiveViewNative.Template.Engine
    """)

    LiveViewNative.Template.Engine.compile(path, name)
  end

  @doc """
  Encodes the HTML templates to iodata.
  """
  def encode_to_iodata!({:safe, body}), do: body
  def encode_to_iodata!(nil), do: ""
  def encode_to_iodata!(bin) when is_binary(bin), do: Phoenix.HTML.Engine.html_escape(bin)
  def encode_to_iodata!(list) when is_list(list), do: LiveViewNative.Template.Safe.List.to_iodata(list)
  def encode_to_iodata!(other), do: LiveViewNative.Template.Safe.to_iodata(other)
end
