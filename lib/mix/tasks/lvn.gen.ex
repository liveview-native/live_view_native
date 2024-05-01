defmodule Mix.Tasks.Lvn.Gen do
  use Mix.Task

  alias Mix.LiveViewNative.Context
  import Mix.LiveViewNative.Context, only: [
    compile_string: 1,
    last?: 2
  ]

  @shortdoc "Generates the Native module and prints configuration instructions"

  @moduledoc """
  #{@shortdoc}

      $ mix lvn.gen

  Instructions will be printed for configuring your application. And a
  new `Native` module will be copied into the `lib/` directory of your application.

  ## Options

  * `--no-copy` - don't copy the `Native` module into your application
  * `--no-info` - don't print configuration info
  * `--no-live-form` - don't include `LiveViewNative.LiveForm` content in the `Native` module
  """

  @impl true
  @doc false
  def run(args) do
    if Mix.Project.umbrella?() do
      Mix.raise(
        "mix lvn.gen must be invoked from within your *_web application root directory"
      )
    end
    context = Context.build(args, __MODULE__)

    if Keyword.get(context.opts, :copy, true) do
      files = files_to_be_generated(context)
      Context.prompt_for_conflicts(files)

      copy_new_files(context, files)
    end

    if Keyword.get(context.opts, :info, true) do
      print_shell_instructions(context)
    end
  end

  defp print_shell_instructions(context) do
    context
    |> print_instructions()
    |> print_config()
    |> print_dev()
    |> print_router()
    |> print_endpoint()
  end

  defp print_instructions(context) do
    """
    The following are configurations that should be added to your application.

    Follow each section as there are multiple files that require editing.
    """
    |> Mix.shell().info()

    context
  end

  defp print_config(context) do
    plugins =
      LiveViewNative.plugins()
      |> Map.values()

    plugins? = length(plugins) > 0

    """
    \e[93;1m# config/config.exs\e[0m

    # \e[91;1mLVN - Required\e[0m
    # Registers each available plugin<%= unless plugins? do %>
    \e[93;1m# Hint: if you add this config to your app populated with client plugins
    # and run `mix lvn.gen` this configuration's placeholders will be populated\e[0m<% end %>
    config :live_view_native, plugins: [\e[32;1m<%= if plugins? do %><%= for plugin <- plugins do %>
      LiveViewNative.<%= plugin.module_suffix %><%= unless last?(plugins, plugin) do %>,<% end %><% end %><% else %>
      # LiveViewNative.SwiftUI<% end %>\e[0m
    ]

    # \e[91;1mLVN - Required\e[0m
    # Each format must be registered as a mime type add to
    # existing configuration if one exists as this will overwrite
    config :mime, :types, %{\e[32;1m<%= if plugins? do %><%= for plugin <- plugins do %>
      "text/<%= plugin.format %>" => ["<%= plugin.format %>"]<%= unless last?(plugins, plugin) do %>,<% end %><% end %><% else %>
      # "text/swiftui" => ["swiftui"]<% end %>\e[0m
    }

    # \e[91;1mLVN - Required\e[0m
    # Phoenix must know how to encode each LVN format
    config :phoenix_template, :format_encoders, [\e[32;1m<%= if plugins? do %><%= for plugin <- plugins do %>
      <%= plugin.format %>: Phoenix.HTML.Engine<%= unless last?(plugins, plugin) do %>,<% end %><% end %><% else %>
      # swiftui: Phoenix.HTML.Engine<% end %>\e[0m
    ]

    # \e[91;1mLVN - Required\e[0m
    # Phoenix must know how to compile neex templates
    config :phoenix, :template_engines, [
      \e[32;1mneex: LiveViewNative.Engine\e[0m
    ]
    """
    |> compile_string()
    |> Mix.shell().info()

    context
  end

  defp print_dev(context) do
    """
    \e[93;1m# config/dev.exs\e[0m

    # \e[36mLVN - Optional\e[0m
    # Allows LVN templates to be subject to LiveReload changes
    config :<% context.context_app %>, <%= inspect context.web_module %>.Endpoint,
      live_reload: [
        patterns: [
          ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
          ~r"priv/gettext/.*(po)$",
          ~r"lib/anotherone_web/(controllers|live|components)/.*(ex|heex\e[32;1m|neex\e[0m)$"
        ]
      ]
    """
    |> compile_string()
    |> Mix.shell().info()

    context
  end

  defp print_router(context) do
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
    \e[93;1m# lib/<%= Macro.underscore(context.web_module) %>/router.ex\e[0m

    # \e[91;1mLVN - Required\e[0m
    # add the formats to the `accepts` plug for the pipeline used by your LiveView Native app
    plug :accepts, [
      "html",\e[32;1m<%= if plugins? do %><%= for plugin <- plugins do %>
      "<%= plugin.format %>"<%= unless last?(plugins, plugin) do %>,<% end %><% end %><% else %>
      # "swiftui"<% end %>\e[0m
    ]

    # \e[91;1mLVN - Required\e[0m
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

  defp print_endpoint(context) do
    """
    \e[93;1m# lib/<%= Macro.underscore(context.web_module) %>/endpoint.ex\e[0m

    # \e[36mLVN - Optional\e[0m
    # Add the LiveViewNative.LiveRealoder to your endpoint
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

  @doc false
  def switches, do: [
    context_app: :string,
    web: :string,
    info: :boolean,
    copy: :boolean,
    live_form: :boolean
  ]

  @doc false
  def validate_args!([]), do: [nil]
  def validate_args!(_args) do
    Mix.raise("""
    mix lvn.gen does not take any arguments, only the following switches:

    --no-live-form
    --context-app
    --web
    """)
  end

  defp files_to_be_generated(context) do
    path =
      context.context_app
      |> Mix.Phoenix.web_path("..")
      |> Path.relative_to(File.cwd!())

    file = Macro.underscore(context.native_module) <> ".ex"

    [{:eex, "app_name_native.ex", Path.join(path, file)}]
  end

  defp copy_new_files(%Context{} = context, files) do
    plugins =
      LiveViewNative.plugins()
      |> Map.values()

    plugins? = length(plugins) > 0

    apps = Mix.Project.deps_apps()

    live_form? =
      Keyword.get(context.opts, :live_form, true) && Enum.member?(apps, :live_view_native_live_form)

    binding = [
      context: context,
      plugins: plugins,
      plugins?: plugins?,
      last?: &last?/2,
      assigns: %{
        live_form?: live_form?,
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
