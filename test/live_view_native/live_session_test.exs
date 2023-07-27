defmodule LiveViewNative.LiveSessionTest do
  use ExUnit.Case

  alias Phoenix.LiveView.Socket
  alias LiveViewNative.LiveSession

  describe "on_mount/4" do
    test "assigns a @native assign with the correct platform configuration" do
      socket = %Socket{
        private: %{connect_params: %{"_platform" => "lvntest"}},
        transport_pid: self()
      }

      {:cont, updated_socket} = LiveSession.on_mount(:live_view_native, %{}, %{}, socket)

      assert updated_socket.assigns
      assert updated_socket.assigns.native
      assert updated_socket.assigns.native.__struct__ == LiveViewNativePlatform.Env
      assert updated_socket.assigns.native.platform_id == :lvntest

      assert updated_socket.assigns.native.platform_config == %LiveViewNative.TestPlatform{
               testing_notes: "everything is ok"
             }

      assert updated_socket.assigns.native.template_extension == ".test.heex"
    end

    test "falls back to Web platform if _platform connect param is not passed" do
      socket = %Socket{
        private: %{connect_params: %{}},
        transport_pid: self()
      }

      {:cont, updated_socket} = LiveSession.on_mount(:live_view_native, %{}, %{}, socket)

      assert updated_socket.assigns
      assert updated_socket.assigns.native
      assert updated_socket.assigns.native.__struct__ == LiveViewNativePlatform.Env
      assert updated_socket.assigns.native.platform_id == :web
      assert updated_socket.assigns.native.template_extension == ".html.heex"
    end
  end
end
