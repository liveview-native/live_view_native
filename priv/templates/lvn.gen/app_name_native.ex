defmodule <%= inspect context.native_module %> do
  @moduledoc """
  The entrypoint for defining your native interfaces, such
  as components, render components, layouts, and live views.

  This can be used in your application as:

      use <%= inspect context.native_module %>, :live_view

  The definitions below will be executed for every
  component, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define additional modules and import
  those modules here.
  """

  import <%= inspect context.web_module %>, only: [verified_routes: 0]

  @doc ~S'''
  Set up an existing LiveView module for use with LiveView Native

      defmodule MyAppWeb.HomeLive do
        use MyAppWeb, :live_view
        use MyAppNative, :live_view
      end

  An `on_mount` callback will be injected that will negotiate
  the inbound connection content type. If it is a LiveView Native
  type the `render/1` will be delegated to the format-specific
  render component.
  '''
  def live_view() do<%= unless plugins? do %>
    # you do not have any plugins configured. Add a plugin to
    # config/config.exs
    #
    #    config :live_view_native, plugins: [
    #      LiveViewNative.SwiftUI
    #    ]
    #
    # then re-run `mix lvn.gen` and the placeholders in this file
    # will be populated<% end %>
    quote do
      use LiveViewNative.LiveView,
        formats: [<%= if plugins? do %><%= for plugin <- plugins do %>
          :<%= plugin.format %><%= unless last?.(plugins, plugin) do %>,<% end %><% end %><% else %>
          # :swiftui<% end %>
        ],
        layouts: [<%= if plugins? do %><%= for plugin <- plugins do %>
          <%= plugin.format %>: {<%= inspect(Module.concat([context.web_module, Layouts, plugin.module_suffix])) %>, :app}<%= unless last?.(plugins, plugin) do %>,<% end %><% end %><% else %>
          # swiftui: {<%= inspect(Module.concat([context.web_module, Layouts, SwiftUI])) %>, :app}<% end %>
        ]

      unquote(verified_routes())
    end
  end

  @doc ~S'''
  Set up a module as a LiveView Native format-specific render component

      defmodule MyAppWeb.HomeLive.SwiftUI do
        use MyAppNative, [:render_component, format: :swiftui]

        def render(assigns, _interface) do
          ~LVN"""
          <Text>Hello, world!</Text>
          """
        end
      end
  '''
  def render_component(opts) do
    opts =
      opts
      |> Keyword.take([:format])
      |> Keyword.put(:as, :render)

    quote do
      use LiveViewNative.Component, unquote(opts)

      unquote(helpers(opts[:format]))
    end
  end

  @doc ~S'''
  Set up a module as a LiveView Native Component

      defmodule MyAppWeb.Components.CustomSwiftUI do
        use MyAppNative, [:component, format: :swiftui]

        attr :msg, :string, :required
        def home_textk(assigns) do
          ~LVN"""
          <Text>@msg</Text>
          """
        end
      end

  LiveView Native Components are identical to Phoenix Components. Please
  refer to the `Phoenix.Component` documentation for more information.
  '''
  def component(opts) do
    opts = Keyword.take(opts, [:format, :root, :as])

    quote do
      use LiveViewNative.Component, unquote(opts)

      unquote(helpers(opts[:format]))
    end
  end

  @doc ~S'''
  Set up a module as a LiveView Natve Layout Component

      defmodule MyAppWeb.Layouts.SwiftUI do
        use MyAppNative, [:layout, format: :swiftui]

        embed_tempaltes "layouts_swiftui/*"
      end
  '''
  def layout(opts) do
    opts = Keyword.take(opts, [:format, :root])

    quote do
      use LiveViewNative.Component, unquote(opts)

      import LiveViewNative.Component, only: [csrf_token: 1]

      unquote(helpers(opts[:format]))
    end
  end

  defp helpers(<%= if @live_form? do %>format<% else %>_format<% end %>) do
    <%= if @gettext do %>gettext_quoted = quote do
      import <%= inspect context.web_module %>.Gettext
    end<% end %>
    <%= if @live_form? do %>
    plugin = LiveViewNative.fetch_plugin!(format)
    plugin_component_quoted = try do
      Code.ensure_compiled!(plugin.component)

      quote do
        import unquote(plugin.component)
      end
    rescue
      _ -> nil
    end

    live_form_quoted = quote do
      import LiveViewNative.LiveForm.Component
    end

    core_component_module = Module.concat([<%= inspect context.web_module %>, CoreComponents, plugin.module_suffix])

    core_component_quoted = try do
      Code.ensure_compiled!(core_component_module)

      quote do
        import unquote(core_component_module)
      end
    rescue
      _ -> nil
    end<% end %>

    <%= case {@gettext, @live_form?} do %>
      <% {true, true} -> %>[
        gettext_quoted,
        plugin_component_quoted,
        live_form_quoted,
        core_component_quoted,
        verified_routes()
      ]
      <% {false, true} -> %>[
        plugin_component_quoted,
        live_form_quoted,
        core_component_quoted,
        verified_routes()
      ]
      <% {true, false} -> %>[
        gettext_quoted,
        verified_routes()
      ]
      <% {false, false} -> %>[
        verified_routes()
      ]
    <% end %>
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__([which | opts]) when is_atom(which) do
    apply(__MODULE__, which, [opts])
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
