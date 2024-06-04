defmodule Mix.Tasks.Lvn.GenTest do
  use ExUnit.Case

  import Mix.Lvn.TestHelper

  @templates Path.join(File.cwd!(), "test/mix/tasks/templates")

  alias Mix.Tasks.Lvn.Gen

  setup do
    Mix.Task.clear()
    :ok
  end

  describe "when a single app" do
    test "generates the `Native` module into the project's lib directory and injects config", config do
      in_tmp_live_project config.test, fn ->
        File.mkdir_p!("config")
        File.write!("config/config.exs", File.read!(Path.join(@templates, "config-1")))
        File.write!("config/dev.exs", File.read!(Path.join(@templates, "dev-1")))

        Gen.run([])

        assert_file "lib/live_view_native_native.ex", fn file ->
          assert file =~ "LiveViewNativeNative"
        end

        assert_file "config/config.exs", fn file ->
          assert file =~ """
            config :live_view_native, plugins: [
              LiveViewNativeTest.GameBoy,
              LiveViewNativeTest.Switch
            ]
            """

          assert file =~ """
            config :mime, :types, %{
              "text/gameboy" => ["gameboy"],
              "text/switch" => ["switch"]
            }
            """

          assert file =~ """
            config :phoenix_template, format_encoders: [
              gameboy: Phoenix.HTML.Engine,
              switch: Phoenix.HTML.Engine
            ]
            """

          assert file =~ """
            config :phoenix, :template_engines,
              neex: LiveViewNative.Engine
            """
        end
      end
    end

    test "will raise with message if any arguments are given", config do
      in_tmp_live_project config.test, fn ->
        assert_raise(Mix.Error, fn() ->
          Gen.run(["gameboy"])
        end)
        refute_file "lib/live_view_native_native.ex"
      end
    end
  end

  describe "when an umbrella app" do
    test "generates the `Native` module into the project's lib directory", config do
      in_tmp_live_umbrella_project config.test, fn ->
        File.cd!("live_view_native_web", fn ->
          File.mkdir_p!("config")
          File.write!("config/config.exs", File.read!(Path.join(@templates, "config-1")))
          File.write!("config/dev.exs", File.read!(Path.join(@templates, "dev-1")))

          Gen.run([])

          assert_file "lib/live_view_native_native.ex", fn file ->
            assert file =~ "LiveViewNativeNative"
          end

          assert_file "config/config.exs", fn file ->
            assert file =~ """
              config :live_view_native, plugins: [
                LiveViewNativeTest.GameBoy,
                LiveViewNativeTest.Switch
              ]
              """

            assert file =~ """
              config :mime, :types, %{
                "text/gameboy" => ["gameboy"],
                "text/switch" => ["switch"]
              }
              """

            assert file =~ """
              config :phoenix_template, format_encoders: [
                gameboy: Phoenix.HTML.Engine,
                switch: Phoenix.HTML.Engine
              ]
              """

            assert file =~ """
              config :phoenix, :template_engines,
                neex: LiveViewNative.Engine
              """
          end
        end)
      end
    end

    test "will raise with message if any arguments are given", config do
      in_tmp_live_umbrella_project config.test, fn ->
        File.cd!("live_view_native_web", fn ->
          assert_raise(Mix.Error, fn() ->
            Gen.run(["gameboy"])
          end)
          refute_file "lib/live_view_native_native.ex"
        end)
      end
    end
  end

  describe "config codgen scenarios" do
    test "when :live_view_native config exists the :plugins list is updated and duplicates are removed" do
      config = """
        config :live_view_native, plugins: [
          LiveViewNativeTest.Other,
          LiveViewNativeTest.Switch
        ]

        config :logger, :level, :debug
        """

      {_, result} = Gen.build_plugins({%{}, config})

      assert  result =~ """
        config :live_view_native, plugins: [
          LiveViewNativeTest.GameBoy,
          LiveViewNativeTest.Other,
          LiveViewNativeTest.Switch
        ]

        config :logger, :level, :debug
        """
    end

    test "when :mimes config exists the :types map is updated and duplicates are removed" do
      config = """
        config :mime, :types, %{
          "text/other" => ["other"],
          "text/switch" => ["switch"]
        }
        """

      {_, result} = Gen.patch_mime_types({%{}, config})

      assert result =~ """
        config :mime, :types, %{
          "text/gameboy" => ["gameboy"],
          "text/other" => ["other"],
          "text/switch" => ["switch"]
        }
        """
    end

    test "when :phonex_template config exists the :format_encoders list is updated and duplicates are removed" do
      config = """
        config :phoenix_template, :format_encoders, [
          other: Other.Engine,
          switch: Phoenix.HTML.Engine
        ]
        """

      {_, result} = Gen.patch_format_encoders({%{}, config})

      assert result =~ """
        config :phoenix_template, :format_encoders, [
          gameboy: Phoenix.HTML.Engine,
          other: Other.Engine,
          switch: Phoenix.HTML.Engine
        ]
        """
    end

    test "when :phonex config exists the :template_engines list is updated and duplicates are removed" do
      config = """
        config :phoenix, :template_engines, [
          other: Other.Engine,
        ]
        """

      {_, result} = Gen.patch_template_engines({%{}, config})

      assert result =~ """
        config :phoenix, :template_engines, [
          neex: LiveViewNative.Engine,
          other: Other.Engine
        ]
        """
    end
  end
end
