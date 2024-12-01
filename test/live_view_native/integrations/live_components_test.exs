defmodule LiveViewNative.LiveComponentsTest do
  use ExUnit.Case, async: true
  import Phoenix.ConnTest
  import LiveViewNativeTest

  alias LiveViewNativeTest.{Endpoint, ViewTree, StatefulComponent}

  @endpoint LiveViewNativeTest.Endpoint
  @moduletag session: %{names: ["chris", "jose"], from: nil}

  setup config do
    {:ok,
     conn: Plug.Test.init_test_session(Phoenix.ConnTest.build_conn(), config[:session] || %{})}
  end

  test "@myself" do
    cid = %LiveViewNative.LiveComponent.CID{cid: 123}
    assert String.Chars.to_string(cid) == "123"
    assert LiveViewNative.Template.Safe.to_iodata(cid) == "123"
  end

  test "renders successfully disconnected then connected responses", %{conn: conn} do
    conn = get(conn, "/components", _format: "gameboy")
    assert lvn_response(conn, 200, :gameboy) =~ "<Group phx-click=\"transform\" id=\"chris\" phx-target=\"#chris\">"

    {:ok, _view, markup} = live(conn, _format: "gameboy")

    assert markup =~ "<Group data-phx-component=\"1\" phx-click=\"transform\" id=\"chris\" phx-target=\"#chris\">"
  end

  test "renders successfully when connected", %{conn: conn} do
    {:ok, view, _markup} = live(conn, "/components", _format: :gameboy)

    assert [
             {"div", _,
              [
                _,
                {"Group",
                 [{"data-phx-component", "1"}, {"phx-click", "transform"}, {"id", "chris"} | _],
                 ["\n  chris says hi\n  \n"]},
                {"Group",
                 [{"data-phx-component", "2"}, {"phx-click", "transform"}, {"id", "jose"} | _],
                 ["\n  jose says hi\n  \n"]}
              ]}
           ] = ViewTree.parse(render(view))
  end

  test "tracks additions and updates", %{conn: conn} do
    {:ok, view, _} = live(conn, "/components", _format: :gameboy)
    markup = render_click(view, "dup-and-disable", %{})

    assert [
             "Redirect: none\n\n  ",
             {"Text", [{"data-phx-component", "1"}], ["\n  DISABLED\n"]},
             {"Text", [{"data-phx-component", "2"}], ["\n  DISABLED\n"]},
             {"Group",
              [
                {"data-phx-component", "3"},
                {"phx-click", "transform"},
                {"id", "chris-new"},
                {"phx-target", "#chris-new"}
              ], ["\n  chris-new says hi\n  \n"]},
             {"Group",
              [
                {"data-phx-component", "4"},
                {"phx-click", "transform"},
                {"id", "jose-new"},
                {"phx-target", "#jose-new"}
              ], ["\n  jose-new says hi\n  \n"]}
           ] = ViewTree.parse(markup)
  end

  test "tracks removals", %{conn: conn} do
    {:ok, view, markup} = live(conn, "/components", _format: :gameboy)

    assert [
             {"Group",
              [{"data-phx-component", "1"}, {"phx-click", "transform"}, {"id", "chris"} | _],
              ["\n  chris says" <> _]},
             {"Group",
              [{"data-phx-component", "2"}, {"phx-click", "transform"}, {"id", "jose"} | _],
              ["\n  jose says" <> _]}
           ] = markup |> ViewTree.parse() |> ViewTree.all("#chris, #jose")

    markup = render_click(view, "delete-name", %{"name" => "chris"})

    assert [
             {"Group",
              [{"data-phx-component", "2"}, {"phx-click", "transform"}, {"id", "jose"} | _],
              ["\n  jose says" <> _]}
           ] = markup |> ViewTree.parse() |> ViewTree.all("#chris, #jose")

    refute view |> element("#chris") |> has_element?()
  end

  test "tracks removals when whole root changes", %{conn: conn} do
    {:ok, view, _markup} = live(conn, "/components", _format: :gameboy)
    assert render_click(view, "disable-all", %{}) =~ "Disabled\n"
    # Sync to make sure it is still alive
    assert render(view) =~ "Disabled\n"
  end

  test "tracks removals from a nested LiveView", %{conn: conn} do
    {:ok, view, _markup} = live(conn, "/component_in_live", _format: :gameboy)
    assert render(view) =~ "Hello World"
    view |> find_live_child("nested_live") |> render_click("disable", %{})
    refute render(view) =~ "Hello World"
  end

  test "tracks removals of a nested LiveView alongside with a LiveComponent in the root view", %{
    conn: conn
  } do
    {:ok, view, _} = live(conn, "/component_and_nested_in_live", _format: :gameboy)
    markup = render(view)
    assert markup =~ "hello"
    assert markup =~ "world"
    render_click(view, "disable", %{})

    markup = render(view)
    refute markup =~ "hello"
    refute markup =~ "world"
  end

  test "tracks removals when there is a race between server and client", %{conn: conn} do
    {:ok, view, _} = live(conn, "/cids_destroyed", _format: :gameboy)

    # The button is on the page
    assert render(view) =~ "Hello World</Button>"

    # Make sure we can bump the component
    assert view |> element("#bumper") |> render_click() =~ "Bump: 1"

    # Now click the form
    assert view |> element("Form") |> render_submit() =~ "loading..."

    # Which will be reset almost immediately
    assert render(view) =~ "Hello World</Button>"

    # But the client did not have time to remove it so the bumper still keeps going
    assert view |> element("#bumper") |> render_click() =~ "Bump: 2"
  end

  describe "handle_event" do
    test "delegates event to component", %{conn: conn} do
      {:ok, view, _markup} = live(conn, "/components", _format: :gameboy)

      markup = view |> element("#chris") |> render_click(%{"op" => "upcase"})

      assert [
               _,
               {"Group",
                [{"data-phx-component", "1"}, {"phx-click", "transform"}, {"id", "chris"} | _],
                ["\n  CHRIS says hi\n" <> _]},
               {"Group",
                [{"data-phx-component", "2"}, {"phx-click", "transform"}, {"id", "jose"} | _],
                ["\n  jose says hi\n" <> _]}
             ] = ViewTree.parse(markup)

      markup = view |> with_target("#jose") |> render_click("transform", %{"op" => "title-case"})

      assert [
               _,
               {"Group",
                [{"data-phx-component", "1"}, {"phx-click", "transform"}, {"id", "chris"} | _],
                ["\n  CHRIS says hi\n" <> _]},
               {"Group",
                [{"data-phx-component", "2"}, {"phx-click", "transform"}, {"id", "jose"} | _],
                ["\n  Jose says hi\n" <> _]}
             ] = ViewTree.parse(markup)

      markup = view |> element("#jose") |> render_click(%{"op" => "dup"})

      assert [
               _,
               {"Group",
                [{"data-phx-component", "1"}, {"phx-click", "transform"}, {"id", "chris"} | _],
                ["\n  CHRIS says hi\n" <> _]},
               {"Group",
                [{"data-phx-component", "2"}, {"phx-click", "transform"}, {"id", "jose"} | _],
                [
                  "\n  Jose says hi\n  ",
                  {"Group",
                   [
                     {"data-phx-component", "3"},
                     {"phx-click", "transform"},
                     {"id", "Jose-dup"} | _
                   ], ["\n  Jose-dup says hi\n" <> _]}
                ]}
             ] = ViewTree.parse(markup)

      markup = view |> element("#jose #Jose-dup") |> render_click(%{"op" => "upcase"})

      assert [
               _,
               {"Group",
                [{"data-phx-component", "1"}, {"phx-click", "transform"}, {"id", "chris"} | _],
                ["\n  CHRIS says hi\n" <> _]},
               {"Group",
                [{"data-phx-component", "2"}, {"phx-click", "transform"}, {"id", "jose"} | _],
                [
                  "\n  Jose says hi\n  ",
                  {"Group",
                   [
                     {"data-phx-component", "3"},
                     {"phx-click", "transform"},
                     {"id", "Jose-dup"} | _
                   ], ["\n  JOSE-DUP says hi\n" <> _]}
                ]}
             ] = ViewTree.parse(markup)

      assert view |> element("#jose #Jose-dup") |> render() ==
               "<Group data-phx-component=\"3\" phx-click=\"transform\" id=\"Jose-dup\" phx-target=\"#Jose-dup\">\n  JOSE-DUP says hi\n  \n</Group>"
    end

    test "works with_target to component", %{conn: conn} do
      {:ok, view, _markup} = live(conn, "/components", _format: :gameboy)

      markup = view |> with_target("#chris") |> render_click("transform", %{"op" => "upcase"})

      assert [
               _,
               {"Group",
                [{"data-phx-component", "1"}, {"phx-click", "transform"}, {"id", "chris"} | _],
                ["\n  CHRIS says hi\n" <> _]},
               {"Group",
                [{"data-phx-component", "2"}, {"phx-click", "transform"}, {"id", "jose"} | _],
                ["\n  jose says hi\n" <> _]}
             ] = ViewTree.parse(markup)
    end

    test "works with multiple phx-targets", %{conn: conn} do
      {:ok, view, _markup} = live(conn, "/multi-targets", _format: :gameboy)

      view |> element("#chris") |> render_click(%{"op" => "upcase"})

      markup = render(view)

      assert [
               {_, _,
                [
                  {"Group", [{"id", "parent_id"} | _],
                   [
                     "\n  Parent was updated\n" <> _,
                     {"Group",
                      [
                        {"data-phx-component", "1"},
                        {"phx-click", "transform"},
                        {"id", "chris"} | _
                      ], ["\n  CHRIS says hi\n" <> _]},
                     {"Group",
                      [
                        {"data-phx-component", "2"},
                        {"phx-click", "transform"},
                        {"id", "jose"} | _
                      ], ["\n  jose says hi\n" <> _]}
                   ]}
                ]}
             ] = ViewTree.parse(markup)
    end

    test "phx-target works with non id selector", %{conn: conn} do
      {:ok, view, _markup} =
        conn
        |> Plug.Conn.put_session(:parent_selector, ".parent")
        |> live("/multi-targets", _format: :gameboy)

      view |> element("#chris") |> render_click(%{"op" => "upcase"})

      markup = render(view)

      assert [
               {_, _,
                [
                  {"Group", [{"id", "parent_id"} | _],
                   [
                     "\n  Parent was updated\n" <> _,
                     {"Group",
                      [
                        {"data-phx-component", "1"},
                        {"phx-click", "transform"},
                        {"id", "chris"} | _
                      ], ["\n  CHRIS says hi\n" <> _]},
                     {"Group",
                      [
                        {"data-phx-component", "2"},
                        {"phx-click", "transform"},
                        {"id", "jose"} | _
                      ], ["\n  jose says hi\n" <> _]}
                   ]}
                ]}
             ] = ViewTree.parse(markup)
    end
  end

  describe "send_update" do
    test "updates child from parent", %{conn: conn} do
      {:ok, view, _markup} = live(conn, "/components", _format: :gameboy)

      send(
        view.pid,
        {:send_update,
         [
           {StatefulComponent, id: "chris", name: "NEW-chris", from: self()},
           {StatefulComponent, id: "jose", name: "NEW-jose", from: self()}
         ]}
      )

      assert_receive {:updated, %{id: "chris", name: "NEW-chris"}}
      assert_receive {:updated, %{id: "jose", name: "NEW-jose"}}
      refute_receive {:updated, _}

      assert [
               {"Group",
                [{"data-phx-component", "1"}, {"phx-click", "transform"}, {"id", "chris"} | _],
                ["\n  NEW-chris says hi\n  \n"]}
             ] = view |> element("#chris") |> render() |> ViewTree.parse()

      assert [
               {"Group",
                [{"data-phx-component", "2"}, {"phx-click", "transform"}, {"id", "jose"} | _],
                ["\n  NEW-jose says hi\n  \n"]}
             ] = view |> element("#jose") |> render() |> ViewTree.parse()
    end

    test "updates child from independent pid", %{conn: conn} do
      {:ok, view, _markup} = live(conn, "/components", _format: :gameboy)

      Phoenix.LiveView.send_update(view.pid, StatefulComponent,
        id: "chris",
        name: "NEW-chris",
        from: self()
      )

      Phoenix.LiveView.send_update_after(
        view.pid,
        StatefulComponent,
        [id: "jose", name: "NEW-jose", from: self()],
        10
      )

      assert_receive {:updated, %{id: "chris", name: "NEW-chris"}}
      assert_receive {:updated, %{id: "jose", name: "NEW-jose"}}
      refute_receive {:updated, _}
    end

    test "updates with cid", %{conn: conn} do
      {:ok, view, _markup} = live(conn, "/components", _format: :gameboy)

      Phoenix.LiveView.send_update_after(
        view.pid,
        StatefulComponent,
        [id: "jose", name: "NEW-jose", from: self(), all_assigns: true],
        10
      )

      assert_receive {:updated, %{id: "jose", name: "NEW-jose", myself: myself}}

      Phoenix.LiveView.send_update(view.pid, myself, name: "NEXTGEN-jose", from: self())
      assert_receive {:updated, %{id: "jose", name: "NEXTGEN-jose"}}

      Phoenix.LiveView.send_update_after(
        view.pid,
        myself,
        [name: "after-NEXTGEN-jose", from: self()],
        10
      )

      assert_receive {:updated, %{id: "jose", name: "after-NEXTGEN-jose"}}, 500
    end

    test "updates without :id raise", %{conn: conn} do
      Process.flag(:trap_exit, true)
      {:ok, view, _markup} = live(conn, "/components", _format: :gameboy)

      assert ExUnit.CaptureLog.capture_log(fn ->
               send(view.pid, {:send_update, [{StatefulComponent, name: "NEW-chris"}]})
               ref = Process.monitor(view.pid)
               assert_receive {:DOWN, ^ref, _, _, _}, 500
             end) =~ "** (ArgumentError) missing required :id in send_update"
    end

    test "warns if component doesn't exist", %{conn: conn} do
      {:ok, view, _markup} = live(conn, "/components", _format: :gameboy)

      # with module and id
      assert ExUnit.CaptureLog.capture_log(fn ->
               send(view.pid, {:send_update, [{StatefulComponent, id: "nemo", name: "NEW-nemo"}]})
               render(view)
               refute_receive {:updated, _}
             end) =~
               "send_update failed because component LiveViewNativeTest.StatefulComponent with ID \"nemo\" does not exist or it has been removed"

      # with @myself
      assert ExUnit.CaptureLog.capture_log(fn ->
               send(
                 view.pid,
                 {:send_update, [{%Phoenix.LiveComponent.CID{cid: 999}, name: "NEW-nemo"}]}
               )

               render(view)
               refute_receive {:updated, _}
             end) =~
               "send_update failed because component with CID 999 does not exist or it has been removed"
    end

    test "raises if component module is not available", %{conn: conn} do
      Process.flag(:trap_exit, true)
      {:ok, view, _markup} = live(conn, "/components", _format: :gameboy)

      assert ExUnit.CaptureLog.capture_log(fn ->
               send(
                 view.pid,
                 {:send_update, [{NonexistentComponent, id: "chris", name: "NEW-chris"}]}
               )

               ref = Process.monitor(view.pid)
               assert_receive {:DOWN, ^ref, _, _, _}, 500
             end) =~
               "** (ArgumentError) send_update failed (module NonexistentComponent is not available)"
    end
  end

  describe "redirects" do
    test "push_navigate", %{conn: conn} do
      {:ok, view, markup} = live(conn, "/components", _format: :gameboy)
      assert markup =~ "Redirect: none"

      assert {:error, {:live_redirect, %{to: "/components?redirect=push"}}} =
               view |> element("#chris") |> render_click(%{"op" => "push_navigate"})

      assert_redirect(view, "/components?redirect=push")
    end

    test "push_patch", %{conn: conn} do
      {:ok, view, markup} = live(conn, "/components", _format: :gameboy)
      assert markup =~ "Redirect: none"

      assert view |> element("#chris") |> render_click(%{"op" => "push_patch"}) =~
               "Redirect: patch"

      assert_patch(view, "/components?redirect=patch")
    end

    test "redirect", %{conn: conn} do
      {:ok, view, markup} = live(conn, "/components", _format: :gameboy)
      assert markup =~ "Redirect: none"

      assert view |> element("#chris") |> render_click(%{"op" => "redirect"}) ==
               {:error, {:redirect, %{to: "/components?redirect=redirect", status: 302}}}

      assert_redirect(view, "/components?redirect=redirect")
    end
  end

  defmodule MyComponent do
    use LiveViewNative.LiveComponent,
      format: :gameboy,
      as: :render

    # Assert endpoint was set
    def mount(%{endpoint: Endpoint, router: SomeRouter} = socket) do
      send(self(), {:mount, socket})
      {:ok, assign(socket, hello: "world")}
    end

    def update(assigns, socket) do
      send(self(), {:update, assigns, socket})
      {:ok, assign(socket, assigns)}
    end

    def render(assigns) do
      send(self(), :render)

      ~LVN"""
      <Text>
        FROM <%= @from %> <%= @hello %>
      </Text>
      """
    end
  end

  defmodule RenderOnlyComponent do
    use LiveViewNative.LiveComponent,
      format: :gameboy,
      as: :render

    def render(assigns) do
      ~LVN"""
      <Text>
        RENDER ONLY <%= @from %>
      </Text>
      """
    end
  end

  defmodule NestedRenderOnlyComponent do
    use LiveViewNative.LiveComponent,
      format: :gameboy,
      as: :render

    def render(assigns) do
      ~LVN"""
      <.live_component module={RenderOnlyComponent} from={@from} id="render-only-component" />
      """
    end
  end

  defmodule BadRootComponent do
    use LiveViewNative.LiveComponent,
      format: :gameboy,
      as: :render

    def render(assigns) do
      ~LVN"""
      <foo><%= @id %></foo>
      <bar><%= @id %></bar>
      """
    end
  end

  describe "render_component/2" do
    test "life-cycle" do
      assert render_component(MyComponent, %{from: "test", id: "stateful"}, router: SomeRouter) =~
               "FROM test world"

      assert_received {:mount,
                       %{assigns: %{flash: %{}, myself: %Phoenix.LiveComponent.CID{cid: -1}}}}

      assert_received {:update, %{from: "test", id: "stateful"},
                       %{assigns: %{flash: %{}, myself: %Phoenix.LiveComponent.CID{cid: -1}}}}
    end

    test "render only" do
      assert render_component(RenderOnlyComponent, %{from: "test"}) =~ "RENDER ONLY test"
    end

    test "nested render only" do
      assert render_component(NestedRenderOnlyComponent, %{from: "test"}) =~ "RENDER ONLY test"
    end

    test "raises on bad root" do
      assert_raise ArgumentError, ~r/have a single static HTML tag at the root/, fn ->
        render_component(BadRootComponent, %{id: "id"})
      end
    end

    test "loads unloaded component" do
      module = LiveViewNativeTest.ComponentInLive.Component
      :code.purge(module)
      :code.delete(module)
      assert render_component(module, %{}) =~ "<Text>Hello World</Text>"
    end
  end
end
