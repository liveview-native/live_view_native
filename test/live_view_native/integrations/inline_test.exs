defmodule LiveViewNative.InlineRenderTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest
  import Phoenix.LiveViewTest
  import LiveViewNativeTest

  @endpoint LiveViewNativeTest.Endpoint

  setup do
    {:ok, conn: Plug.Test.init_test_session(build_conn(), %{})}
  end

  test "can render the fallback html inline render", %{conn: conn} do
    {:ok, lv, _body} = live(conn, "/inline")

    assert lv |> element("#inline") |> render() =~ "original inline HTML works"
  end

  test "can render the gameboy format", %{conn: conn} do
    {:ok, lv, _body} = native(conn, "/inline", :gameboy)

    assert lv |> element("gameboy") |> render() =~ "Inline GameBoy Render 100"
  end

  test "can render the gameboy format with tv target", %{conn: conn} do
    {:ok, lv, _body} = native(conn, "/inline", :gameboy, %{"target" => "tv"})

    assert lv |> element("gameboytv") |> render() =~ "TV Target Inline GameBoy Render 100"
  end

  test "can render the switch format", %{conn: conn} do
    {:ok, lv, _body} = native(conn, "/inline", :switch)

    assert lv |> element("switch") |> render() =~ "Inline Switch Render 100"
  end

  test "can render the switch format with tv target", %{conn: conn} do
    {:ok, lv, _body} = native(conn, "/inline", :switch, %{"target" => "tv"})

    assert lv |> element("switchtv") |> render() =~ "TV Target Inline Switch Render 100"
  end
end
