defmodule Mix.Tasks.Lvn.Gen do
  alias Mix.LiveViewNative.Context

  def run(args) do
    context = Context.build(args, __MODULE__)

    files = files_to_be_generated(context)

    Context.prompt_for_conflicts(files)

    context
    |> copy_new_files(files)
    |> print_shell_instructions()
  end

  def print_shell_instructions(context) do
    context
    |> print_instructions()
    |> print_config()
    |> print_router()
    |> print_endpoint()
    |> print_post_instructions()
  end

  def last?(plugins, plugin) do
    Enum.at(plugins, -1) == plugin
  end

  defmacro compile_string(string) do
    EEx.compile_string(string)
  end

  def print_instructions(context) do
    """
    The following are configurations that should be added to your application.

    Follow each section as there are multiple files that require editing.
    """
    |> Mix.shell().info()

    context
  end

  def print_config(context) do
    plugins =
      LiveViewNative.plugins()
      |> Map.values()

    plugins? = length(plugins) > 0

    stylesheet? =
      Mix.Project.deps_apps()
      |> Enum.member?(:live_view_native_stylesheet)

    """
    \e[93;1m# config/config.exs\e[0m

    # LVN - registers each available plugin<%= unless plugins? do %>
    \e[93;1m# Hint: if you add this config to your app populated with client plugins
    # and run `mix lvn.gen` this configuration's placeholders will be populated\e[0m<% end %>
    config :live_view_native, plugins: [\e[32;1m<%= if plugins? do %><%= for plugin <- plugins do %>
      LiveViewNative.<%= plugin.module_suffix %><%= unless last?(plugins, plugin) do %>,<% end %><% end %><% else %>
      # LiveViewNative.SwiftUI<% end %>\e[0m
    ]

    # LVN - Each format must be registered as a mime type
    # add to existing configuration if one exists as this will
    # overwrite
    config :mime, :types, %{\e[32;1m<%= if plugins? do %><%= for plugin <- plugins do %>
      "text/<%= plugin.format %>" => ["<%= plugin.format %>"]<%= unless last?(plugins, plugin) do %>,<% end %><% end %><% else %>
      # "text/swiftui" => ["swiftui"]<% end %>\e[0m
    }

    <%= if stylesheet? do %># LVN - Required, you must configure LiveView Native Stylesheets
    # on which file path patterns class names should be extracted from
    config :live_view_native_stylesheet,
      content: [\e[32;1m<%= if plugins? do %><%= for plugin <- plugins do %>
        <%= plugin.format %>: [
          "lib/**/*<%= plugin.format %>*"
        ]<%= unless last?(plugins, plugin) do %>,<% end %><% end %><% else %>
        # swiftui: ["lib/**/*swiftui*"]<% end %>\e[0m
      ],
      output: "priv/static/assets"
    <% end %>
    # LVN - Required, you must configure Phoenix to know how
    # to encode for the swiftui format
    config :phoenix_template, :format_encoders, [\e[32;1m<%= if plugins? do %><%= for plugin <- plugins do %>
      <%= plugin.format %>: Phoenix.HTML.Engine<%= unless last?(plugins, plugin) do %>,<% end %><% end %><% else %>
      # swiftui: Phoenix.HTML.Engine<% end %>\e[0m
    ]

    # LVN - Required, you must configure Phoenix so it knows
    # how to compile LVN's neex templates
    config :phoenix, :template_engines, [
      \e[32;1mneex: LiveViewNative.Engine\e[0m
    ]
    """
    |> compile_string()
    |> Mix.shell().info()

    context
  end

  def print_router(context) do
    plugins =
      LiveViewNative.plugins()
      |> Map.values()

    plugins? = length(plugins) > 0

    layouts =
      [html: {Module.concat(context.web_module, Layouts), :root}]
      |> Kernel.++(
        plugins
        |> Enum.map(&({&1.format, {Module.concat([context.web_module, Layouts, &1.module_suffix]), :root}})
      ))

    """
    \e[93;1m# lib/<%= Phoenix.Naming.underscore(context.web_module) %>/router.ex\e[0m

    # add the formats to the `accepts` plug for the pipeline used by your LiveView Native app
    plug :accepts, [
      "html",\e[32;1m<%= if plugins? do %><%= for plugin <- plugins do %>
      "<%= plugin.format %>"<%= unless last?(plugins, plugin) do %>,<% end %><% end %><% else %>
      # "swiftui"<% end %>\e[0m
    ]

    # add the root layout for each format
    plug :put_root_layout, [
      html: <%= inspect(layouts[:html]) %>,\e[32;1m<%= if plugins? do %><%= for plugin <- plugins do %>
      <%= plugin.format %>: <%= inspect(layouts[plugin.format]) %><%= unless last?(plugins, plugin) do %>,<% end %><% end %><% else %>
      # swiftui: {<%= inspect(layouts[:html] |> elem(0)) %>, :root}<% end %>\e[0m
    ]
    """
    |> compile_string()
    |> Mix.shell().info()

    context
  end

  def print_endpoint(context) do
    """
    \e[93;1m# lib/<%= Phoenix.Naming.underscore(context.web_module) %>/endpoint.ex\e[0m

    # add the LiveViewNative.LiveRealoder to your endpoint
    if code_reloading? do
      socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
      plug Phoenix.LiveReloader
      \e[32;1mplug LiveViewNative.LiveReloader\e[0m
      plug Phoenix.CodeReloader
      plug Phoenix.Ecto.CheckRepoStatus, otp_app: :form_demo
    end
    """
    |> compile_string()
    |> Mix.shell.info()

    context
  end

  def print_post_instructions(context) do
    """
    After you have configured your application you should run the following:

    * `mix lvn.gen.layout <plaform>`
    * `mix lvn.gen.stylsheet <platform> App`
    """
    |> Mix.shell().info()

    context
  end

  def switches, do: [
    context_app: :string,
    web: :string
  ]

  def validate_args!([]), do: [nil]
  def validate_args!(_args) do
    Mix.raise("""
    mix lvn.gen does not take any arguments, only the following switches:

    --context-app
    --web
    """)
  end

  defp files_to_be_generated(context) do
    path = Mix.Phoenix.context_app_path(context.context_app, "lib")
    file = Phoenix.Naming.underscore(context.native_module) <> ".ex"

    [{:eex, "app_name_native.ex", Path.join(path, file)}]
  end

  defp copy_new_files(%Context{} = context, files) do
    plugins =
      LiveViewNative.plugins()
      |> Map.values()

    plugins? = length(plugins) > 0

    binding = [
      context: context,
      plugins: plugins,
      plugins?: plugins?,
      last?: &last?/2,
      assigns: %{
        gettext: true,
        formats: formats(),
        layouts: layouts(context.web_module)
      }
    ]

    Mix.Phoenix.copy_from([".", :live_view_native], "priv/templates/lvn.gen", binding, files)

    context
  end

  defp formats do
    LiveViewNative.available_formats()
  end

  defp layouts(web_module) do
    Enum.map(formats(), fn(format) ->
      format_module =
        format
        |> LiveViewNative.fetch_plugin!()
        |> Map.fetch!(:module_suffix)

      {format, {Module.concat([web_module, Layouts, format_module]), :app}}
    end)
  end
end
