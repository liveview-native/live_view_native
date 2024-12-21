defmodule LiveViewNativeTest.Switch.TestClient do
  @moduledoc false

  defstruct tags: %{
    form: "LiveForm",
    button: "Button",
    upload_input: "Input",
    changeables: ~w(Input LiveForm)
  }
end
