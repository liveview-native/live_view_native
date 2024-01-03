defmodule LiveViewNativeTest.GameBoy.Component do
  defmacro __using__(_) do
    quote do
      LiveViewNative.Component.embed_sigil([], LiveViewNativeTest.GameBoy)
    end
  end
end