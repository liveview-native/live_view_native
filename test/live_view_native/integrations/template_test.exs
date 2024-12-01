defmodule LiveViewNative.TemplateRenderTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest
  require Phoenix.LiveViewTest
  import LiveViewNativeTest

  @endpoint LiveViewNativeTest.Endpoint

  setup do
    {:ok, conn: Plug.Test.init_test_session(build_conn(), %{})}
  end

  test "can render the fallback html template render", %{conn: conn} do
    {:ok, lv, _html} = Phoenix.LiveViewTest.live(conn, "/template")

    assert lv |> Phoenix.LiveViewTest.element("#template") |> Phoenix.LiveViewTest.render() =~ "original template HTML works"
  end

  test "can render the gameboy format", %{conn: conn} do
    {:ok, lv, _markup} = live(conn, "/template", _format: :gameboy)

    assert lv |> element("GameBoy") |> render() =~ "Template GameBoy Render 200"
  end

  test "can render the gameboy format with tv target", %{conn: conn} do
    {:ok, lv, _markup} = live(conn, "/template", _format: :gameboy, _interface: %{"target" => "tv"})

    assert lv |> element("GameBoyTV") |> render() =~ "TV Target Template GameBoy Render 200"
  end

  test "can render the switch format", %{conn: conn} do
    {:ok, lv, _markup} = live(conn, "/template", _format: :switch)

    assert lv |> element("Switch") |> render() =~ "Template Switch Render 200"
  end

  test "can render the switch format with tv target", %{conn: conn} do
    {:ok, lv, _markup} = live(conn, "/template", _format: :switch, _interface: %{"target" => "tv"})

    assert lv |> element("SwitchTV") |> render() =~ "TV Target Template Switch Render 200"
  end
end
