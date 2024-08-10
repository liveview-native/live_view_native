defmodule Mix.LiveViewNative.CodeGen.PatchTest do
  use ExUnit.Case

  alias Mix.LiveViewNative.CodeGen.Patch

  describe "patch codegen scenarios" do
    test "when :live_view_native config exists the :plugins list is updated and duplicates are removed" do
      source = """
        config :live_view_native, plugins: [
          LiveViewNativeTest.Other,
          LiveViewNativeTest.Switch
        ]

        config :logger, :level, :debug
        """

      data = [
        LiveViewNativeTest.GameBoy,
        LiveViewNativeTest.Switch
      ]

      {:ok, result} = Patch.patch_plugins(%{}, data, source, "config/config.exs")

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
      source = """
        config :mime, :types, %{
          "text/other" => ["other"],
          "text/switch" => ["switch"]
        }
        """

      data = [:gameboy]

      {:ok, result} = Patch.patch_mime_types(%{}, data, source, "config/config.exs")

      assert result =~ """
        config :mime, :types, %{
          "text/gameboy" => ["gameboy"],
          "text/other" => ["other"],
          "text/switch" => ["switch"]
        }
        """
    end

    test "when :phonex_template config exists the :format_encoders list is updated and duplicates are removed" do
      source = """
        config :phoenix_template, :format_encoders, [
          other: Other.Engine,
          switch: Phoenix.HTML.Engine
        ]
        """

      data = [:gameboy]

      {:ok, result} = Patch.patch_format_encoders(%{}, data, source, "config/config.exs")

      assert result =~ """
        config :phoenix_template, :format_encoders, [
          gameboy: Phoenix.HTML.Engine,
          other: Other.Engine,
          switch: Phoenix.HTML.Engine
        ]
        """
    end

    test "when :phoenix config exists the :template_engines list is updated and duplicates are removed" do
      source = """
        config :phoenix, :template_engines, [
          other: Other.Engine,
        ]
        """

      data = [{:neex, LiveViewNative.Engine}]

      {:ok, result} = Patch.patch_template_engines(%{}, data, source, "config/config.exs")

      assert result =~ """
        config :phoenix, :template_engines, [
          neex: LiveViewNative.Engine,
          other: Other.Engine
        ]
        """
    end

    test "when an unexpected config exists" do
      source = """
        if false, do: config :logger, :level, :debug
        config :logger, :backends, []
        """

      data = [
        LiveViewNativeTest.GameBoy,
        LiveViewNativeTest.Switch
      ]

      {:ok, result} = Patch.patch_plugins(%{}, data, source, "config/config.exs")

      assert  result =~ """
        if false, do: config :logger, :level, :debug
        config :logger, :backends, []

        config :live_view_native, plugins: [
          LiveViewNativeTest.GameBoy,
          LiveViewNativeTest.Switch
        ]
        """
    end
  end

  describe "dev codgen scenarios" do
    test "when the :live_reload_patterns had additional keywords items" do
      source = """
        config :live_view_native, LiveViewNativeWeb.Endpoint,
          live_reload: [
            other: :thing,
            patterns: [
              ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
              ~r"priv/gettext/.*(po)$",
              ~r"lib/live_view_native_web/(controllers|live|components)/.*(ex|heex)$"
            ]
          ]
        """

      data = [
        ~s'~r"lib/live_view_native_web/(live|components)/.*neex$"'
      ]

      {:ok, result} = Patch.patch_live_reload_patterns(%{context_app: :live_view_native}, data, source, "config/config.exs")

      assert  result =~ """
        config :live_view_native, LiveViewNativeWeb.Endpoint,
          live_reload: [
            other: :thing,
            patterns: [
              ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
              ~r"priv/gettext/.*(po)$",
              ~r"lib/live_view_native_web/(controllers|live|components)/.*(ex|heex)$",
              ~r"lib/live_view_native_web/(live|components)/.*neex$"
            ]
          ]
        """
    end
  end

  describe "router codgen scenarios" do
    test "patch_layouts when this old style of router layout option is being used, rewrite as the new keyword list with html" do
      source = """
          pipeline :browser do
            plug :accepts, ["html"]
            plug :fetch_session
            plug :fetch_live_flash

            plug :put_root_layout, {LiveViewNativeWeb.Layouts, :root}

            plug :protect_from_forgery
            plug :put_secure_browser_headers
          end
        """

      data = [
        {:gameboy, {LiveViewNativeWeb.Layouts.GameBoy, :root}},
        {:switch, {LiveViewNativeWeb.Layouts.Switch, :root}},
      ]

      {:ok, result} = Patch.patch_root_layouts(%{}, data, source, "live_view_native_web/router.ex")

      assert result =~ """
        pipeline :browser do
          plug :accepts, ["html"]
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
