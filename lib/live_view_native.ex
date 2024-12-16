defmodule LiveViewNative do
  @moduledoc ~S'''
  This module should be used for creating new LiveView Native Clients.

  ## Configuration

  To use LiveView Native you must configure application
  to register LiveView Native plugins and instruct
  Phoenix on how to handle certain formats.

      # registers each plugin for use
      config :live_view_native, plugins: [
        LiveViewNative.SwiftUI,
        LiveViewNative.Jetpack
      ]

      # configure the mimetype for each plugin's format
      # refer to the plugin's documentation for each format
      # in nearly all cases the content-type should be `"text/:format"`
      config :mime, :types, %{
        "text/swiftui" => [:swiftui],
        "text/jetpack" => [:jetpack]
      }

      # configures the stylesheet for each format
      # refer to the documentation of `LiveViewNative.Stylesheet`
      # for more information on configuration options
      config :live_view_native_stylesheet,
        content: [
          swiftui: [
            "lib/**/*swiftui*"
          ],
          jetpack: [
            "lib/**/*jetpack*"
          ]
        ]

      # instructs Phoenix on how to encode a given format
      config :phoenix_template, :format_encoders, [
        swiftui: Phoenix.HTML.Engine,
        jetpack: Phoenix.HTML.Engine
      ]

      # instructs Phoenix on which engine to
      # use when compiling `neex` templates
      config :phoenix, :template_engines,
        neex: LiveViewNative.Engine

  Next you should add `LiveViewNative.LiveReloader` to your application's endpoint.

      if code_reloading? do
        socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
        plug Phoenix.LiveReloader

        # add here to ensure it is only enabled
        # when your application is configured for code reloading
        plug LiveViewNative.LiveReloader

  Finally you will need to configure your router's plugs

      plug :accepts, ["html", "swiftui", "jetpack"]
      plug :put_root_layout,
        html: {MyAppWeb.Layouts, :root},
        swiftui: {MyAppWeb.Layouts.SwiftUI, :root},
        jetpack: {MyAppWeb.Layouts.Jetpack, :root}

  Refer to the documentation in `LiveViewNative.Component` for more
  information on native layouts.

  You are now ready to create your first LiveView Native app. Refer to
  the documentation in `LiveViewNative.LiveView` on how to configure
  your live views for native.

  ## Enabling LiveView for Native

  Now that your application is configured you will need to enable a LiveView for Native.

  Assuming your application has the following LiveView route:

      live "/", HomeLive

  You'll need to add `use MyAppNative, :live_view` to that module:

      defmodule MyAppWeb.HomeLive do
        use MyAppWeb, :live_view
        use MyAppNative, :live_view

  Next you should use the `mix lvn.gen.live` task to generate
  the LiveView Native render component and template.

      > mix lvn.gen.live swiftui Home

  This will generate the following files in your project:

    * lib/my_app_web/live/home_live.swiftui.ex
    * lib/my_app_web/live/swiftui/home_live.swiftui.neex

  Just like a regular LiveView you can decide not to use the template and render
  templates in-line inside the render component:

      defmodule MyAppWeb.HomeLive.SwiftUI do
        use MyAppNative, [:render_component, format: :swiftui]

        def render(assigns, _interface) do
          ~LVN"""
          <Text>Hello, LiveView Native!</Text>
          """
        end
      end

  Note that unlike a regular LiveView that has `render/1` the
  LiveView Native render component uses `render/2` as the 2nd argument
  will include interface information about the client.

  You can read more in `LiveViewNative.Component`
  '''

  import LiveViewNative.Utils, only: [
    stringify: 1
  ]

  @doc """
  Uses LiveViewNative for creating new clients

      defmodule GameBoy do
        use LiveViewNative,
          format: :gameboy,
          component: GameBoy.Component,
          module_suffix: GameBoy,
          template_engine: LiveViewNative.Engine,
          client: GameBoy.Client
      end

  ## Options

    * `:format` - the format that will be used by Phoenix to determine the request
    and response encoding. Should be all lowercase and underscored
    * `:component` - module name of the client's component module to be used within
    render components
    * `:module_suffix` - the module name that will be assumed to be appended to
    liveviews for render components (i.e. MyAppWeb.HomeLive.GameBoy)
    * `:template_engine` - the engine for compiling a client's template. In nearly
    all cases `LiveViewNative.Engine` will be sufficient
  """
  defmacro __using__(config) do
    quote bind_quoted: [config: config] do
      defstruct format: config[:format],
        component: config[:component],
        module_suffix: config[:module_suffix],
        template_engine: config[:template_engine],
        stylesheet: config[:stylesheet],
        stylesheet_rules_parser: config[:stylesheet_rules_parser],
        client: config[:client]

      def __lvn_client__, do: true
    end
  end

  @doc"""
  Fetches a plugin based upon the format name

  Follows the same return types as `Map.fetch/2`
  """
  def fetch_plugin(format) do
    Map.fetch(plugins(), stringify(format))
  end

  @doc"""
  Fetches a plugin based upon the format name

  If the format is not present `LiveViewNative.PluginError` is raised
  """
  def fetch_plugin!(format) do
    case fetch_plugin(format) do
      {:ok, format} -> format
      :error -> raise LiveViewNative.PluginError, format
    end
  end

  @doc"""
  Returns a list of all available LiveView Native plugins

  Only the plugins that have been registered in your application
  config will be returned in the list
  """
  def plugins() do
    case Application.fetch_env(:live_view_native, :plugins_map) do
      {:ok, plugins} -> plugins
      :error ->
        plugins =
          Application.fetch_env(:live_view_native, :plugins)
          |> case do
            {:ok, plugins} ->
              Enum.map(plugins, fn(plugin) ->
                Code.ensure_compiled(plugin)
                struct(plugin)
              end)
            :error -> []
          end
          |> Enum.into(%{}, &({Atom.to_string(&1.format), &1}))

        :ok = Application.put_env(:live_view_native, :plugins_map, plugins)
        plugins
    end
  end

  @doc"""
  Returns a list of all available formats

  The format list is derived from the plugins returned by `LiveViewNative.plugins/0`
  """
  def available_formats() do
    plugins()
    |> Map.values()
    |> Enum.map(&(&1.format))
  end
end
