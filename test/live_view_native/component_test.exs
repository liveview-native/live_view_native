defmodule LiveViewNativeTest.ComponentTest do
  use ExUnit.Case
  import LiveViewNativeTest.Utils, only: [render: 1]

  alias Phoenix.LiveView.Socket
  alias LiveViewNativeTest.{HomeLive}

  setup do
    {:ok, socket: %Socket{private: %{connect_info: %{params: %{"target" => "classic"}}}}}
  end

  describe "embed_templates" do
    test "will compile templates into render/2 functions", %{socket: socket} do
      assert render(HomeLive.home_live(%{foo: :bar, socket: socket}, %{})) =~ "Hello, GameBoy! bar"

      assert render(HomeLive.home_live_other(%{foo: :bar, socket: socket}, %{})) =~ "Hello, Other GameBoy! bar"
    end

    test "will compile templates into render/1 functions for use with `render_with`", %{socket: socket} do
      assert render(HomeLive.home_live(%{foo: :bar, socket: socket})) =~ "Hello, GameBoy! bar"

      assert render(HomeLive.home_live_other(%{foo: :bar, socket: socket})) =~ "Hello, Other GameBoy! bar"
    end
  end
end
