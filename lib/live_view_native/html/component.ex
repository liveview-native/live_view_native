defmodule LiveViewNative.HTML.Component do
  defmacro __using__(_opts) do
    quote do
      import Phoenix.Component, only: [sigil_H: 2]
    end
  end
end