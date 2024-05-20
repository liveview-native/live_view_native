defmodule LiveViewNative.TemplateRenderTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest
  import Phoenix.LiveViewTest
  import LiveViewNativeTest

  @endpoint LiveViewNativeTest.Endpoint

  setup do
    {:ok, conn: Plug.Test.init_test_session(build_conn(), %{})}
  end

  test "can render the fallback html template render", %{conn: conn} do
    {:ok, lv, _html} = live(conn, "/template")

    assert lv |> element("#template") |> render() =~ "original template HTML works"
  end

  test "can render the gameboy format", %{conn: conn} do
    {:ok, lv, _html} = native(conn, "/template", :gameboy)

    assert lv |> element("gameboy") |> render() =~ "Template GameBoy Render 200"
  end

  test "can render the gameboy format with tv target", %{conn: conn} do
    {:ok, lv, _html} = native(conn, "/template", :gameboy, %{"target" => "tv"})

    assert lv |> element("gameboytv") |> render() =~ "TV Target Template GameBoy Render 200"
  end

  test "can render the switch format", %{conn: conn} do
    {:ok, lv, _html} = native(conn, "/template", :switch)

    assert lv |> element("switch") |> render() =~ "Template Switch Render 200"
  end

  test "can render the switch format with tv target", %{conn: conn} do
    {:ok, lv, _html} = native(conn, "/template", :switch, %{"target" => "tv"})

    assert lv |> element("switchtv") |> render() =~ "TV Target Template Switch Render 200"
  end
end
