defmodule LiveViewNative.ComponentInterfaceTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest
  require Phoenix.LiveViewTest
  import LiveViewNativeTest

  @endpoint LiveViewNativeTest.Endpoint

  setup do
    {:ok, conn: Plug.Test.init_test_session(build_conn(), %{})}
  end

  test "can render the fallback html inline render", %{conn: conn} do
    {:ok, lv, _html} = Phoenix.LiveViewTest.live(conn, "/interface")

    assert lv |> Phoenix.LiveViewTest.render() =~ "In HTML"
  end

  test "can render the gameboy format", %{conn: conn} do
    {:ok, lv, _markup} = live(conn, "/interface", _format: :gameboy)

    assert lv |> render() =~ "In Default"
  end

  test "can render the gameboy format with watch interface", %{conn: conn} do
    {:ok, lv, _markup} = live(conn, "/interface", _format: :gameboy, _interface: %{"target" => "watch"})

    assert lv |> render() =~ "In Watch"
  end
end
