defmodule LiveViewNativeTest.Utils do
  def render(template) do
    template
    |> Phoenix.HTML.Safe.to_iodata()
    |> IO.iodata_to_binary()
  end
end