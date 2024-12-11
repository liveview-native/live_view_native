defmodule LiveViewNative.LVNTemplateTest do
  use ExUnit.Case, async: true

  defmacrop compile(string) do
    quote do
      unquote(
        EEx.compile_string(string,
          file: __ENV__.file,
          engine: LiveViewNative.TagEngine,
          module: __MODULE__,
          caller: __CALLER__,
          source: string,
          tag_handler: LiveViewNative.TagEngine
        )
      )
      |> Phoenix.HTML.Safe.to_iodata()
      |> IO.iodata_to_binary()
    end
  end

  describe ":interface- attr" do
    test "will conditionally render if interface value matches" do
      assigns = %{_interface: %{"target" => "mobile"}}

      assert compile("""
               <Text :interface-target="mobile" id="test">yes</Text>
             """) =~ "<Text id=\"test\">yes</Text>"

      refute compile("""
              <Text :interface-target="watch" id="test">yes</Text>
            """) =~ "<Text id=\"test\">yes</Text>"
    end
  end
end
