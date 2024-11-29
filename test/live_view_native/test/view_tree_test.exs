defmodule LiveViewNative.ViewTreeTest do
  use ExUnit.Case, async: true

  alias LiveViewNativeTest.ViewTree

  describe "find_live_views" do
    # >= 4432 characters
    @too_big_session Enum.map_join(1..4432, fn _ -> "t" end)

    test "finds views given markup" do
      assert ViewTree.find_live_views(
               ViewTree.parse("""
               <Title>top</Title>
               <Group data-phx-session="SESSION1"
                 id="phx-123"></Group>
               <Group data-phx-parent-id="456"
                   data-phx-session="SESSION2"
                   data-phx-static="STATIC2"
                   id="phx-456"></Group>
               <Group data-phx-session="#{@too_big_session}"
                 id="phx-458"></Group>
               <Title>bottom</Title>
               """)
             ) == [
               {"phx-123", "SESSION1", nil},
               {"phx-456", "SESSION2", "STATIC2"},
               {"phx-458", @too_big_session, nil}
             ]

      assert ViewTree.find_live_views(["none"]) == []
    end

    test "returns main live view as first result" do
      assert ViewTree.find_live_views(
               ViewTree.parse("""
               <Title>top</Title>
               <Group data-phx-session="SESSION1"
                 id="phx-123"></Group>
               <Group data-phx-parent-id="456"
                   data-phx-session="SESSION2"
                   data-phx-static="STATIC2"
                   id="phx-456"></Group>
               <Group data-phx-session="SESSIONMAIN"
                 data-phx-main="true"
                 id="phx-458"></Group>
               <Title>bottom</Title>
               """)
             ) == [
               {"phx-458", "SESSIONMAIN", nil},
               {"phx-123", "SESSION1", nil},
               {"phx-456", "SESSION2", "STATIC2"}
             ]
    end
  end

  describe "replace_root_container" do
    test "replaces tag name and merges attributes" do
      container =
        ViewTree.parse("""
        <Group id="container"
             data-phx-main="true"
             data-phx-session="session"
             data-phx-static="static"
             class="old">contents</Group>
        """)

      assert ViewTree.replace_root_container(container, :Span, %{class: "new"}) ==
               [
                 {"Span",
                  [
                    {"id", "container"},
                    {"data-phx-main", "true"},
                    {"data-phx-session", "session"},
                    {"data-phx-static", "static"},
                    {"class", "new"}
                  ], ["contents"]}
               ]
    end

    test "does not overwrite reserved attributes" do
      container =
        ViewTree.parse("""
        <Group id="container"
             data-phx-main="true"
             data-phx-session="session"
             data-phx-static="static">contents</Group>
        """)

      new_attrs = %{
        "id" => "new",
        "data-phx-session" => "new",
        "data-phx-static" => "new",
        "data-phx-main" => "new"
      }

      assert ViewTree.replace_root_container(container, :Group, new_attrs) ==
               [
                 {"Group",
                  [
                    {"id", "container"},
                    {"data-phx-main", "true"},
                    {"data-phx-session", "session"},
                    {"data-phx-static", "static"}
                  ], ["contents"]}
               ]
    end
  end

  describe "patch_id" do
    test "updates deeply nested markup" do
      lvn = """
      <Group data-phx-session="SESSIONMAIN"
                     data-phx-main="true"
                     id="phx-458">
      <Text id="foo">Hello</Text>
      <List id="list">
        <Text id="1">a</Text>
        <Text id="2">a</Text>
        <Text id="3">a</Text>
      </List>
      </Group>
      """

      inner_markup = """
      <Text id="foo">Hello World</Text>
      <List id="list">
        <Text id="2" class="foo">a</Text>
        <Group id="3">
          <Text id="5">inner</Text>
        </Group>
        <Text id="4">a</Text>
      </List>
      """

      {new_markup, _removed_cids} =
        ViewTree.patch_id("phx-458", ViewTree.parse(lvn), ViewTree.parse(inner_markup), [])

      new_markup = ViewTree.to_markup(new_markup)

      refute new_markup =~ ~S(<Text id="1">a</Text>)
      assert new_markup =~ ~S(<Text id="2" class="foo">a</Text>)
      assert new_markup =~ ~S(<Group id="3"><Text id="5">inner</Text></Group>)
      assert new_markup =~ ~S(<Text id="4">a</Text>)
    end

    test "inserts new elements when phx-update=append" do
      lvn = """
      <Group data-phx-session="SESSIONMAIN"
                     data-phx-main="true"
                     id="phx-458">
      <List id="list" phx-update="append">
        <Text id="1">a</Text>
        <Text id="2">a</Text>
        <Text id="3">a</Text>
      </List>
      </Group>
      """

      inner_markup = """
      <List id="list" phx-update="append">
        <Text id="4" class="foo">a</Text>
      </List>
      """

      {new_markup, _removed_cids} =
        ViewTree.patch_id("phx-458", ViewTree.parse(lvn), ViewTree.parse(inner_markup), [])

      new_markup = ViewTree.to_markup(new_markup)

      assert new_markup =~ ~S(<Text id="1">a</Text>)
      assert new_markup =~ ~S(<Text id="2">a</Text>)
      assert new_markup =~ ~S(<Text id="3">a</Text><Text id="4" class="foo">a</Text>)
    end

    test "inserts new elements when phx-update=prepend" do
      lvn = """
      <Group data-phx-session="SESSIONMAIN"
                     data-phx-main="true"
                     id="phx-458">
      <List id="list" phx-update="append">
        <Text id="1">a</Text>
        <Text id="2">a</Text>
        <Text id="3">a</Text>
      </List>
      </Group>
      """

      inner_markup = """
      <List id="list" phx-update="prepend">
        <Text id="4">a</Text>
      </List>
      """

      {new_markup, _removed_cids} =
        ViewTree.patch_id("phx-458", ViewTree.parse(lvn), ViewTree.parse(inner_markup), [])

      new_markup = ViewTree.to_markup(new_markup)

      assert new_markup =~ ~S(<Text id="4">a</Text><Text id="1">a</Text>)
      assert new_markup =~ ~S(<Text id="2">a</Text>)
      assert new_markup =~ ~S(<Text id="3">a</Text>)
    end

    test "updates existing elements when phx-update=append" do
      lvn = """
      <Group data-phx-session="SESSIONMAIN" data-phx-main="true" id="phx-458">
        <List id="list" phx-update="append">
          <Text id="1">a</Text>
          <Text id="2">a</Text>
          <Text id="3">a</Text>
        </List>
      </Group>
      """

      inner_markup = """
      <List id="list" phx-update="append">
        <Text id="1" class="foo">b</Text>
        <Text id="2">b</Text>
      </List>
      """

      {new_markup, _removed_cids} =
        ViewTree.patch_id("phx-458", ViewTree.parse(lvn), ViewTree.parse(inner_markup), [])

      new_markup = ViewTree.to_markup(new_markup)

      assert new_markup =~ ~S(<Text id="1" class="foo">b</Text>)
      assert new_markup =~ ~S(<Text id="2">b</Text>)
      assert new_markup =~ ~S(<Text id="3">a</Text>)
    end

    test "patches only container data attributes when phx-update=ignore" do
      lvn = """
      <Group data-phx-session="SESSIONMAIN" data-phx-main="true" id="phx-458">
      <Group id="Group" remove="true" data-remove="true" update="a" data-update="a" phx-update="ignore">
        <Text id="1">a</Text>
      </Group>
      </Group>
      """

      inner_markup = """
      <Group id="Group" update="b" data-update="b" add="true" data-add="true" phx-update="ignore">
        <Text id="1" class="foo">b</Text>
      </Group>
      """

      {new_markup, _removed_cids} =
        ViewTree.patch_id("phx-458", ViewTree.parse(lvn), ViewTree.parse(inner_markup), [])

      new_markup = ViewTree.to_markup(new_markup)

      assert new_markup =~ ~S( remove)
      refute new_markup =~ ~S( data-remove)
      assert new_markup =~ ~S( update="a")
      assert new_markup =~ ~S( data-update="b")
      refute new_markup =~ ~S( add)
      assert new_markup =~ ~S( data-add)
      assert new_markup =~ ~S(<Text id="1">a</Text>)
    end

    test "patches elements with special characters in id (issue #3144)" do
      lvn = """
      <Group data-phx-session="SESSIONMAIN" data-phx-main="true" id="phx-458">
      <Group id="Group?param=foo" phx-update="ignore" data-attr="1">
        <Text id="1">a</Text>
      </Group>
      </Group>
      """

      inner_markup = """
      <Group id="Group?param=foo" phx-update="ignore" data-attr="b">
        <Text id="1" class="foo">b</Text>
      </Group>
      """

      {new_markup, _removed_cids} =
        ViewTree.patch_id("phx-458", ViewTree.parse(lvn), ViewTree.parse(inner_markup), [])

      new_markup = ViewTree.to_markup(new_markup)

      assert new_markup =~ ~S(data-attr="b")
      assert new_markup =~ ~S(<Text id="1">a</Text>)
    end
  end

  describe "merge_diff" do
    test "merges unless static" do
      assert ViewTree.merge_diff(%{0 => "bar", s: "foo"}, %{0 => "baz"}) ==
               %{0 => "baz", s: "foo", streams: []}

      assert ViewTree.merge_diff(%{s: "foo", d: []}, %{s: "bar"}) ==
               %{s: "bar", streams: []}
    end
  end
end
