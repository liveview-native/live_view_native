defmodule LiveViewNative.LiveViewTest do
  use ExUnit.Case, async: true

  import Phoenix.ConnTest
  import LiveViewNativeTest

  alias LiveViewNativeTest.{Endpoint, ViewTree}
  alias Phoenix.HTML

  @endpoint Endpoint

  setup config do
    {:ok, conn: Plug.Test.init_test_session(build_conn(), config[:session] || %{})}
  end

  describe "mounting" do
    test "static mount followed by connected mount", %{conn: conn} do
      conn = get(conn, "/thermo", _format: :gameboy)
      assert lvn_response(conn, 200, :gameboy) =~ "The temp is: 0"

      {:ok, _view, markup} = live(conn, _format: :gameboy)
      assert markup =~ "The temp is: 1"
    end

    test "live mount in single call", %{conn: conn} do
      {:ok, _view, markup} = live(conn, "/thermo", _format: :gameboy)
      assert markup =~ "The temp is: 1"
    end

    test "live mount sets caller", %{conn: conn} do
      {:ok, view, _markup} = live(conn, "/thermo", _format: :gameboy)
      {:dictionary, dictionary} = Process.info(view.pid, :dictionary)
      assert dictionary[:"$callers"] == [self()]
    end

    test "live mount without issuing request", %{conn: conn} do
      assert_raise ArgumentError, ~r/a request has not yet been sent/, fn ->
        live(conn, _format: :gameboy)
      end
    end

    test "live mount with unexpected status", %{conn: conn} do
      assert_raise ArgumentError, ~r/unexpected 404 response/, fn ->
        conn
        |> get("/not_found", _format: :gameboy)
        |> live(_format: :gameboy)
      end
    end
  end

  describe "rendering" do
    test "live render with valid session", %{conn: conn} do
      conn = get(conn, "/thermo", _format: :gameboy)
      markup = lvn_response(conn, 200, :gameboy)

      assert markup =~ """
              <Text>The temp is: 0</Text>
              <Button phx-click="dec">-</Button>
              <Button phx-click="inc">+</Button>
              """

      {:ok, view, markup} = live(conn, _format: :gameboy)
      assert is_pid(view.pid)
      {_tag, _attrs, children} = markup |> ViewTree.parse() |> ViewTree.by_id!(view.id)

      assert children == [
                {"Text", [], ["Redirect: none"]},
                {"Text", [], ["The temp is: 1"]},
                {"Button", [{"phx-click", "dec"}], ["-"]},
                {"Button", [{"phx-click", "inc"}], ["+"]}
              ]
    end

    @tag session: %{nest: [], users: [%{name: "Annette O'Connor", email: "anne@email.com"}]}
    test "live render with correct escaping", %{conn: conn} do
      {:ok, _view, markup} = live(conn, "/thermo", _format: :gameboy)
      assert markup =~ "The temp is: 1"
      assert markup =~ "O'Connor" |> HTML.html_escape() |> HTML.safe_to_string()
    end
  end

  describe "render_*" do
    test "render_click", %{conn: conn} do
      {:ok, view, _} = live(conn, "/thermo", _format: :gameboy)
      assert render_click(view, :save, %{temp: 20}) =~ "The temp is: 20"
    end

    test "render_submit", %{conn: conn} do
      {:ok, view, _} = live(conn, "/thermo", _format: :gameboy)
      assert render_submit(view, :save, %{temp: 20}) =~ "The temp is: 20"
    end

    test "render_change", %{conn: conn} do
      {:ok, view, _} = live(conn, "/thermo", _format: :gameboy)
      assert render_change(view, :save, %{temp: 21}) =~ "The temp is: 21"
    end

    test "render_change with _target", %{conn: conn} do
      {:ok, view, _markup} = live(conn, "/thermo", _format: :gameboy)

      assert render_change(view, :save, %{_target: "", temp: 21}) =~ "The temp is: 21[]"

      assert render_change(view, :save, %{_target: ["user"], temp: 21}) =~
                "The temp is: 21[&quot;user&quot;]"

      assert render_change(view, :save, %{_target: ["user", "name"], temp: 21}) =~
                "The temp is: 21[&quot;user&quot;, &quot;name&quot;]"

      assert render_change(view, :save, %{_target: ["another", "field"], temp: 21}) =~
                "The temp is: 21[&quot;another&quot;, &quot;field&quot;]"
    end

    test "render_key|up|down", %{conn: conn} do
      {:ok, view, _} = live(conn, "/thermo", _format: :gameboy)
      assert render(view) =~ "The temp is: 1"
      assert render_keyup(view, :key, %{"key" => "i"}) =~ "The temp is: 2"
      assert render_keydown(view, :key, %{"key" => "d"}) =~ "The temp is: 1"
      assert render_keyup(view, :key, %{"key" => "d"}) =~ "The temp is: 0"
      assert render(view) =~ "The temp is: 0"
    end

    test "render_blur and render_focus", %{conn: conn} do
      {:ok, view, _markup} = live(conn, "/thermo", _format: :gameboy)
      assert render(view) =~ "The temp is: 1", view.id
      assert render_blur(view, :inactive, %{value: "Zzz"}) =~ "Tap to wake – Zzz"
      assert render_focus(view, :active, %{value: "Hello!"}) =~ "Waking up – Hello!"
    end

    test "render_hook", %{conn: conn} do
      {:ok, view, _} = live(conn, "/thermo", _format: :gameboy)
      assert render_hook(view, :save, %{temp: 20}) =~ "The temp is: 20"
    end
  end

  describe "messaging callbacks" do
    test "handle_event with no change in socket", %{conn: conn} do
      {:ok, view, markup} = live(conn, "/thermo", _format: :gameboy)
      assert markup =~ "The temp is: 1"
      assert render_click(view, :noop) =~ "The temp is: 1"
    end

    test "handle_info with change", %{conn: conn} do
      {:ok, view, _markup} = live(conn, "/thermo", _format: :gameboy)

      assert render(view) =~ "The temp is: 1"

      GenServer.call(view.pid, {:set, :val, 1})
      GenServer.call(view.pid, {:set, :val, 2})
      GenServer.call(view.pid, {:set, :val, 3})

      assert ViewTree.parse(render_click(view, :inc)) ==
                ViewTree.parse("""
                <Text>Redirect: none</Text>
                <Text>The temp is: 4</Text>
                <Button phx-click="dec">-</Button>
                <Button phx-click="inc">+</Button>
                """)

      assert ViewTree.parse(render_click(view, :dec)) ==
                ViewTree.parse("""
                <Text>Redirect: none</Text>
                <Text>The temp is: 3</Text>
                <Button phx-click="dec">-</Button>
                <Button phx-click="inc">+</Button>
                """)

      [{_, _, child_nodes} | _] = ViewTree.parse(render(view))

      assert child_nodes ==
                ViewTree.parse("""
                <Text>Redirect: none</Text>
                <Text>The temp is: 3</Text>
                <Button phx-click="dec">-</Button>
                <Button phx-click="inc">+</Button>
                """)
    end
  end

  describe "title" do
    test "sends page title updates", %{conn: conn} do
      {:ok, view, _markup} = live(conn, "/thermo", _format: :gameboy)
      GenServer.call(view.pid, {:set, :page_title, "New Title"})
      assert page_title(view) =~ "New Title"

      GenServer.call(view.pid, {:set, :page_title, "<Text>New Title</Text>"})
      assert page_title(view) =~ "&lt;Text&gt;New Title&lt;/Text&gt;"
    end
  end

  describe "live_isolated" do
    test "renders a live view with custom session", %{conn: conn} do
      {:ok, view, _} =
        live_isolated(conn, LiveViewNativeTest.DashboardLive,
          session: %{"hello" => "world"},
          _format: :gameboy
        )

      assert render(view) =~ "session: %{&quot;hello&quot; =&gt; &quot;world&quot;}"
    end

    test "renders a live view with custom session and a router", %{conn: conn} do
      conn = %Plug.Conn{conn | request_path: "/router/thermo_defaults/123"}

      {:ok, view, _} =
        live_isolated(conn, LiveViewNativeTest.DashboardLive,
          session: %{"hello" => "world"},
          _format: :gameboy
        )

      assert render(view) =~ "session: %{&quot;hello&quot; =&gt; &quot;world&quot;}"
    end

    test "raises if handle_params is implemented", %{conn: conn} do
      assert_raise ArgumentError,
                    ~r/it is not mounted nor accessed through the router live\/3 macro/,
                    fn -> live_isolated(conn, LiveViewNativeTest.ParamCounterLive, _format: :gameboy) end
    end

    test "works without an initialized session" do
      {:ok, view, _} =
        live_isolated(Phoenix.ConnTest.build_conn(), LiveViewNativeTest.DashboardLive,
          session: %{"hello" => "world"},
          _format: :gameboy
        )

      assert render(view) =~ "session: %{&quot;hello&quot; =&gt; &quot;world&quot;}"
    end

    test "raises on session with atom keys" do
      assert_raise ArgumentError, ~r"LiveView :session must be a map with string keys,", fn ->
        live_isolated(Phoenix.ConnTest.build_conn(), LiveViewNativeTest.DashboardLive,
          session: %{hello: "world"},
          _format: :gameboy
        )
      end
    end
  end
end
