defmodule Mix.LiveViewNative.CodeGenTest do
  use ExUnit.Case

  import Mix.LiveViewNative.Context, only: [
    compile_string: 1,
    last?: 2
  ]

  import Mix.LiveViewNative.CodeGen, only: [
    build_patch: 2
  ]

  alias Mix.LiveViewNative.CodeGen
  alias Sourceror.Zipper

  describe "patch" do
    test "inject before" do
      source = """
      config :logger, :level, :debug
      """

      change = """
      config :live_view_native, plugins: [
        SwiftUI
      ]

      """

      matcher = &(match?({:config, _, [{:__block__, _, [:logger]} | _]}, &1))

      {:ok, source} = CodeGen.patch(source, change, inject: {:before, matcher}, path: "config/config.exs")

      assert source == """
      config :live_view_native, plugins: [
        SwiftUI
      ]

      config :logger, :level, :debug
      """
    end

    test "inject before not matched" do
      source = """
      config :logger, :level, :debug
      """

      change = """
      config :live_view_native, plugins: [
        SwiftUI
      ]

      """

      matcher = &(match?({:config, _, [{:__block__, _, [:other]} | _]}, &1))

      assert {:error, _msg} = CodeGen.patch(source, change, inject: {:before, matcher}, path: "config/config.exs")
    end

    test "inject after" do
      source = """
      config :logger, :level, :debug
      config :logger, :backends, []
      """

      change = """

      config :live_view_native, plugins: [
        SwiftUI
      ]

      """

      matcher = &(match?({:config, _, [{:__block__, _, [:logger]} | _]}, &1))

      {:ok, source} = CodeGen.patch(source, change, inject: {:after, matcher}, path: "config/config.exs")

      assert source == """
      config :logger, :level, :debug

      config :live_view_native, plugins: [
        SwiftUI
      ]

      config :logger, :backends, []
      """
    end

    test "inject after not matched" do
      source = """
      config :logger, :level, :debug
      config :logger, :backends, []
      """

      change = """

      config :live_view_native, plugins: [
        SwiftUI
      ]

      """

      matcher = &(match?({:config, _, [{:__block__, _, [:other]} | _]}, &1))

      assert {:error, _msg} = CodeGen.patch(source, change, inject: {:after, matcher}, path: "config/config.exs")
    end

    test "inject head" do
      source = """
      config :logger, :level, :debug
      """

      change = """
      config :live_view_native, plugins: [
        SwiftUI
      ]

      """

      {:ok, source} = CodeGen.patch(source, change, inject: :head)

      assert source == """
      config :live_view_native, plugins: [
        SwiftUI
      ]

      config :logger, :level, :debug
      """
    end

    test "inject eof" do
      source = """
      config :logger, :level, :debug
      """

      change = """

      config :live_view_native, plugins: [
        SwiftUI
      ]
      """

      {:ok, source} = CodeGen.patch(source, change, inject: :eof)

      assert source == """
      config :logger, :level, :debug

      config :live_view_native, plugins: [
        SwiftUI
      ]
      """
    end

    test "merge" do
      source = """
      config :logger, :level, :debug

      config :live_view_native, plugins: [
        HTML,
        Jetpack
      ]
      """

      change = """

      config :live_view_native, plugins: [
        SwiftUI
      ]
      """

      merge = &merger/2

      {:ok, source} = CodeGen.patch(source, change, merge: merge)

      assert source == """
      config :logger, :level, :debug

      config :live_view_native, plugins: [
        HTML,
        Jetpack,
        SwiftUI
      ]
      """
    end

    test "merge fails, fallback to inject" do
      source = """
      config :logger, :level, :debug
      """

      change = """

      config :live_view_native, plugins: [
        SwiftUI
      ]
      """

      merge = &merger/2

      matcher = &(match?({:config, _, [{:__block__, _, [:logger]} | _]}, &1))

      {:ok, source} = CodeGen.patch(source, change, merge: merge, inject: {:after, matcher}, path: "config/config.exs")

      assert source == """
      config :logger, :level, :debug

      config :live_view_native, plugins: [
        SwiftUI
      ]
      """
    end
  end

  def merger(source, change) do
    quoted_change = Sourceror.parse_string!(change)

    source
    |> Sourceror.parse_string!()
    |> Zipper.zip()
    |> Zipper.find(&match?({:config, _, [{:__block__, _, [:live_view_native]} | _]}, &1))
    |> case do
      nil -> :error
      found ->
        Zipper.find(found, &match?({{:__block__, _, [:plugins]}, _}, &1))
        |> case do
          nil -> :error
          %{node: {{:__block__, _, [:plugins]}, {:__block__, _, [source_list]} = source_block}} ->
            {:config, _, [_, [{_, {:__block__, _, [change_list]}}]]} = quoted_change
            range = Sourceror.get_range(source_block)
            source_members = Enum.map(source_list, fn(member) -> Code.eval_quoted(member) |> elem(0) end)
            change_members = Enum.map(change_list, fn(member) -> Code.eval_quoted(member) |> elem(0) end)

            plugins_list = (source_members ++ change_members) |> Enum.uniq() |> Enum.sort()

            change = """
              [<%= for plugin <- plugins_list do %>
                <%= inspect plugin %><%= unless last?(plugins_list, plugin) do %>,<% end %><% end %>
              ]
              """
              |> compile_string()
              |> String.trim()

            [build_patch(range, change)]
        end
    end
  end
end
