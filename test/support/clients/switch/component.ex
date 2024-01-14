defmodule LiveViewNativeTest.Switch.Component do
  defmacro __using__(_) do
    quote do
      import LiveViewNative.Component, only: [sigil_LVN: 2]
    end
  end
end