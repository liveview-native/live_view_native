defmodule LiveViewNative.LiveReloaderTest do
  use ExUnit.Case

  import Plug.Test
  import Plug.Conn

  defp conn(path) do
    conn(:get, path)
    |> Plug.Conn.put_private(:phoenix_endpoint, LiveViewNativeTest.Endpoint)
  end

  describe "live reloader" do
    test "injects live_reload for LVN requests if configured and injects at the end of the body" do
      opts = LiveViewNative.LiveReloader.init([])
 
      conn =
        conn("/")
        |> Map.put(:query_string, "_format=gameboy")
        |> LiveViewNative.LiveReloader.call(opts)
        |> send_resp(200, "<Text>Hello, Elixir</Text>")
  
      assert to_string(conn.resp_body) ==
               "<Text>Hello, Elixir</Text><iframe hidden height=\"0\" width=\"0\" src=\"/phoenix/live_reload/frame\"></iframe>"
    end
  end
end