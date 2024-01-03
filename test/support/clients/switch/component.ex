defmodule LiveViewNativeTest.Switch.Component do
  defmacro __using__(_) do
    quote do
      LiveViewNative.Component.embed_sigil([], LiveViewNativeTest.Switch)
    end
  end
end