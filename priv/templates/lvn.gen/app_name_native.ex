defmodule <%= inspect context.native_module %> do
  import <%= inspect context.web_module %>, only: [verified_routes: 0]

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

  def component(opts) do
    opts = Keyword.take(opts, [:format, :root, :as])

    quote do
      use LiveViewNative.Component, unquote(opts)

      unquote(helpers(opts[:format]))
    end
  end

  def layout(opts) do
    opts = Keyword.take(opts, [:format, :root])

    quote do
      use LiveViewNative.Component, unquote(opts)

      import LiveViewNative.Component, only: [csrf_token: 1]

      unquote(helpers(opts[:format]))
    end
  end

  defp helpers(<%= if @live_form? do %>format<% else %>_format<% end %>) do
    <%= if @live_form? do %>plugin = LiveViewNative.fetch_plugin!(format)
    <% end %>quote do
      <%= if @gettext do %>import <%= inspect context.web_module %>.Gettext<% end %><%= if @live_form? do %>
      if function_exported?(unquote(plugin.component), :__native_opts__, 0) do
        import unquote(plugin.component)
      end
      if function_exported?(<%= inspect context.web_module %>.CoreComponents.unquote(Module.concat([plugin.module_suffix])), :__native_opts__, 0) do
        import <%= inspect context.web_module %>.CoreComponents.unquote(Module.concat([plugin.module_suffix]))
      end<% end %>
      unquote(verified_routes())
    end
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
