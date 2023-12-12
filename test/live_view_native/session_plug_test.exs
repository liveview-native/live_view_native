defmodule LiveViewNative.SessionPlugTest do
  use ExUnit.Case

  import Plug.Test
  import Plug.Conn

  defp conn(path) do
    conn(:get, path)
    |> Plug.Conn.put_private(:phoenix_endpoint, MyApp.Endpoint)
  end

  describe "live reloader" do
    test "injects live_reload for LVN requests if configured and injects at the end of the body" do
      opts = LiveViewNative.SessionPlug.init([])
 
      # define so it exists
      :root_layout_native
      
      conn =
        conn("/")
        |> Map.put(:params, %{"_lvn" => %{"format" => "native"}})
        |> put_private(:phoenix_format, "html")
        |> put_private(:phoenix_root_layout, %{
            "html" => {TestLayout, :root_layout}
          })
        |> LiveViewNative.SessionPlug.call(opts)
        |> send_resp(200, "<Text>Hello, Elixir</Text>")
  
      assert to_string(conn.resp_body) ==
               "<Text>Hello, Elixir</Text><iframe hidden height=\"0\" width=\"0\" src=\"/phoenix/live_reload/frame\"></iframe>"
    end
  end
end