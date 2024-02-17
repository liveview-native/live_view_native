defmodule LiveViewNative.Engine do
  @moduledoc """
  The LiveViewNative.Engine that powers `.neex` templates and the `~LVN` sigil.

  It works by adding a LiveView Native template parsing and validation layer on top
  of `Phoenix.LiveView.TagEngine`.
  """

  @behaviour Phoenix.Template.Engine

  @impl true
  def compile(path, _name) do
    quote do
      require LiveViewNative.Engine
      LiveViewNative.Engine.compile(unquote(path))
    end
  end

  @doc false
  defmacro compile(path) do
    trim = Application.get_env(:phoenix, :trim_on_html_eex_engine, true)
    debug_annotations? = Module.get_attribute(__CALLER__.module, :__debug_annotations__)
    source = File.read!(path)

    EEx.compile_string(source,
      engine: Phoenix.LiveView.TagEngine,
      line: 1,
      file: path,
      trim: trim,
      caller: __CALLER__,
      source: source,
      tag_handler: LiveViewNative.TagEngine,
      annotate_tagged_content: debug_annotations? && (&annotate_tagged_content/1)
    )
  end

    @doc """
  Encodes the HTML templates to iodata.
  """
  def encode_to_iodata!({:safe, body}), do: body
  def encode_to_iodata!(nil), do: ""
  def encode_to_iodata!(bin) when is_binary(bin), do: Phoenix.HTML.Engine.html_escape(bin)
  def encode_to_iodata!(list) when is_list(list), do: LiveViewNative.Template.Safe.List.to_iodata(list)
  def encode_to_iodata!(other), do: LiveViewNative.Template.Safe.to_iodata(other)

  @doc false
  def annotate_tagged_content(%Macro.Env{} = caller) do
    %Macro.Env{module: mod, function: {func, _}, file: file, line: line} = caller
    line = if line == 0, do: 1, else: line
    file = Path.relative_to_cwd(file)

    before = "<#{inspect(mod)}.#{func}> #{file}:#{line}"
    aft = "</#{inspect(mod)}.#{func}>"
    {"<!-- #{before} -->", "<!-- #{aft} -->"}
  end
end
