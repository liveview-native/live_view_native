defmodule Mix.Tasks.Lvn.SetupTest do
  use ExUnit.Case

  import Mix.Lvn.TestHelper
  import ExUnit.CaptureIO

  @templates Path.join(File.cwd!(), "test/mix/tasks/templates")

  alias Mix.Tasks.Lvn.Setup.{Config, Gen}

  setup do
    Mix.Task.clear()
    :ok
  end

  describe "when a single app" do
    test "generates the `Native` module into the project's lib directory and injects config", config do
      in_tmp_live_project config.test, fn ->
        File.mkdir_p!("config")
        File.write!("config/config.exs", File.read!(Path.join(@templates, "config")))
        File.write!("config/dev.exs", File.read!(Path.join(@templates, "dev")))
        File.mkdir_p!("lib/live_view_native_web")
        File.write!("lib/live_view_native_web/endpoint.ex", File.read!(Path.join(@templates, "endpoint")))
        File.write!("lib/live_view_native_web/router.ex", File.read!(Path.join(@templates, "router")))

        capture_io("y\ny\ny\ny\n", fn ->
          Config.run([])
        end)

        Gen.run([])

        assert_file "lib/live_view_native_native.ex", fn file ->
          assert file =~ "LiveViewNativeNative"
        end

        assert_file "lib/live_view_native_web/components/layouts_gameboy/app.gameboy.neex"
        assert_file "lib/live_view_native_web/components/layouts_gameboy/root.gameboy.neex", fn file ->
          assert file =~ "app.gameboy"
        end
        assert_file "lib/live_view_native_web/components/layouts.gameboy.ex", fn file ->
          assert file =~ "LiveViewNativeNative"
        end

        assert_file "lib/live_view_native_web/components/layouts_switch/app.switch.neex"
        assert_file "lib/live_view_native_web/components/layouts_switch/root.switch.neex", fn file ->
          assert file =~ "app.switch"
        end
        assert_file "lib/live_view_native_web/components/layouts.switch.ex", fn file ->
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
            config :phoenix_template, :format_encoders, [
              gameboy: Phoenix.HTML.Engine,
              switch: Phoenix.HTML.Engine
            ]
            """

          assert file =~ """
            config :phoenix, :template_engines, [
              neex: LiveViewNative.Template.Engine
            ]
            """
        end

        assert_file "config/dev.exs", fn file ->
          assert file =~ """
            config :live_view_native, LiveViewNativeWeb.Endpoint,
              live_reload: [
                patterns: [
                  ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
                  ~r"priv/gettext/.*(po)$",
                  ~r"lib/live_view_native_web/(controllers|live|components)/.*(ex|heex)$",
                  ~r"lib/live_view_native_web/(live|components)/.*neex$"
                ]
              ]
            """
        end

        assert_file "lib/live_view_native_web/endpoint.ex", fn file ->
          assert file =~ """
              plug Phoenix.LiveReloader
              plug LiveViewNative.LiveReloader
          """
        end

        assert_file "lib/live_view_native_web/router.ex", fn file ->
          assert file =~ """
            pipeline :browser do
              plug :accepts, [
                "gameboy",
                "html",
                "switch"
              ]
              plug :fetch_session
              plug :fetch_live_flash

              plug :put_root_layout,
                gameboy: {LiveViewNativeWeb.Layouts.GameBoy, :root},
                html: {LiveViewNativeWeb.Layouts, :root},
                switch: {LiveViewNativeWeb.Layouts.Switch, :root}

              plug :protect_from_forgery
              plug :put_secure_browser_headers
            end
          """
        end
      end
    end

    test "will raise with message if any arguments are given", config do
      in_tmp_live_project config.test, fn ->
        assert_raise(Mix.Error, fn() ->
          Config.run(["gameboy"])
        end)
        refute_file "lib/live_view_native_native.ex"
      end
    end

    test "does not error when files are missing", config do
      in_tmp_live_project config.test, fn ->
        Config.run([])
      end
    end
  end

  describe "when an umbrella app" do
    test "generates the `Native` module into the project's lib directory", config do
      in_tmp_live_umbrella_project config.test, fn ->
        File.cd!("live_view_native_web", fn ->
          File.mkdir_p!("config")
          File.write!("config/config.exs", File.read!(Path.join(@templates, "config")))
          File.write!("config/dev.exs", File.read!(Path.join(@templates, "dev")))
          File.mkdir_p!("lib/live_view_native_web")
          File.write!("lib/live_view_native_web/endpoint.ex", File.read!(Path.join(@templates, "endpoint")))
          File.write!("lib/live_view_native_web/router.ex", File.read!(Path.join(@templates, "router")))


          capture_io("y\ny\ny\ny\n", fn ->
            Config.run([])
          end)

          Gen.run([])

          assert_file "lib/live_view_native_native.ex", fn file ->
            assert file =~ "LiveViewNativeNative"
          end

          assert_file "lib/live_view_native_web/components/layouts_gameboy/app.gameboy.neex"
          assert_file "lib/live_view_native_web/components/layouts_gameboy/root.gameboy.neex", fn file ->
            assert file =~ "app.gameboy"
          end
          assert_file "lib/live_view_native_web/components/layouts.gameboy.ex", fn file ->
            assert file =~ "LiveViewNativeNative"
          end

          assert_file "lib/live_view_native_web/components/layouts_switch/app.switch.neex"
          assert_file "lib/live_view_native_web/components/layouts_switch/root.switch.neex", fn file ->
            assert file =~ "app.switch"
          end
          assert_file "lib/live_view_native_web/components/layouts.switch.ex", fn file ->
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
              config :phoenix_template, :format_encoders, [
                gameboy: Phoenix.HTML.Engine,
                switch: Phoenix.HTML.Engine
              ]
              """

            assert file =~ """
              config :phoenix, :template_engines, [
                neex: LiveViewNative.Template.Engine
              ]
              """
          end

          assert_file "config/dev.exs", fn file ->
            assert file =~ """
              config :live_view_native, LiveViewNativeWeb.Endpoint,
                live_reload: [
                  patterns: [
                    ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
                    ~r"priv/gettext/.*(po)$",
                    ~r"lib/live_view_native_web/(controllers|live|components)/.*(ex|heex)$",
                    ~r"lib/live_view_native_web/(live|components)/.*neex$"
                  ]
                ]
              """
          end

          assert_file "lib/live_view_native_web/endpoint.ex", fn file ->
            assert file =~ """
                plug Phoenix.LiveReloader
                plug LiveViewNative.LiveReloader
            """
          end

          assert_file "lib/live_view_native_web/router.ex", fn file ->
            assert file =~ """
              pipeline :browser do
                plug :accepts, [
                  "gameboy",
                  "html",
                  "switch"
                ]
                plug :fetch_session
                plug :fetch_live_flash

                plug :put_root_layout,
                  gameboy: {LiveViewNativeWeb.Layouts.GameBoy, :root},
                  html: {LiveViewNativeWeb.Layouts, :root},
                  switch: {LiveViewNativeWeb.Layouts.Switch, :root}

                plug :protect_from_forgery
                plug :put_secure_browser_headers
              end
            """
          end
        end)
      end
    end

    test "will raise with message if any arguments are given", config do
      in_tmp_live_umbrella_project config.test, fn ->
        File.cd!("live_view_native_web", fn ->
          assert_raise(Mix.Error, fn() ->
            Config.run(["gameboy"])
          end)
          refute_file "lib/live_view_native_native.ex"
        end)
      end
    end
  end


  describe "Gettext support" do
    test "is available by default", config do
      in_tmp_live_project config.test, fn ->
        Gen.run([])

        assert_file "lib/live_view_native_native.ex", fn file ->
          assert file =~ "Gettext"
        end
      end
    end

    test "can be turned off via a switch", config do
      in_tmp_live_project config.test, fn ->
        Gen.run(["--no-gettext"])

        assert_file "lib/live_view_native_native.ex", fn file ->
          refute file =~ "Gettext"
        end
      end
    end
  end
end
