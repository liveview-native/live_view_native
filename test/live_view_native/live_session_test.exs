defmodule LiveViewNative.LiveSessionTest do
  use ExUnit.Case

  alias Phoenix.LiveView.Socket
  alias LiveViewNative.LiveSession

  describe "on_mount/4" do
    test "assigns a @native assign with the correct platform configuration" do
      socket = %Socket{
        private: %{
          connect_params: %{
            "_lvn" => %{
              "app_version" => "0.2",
              "app_build" => "1",
              "bundle_id" => "com.TestSuite.LVN",
              "format" => "lvntest",
              "os" => "fakeos",
              "os_version" => "1.0",
              "target" => "testsuite"
            }
          }
        },
        transport_pid: self()
      }

      {:cont, updated_socket} = LiveSession.on_mount(:live_view_native, %{}, %{}, socket)

      assert updated_socket.assigns
      assert updated_socket.assigns.native
      assert updated_socket.assigns.app_version == "0.2"
      assert updated_socket.assigns.app_build == "1"
      assert updated_socket.assigns.bundle_id == "com.TestSuite.LVN"
      assert updated_socket.assigns.format == :lvntest
      assert updated_socket.assigns.os == "fakeos"
      assert updated_socket.assigns.os_version == "1.0"
      assert updated_socket.assigns.target == :testsuite
      assert updated_socket.assigns.native.__struct__ == LiveViewNativePlatform.Env
      assert updated_socket.assigns.native.platform_id == :lvntest

      assert updated_socket.assigns.native.platform_config == %LiveViewNative.TestPlatform{
               testing_notes: "everything is ok"
             }

      assert updated_socket.assigns.native.template_extension == ".test.heex"
    end

    test "does nothing if _lvn connect param is not passed" do
      socket = %Socket{
        private: %{connect_params: %{}},
        transport_pid: self()
      }

      {:cont, updated_socket} = LiveSession.on_mount(:live_view_native, %{}, %{}, socket)

      assert updated_socket.assigns
      refute Map.has_key?(updated_socket.assigns, :native)
    end
  end
end
