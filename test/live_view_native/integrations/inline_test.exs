defmodule LiveViewNative.InlineRenderTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest
  require Phoenix.LiveViewTest
  import LiveViewNativeTest

  @endpoint LiveViewNativeTest.Endpoint

  setup do
    {:ok, conn: Plug.Test.init_test_session(build_conn(), %{})}
  end

  test "can render the fallback html inline render", %{conn: conn} do
    {:ok, lv, _html} = Phoenix.LiveViewTest.live(conn, "/inline")

    assert lv |> Phoenix.LiveViewTest.element("#inline") |> Phoenix.LiveViewTest.render() =~ "original inline HTML works"
  end

  test "can render the gameboy format", %{conn: conn} do
    {:ok, lv, _markup} = live(conn, "/inline", :gameboy)

    assert lv |> element("GameBoy") |> render() =~ "Inline GameBoy Render 100"
  end

  test "can render the gameboy format with tv target", %{conn: conn} do
    {:ok, lv, _markup} = live(conn, "/inline", :gameboy, %{"target" => "tv"})

    assert lv |> element("GameBoyTV") |> render() =~ "TV Target Inline GameBoy Render 100"
  end

  test "can render the switch format", %{conn: conn} do
    {:ok, lv, _markup} = live(conn, "/inline", :switch)

    assert lv |> element("Switch") |> render() =~ "Inline Switch Render 100"
  end

  test "can render the switch format with tv target", %{conn: conn} do
    {:ok, lv, _markup} = live(conn, "/inline", :switch, %{"target" => "tv"})

    assert lv |> element("SwitchTV") |> render() =~ "TV Target Inline Switch Render 100"
  end
end
