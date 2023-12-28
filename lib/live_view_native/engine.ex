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
    source = File.read!(path)

    EEx.compile_string(source,
      engine: Phoenix.LiveView.TagEngine,
      line: 1,
      file: path,
      trim: true,
      caller: __CALLER__,
      source: source,
      tag_handler: tag_handler_lookup(path)
    )
  end

  defp tag_handler_lookup(path) do
    {format, target} =
      path
      |> Path.basename()
      |> String.split(".")
      |> Enum.at(1)
      |> String.split("+", parts: 2)
      |> case do
        [format] -> {format, nil}
        [format, target] -> {format, target}
      end

    plugin = LiveViewNative.plugin_for(format)
    plugin.tag_handler(target)
  end
end