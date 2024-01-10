defmodule LiveViewNative.Engine do
  # @behaviour Phoenix.Template.Engine

  # @impl true
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
      tag_handler: tag_handler_lookup(path),
      annotate_tagged_content: debug_annotations? && (&Phoenix.LiveView.HTMLEngine.annotate_tagged_content/1)
    )
  end

  defp tag_handler_lookup(path) do
    {format, _target} =
      path
      |> Path.basename()
      |> String.split(".")
      |> Enum.at(1)
      |> String.split("+", parts: 2)
      |> case do
        [format] -> {format, nil}
        [format, target] -> {format, target}
      end

    case LiveViewNative.fetch_plugin(format) do
      {:ok, plugin} -> plugin.tag_handler
      :error ->
        IO.warn("could not find the LiveViewNative plugin for #{inspect(format)}")
    end
  end

  def annotate_tagged_content(%Macro.Env{} = caller) do
    %Macro.Env{module: mod, function: {func, _}, file: file, line: line} = caller
    line = if line == 0, do: 1, else: line
    file = Path.relative_to_cwd(file)

    before = "<#{inspect(mod)}.#{func}> #{file}:#{line}"
    aft = "</#{inspect(mod)}.#{func}>"
    {"<!-- #{before} -->", "<!-- #{aft} -->"}
  end
end