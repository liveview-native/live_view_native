defmodule Mix.Tasks.Lvn.Gen do
  use Mix.Task

  alias Mix.LiveViewNative.Context
  alias Sourceror.Zipper

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
      setup(context)
    end

    if Keyword.get(context.opts, :info, true) do
      # print_shell_instructions(context)
    end
  end

  @doc false
  def setup(context) do
    config =
      File.read!("config/config.exs")

    dev =
      File.read!("config/dev.exs")

    context
    |> patch_config(config)
    |> patch_dev(dev)
  end

  @doc false
  def patch_config(context, config) do
    {context, config}
    |> build_plugins()
    # |> build_mime_types()
    # |> build_format_encoders()
    # |> build_template_engines()
    # |> write_file("config/config.exs", config)
  end

  def build_plugins({context, config}) do
    plugins = Mix.LiveViewNative.plugins() |> Map.values()

    patches = """
      config :live_view_native, :plugins, [<%= for plugin <- plugins do %>
        <%= inspect plugin.__struct__ %><%= unless last?(plugins, plugin) do %>,<% end %><% end %>
      ]
      """
      |> compile_string()
      |> Sourceror.parse_string!()
      |> generate_patches(Sourceror.parse_string!(config))

    config = Sourceror.patch_string(config, patches)

    {context, config}
  end

  defp generate_patches_for({:config, _meta, _args} = config, source_zip),
    do: generate_patches_for({:__block__, [], [config]}, source_zip)

  defp generate_patches_for({:__block__, _meta, blocks}, source) do
    Enum.reduce(blocks, {source, []}, &block_handler/2)
  end

  defp block_handler({:config, _meta, args} = quoted, {source, patches}) do
    range = Sourceror.get_range(quoted)

    kv = case args do
      [root_key, key, _opts] -> [root_key, key]
      [root_key, _opts] -> [root_key]
    end

    source
    |> Zipper.zip()
    # |> Zipper.find(&(match?({:config, _meta, }))
  end

  defp block_handler({:config, _meta, [root_key, opts]} = quoted, {source, patches}) do
      range = Sourceror.get_range(quoted)
  end

  defp merge_opts(source, change) when is_list(source) and is_list(change) do

  end

  defp merge_opts(source, change) when is_map(source) and is_map(change) do

  end

  @doc false
  def patch_plugins({context, config}) do
    plugins = Mix.LiveViewNative.plugins() |> Map.values()

    config =
      config
      |> Sourceror.parse_string!()
      |> Zipper.zip()
      |> Zipper.find(&match?({:config, _, [{:__block__, _, [:live_view_native]} | _]}, &1))
      |> case do
        nil ->
          %{start: [line: line, column: column], end: _} =
            config
            |> Sourceror.parse_string!()
            |> Zipper.zip()
            |> Zipper.find(&match?({:import_config, _, _}, &1))
            |> Zipper.node()
            |> Sourceror.get_range()

          range = %{
            start: [line: line, column: column],
            end: [line: line, column: column]
          }

          change = """
          config :live_view_native, plugins: [<%= for plugin <- plugins do %>
            <%= inspect plugin.__struct__ %><%= unless last?(plugins, plugin) do %>,<% end %><% end %>
          ]
          """
          |> compile_string()

          Sourceror.patch_string(config, [%{range: range, change: change}])

        zipper ->
          {_plugins_key, quoted_plugins_list} =
            zipper
            |> Zipper.subtree()
            |> Zipper.find(&match?({{:__block__, _, [:plugins]}, {:__block__, _, plugins_list}} when is_list(plugins_list), &1))
            |> Zipper.node()

          range = Sourceror.get_range(quoted_plugins_list)

          {existing_plugins, _} = Code.eval_quoted(quoted_plugins_list)
          plugins = Enum.map(plugins, &(&1.__struct__))

          plugins_list =
            (existing_plugins ++ plugins)
            |> Enum.uniq()
            |> Enum.sort()

          change = """
            [<%= for plugin <- plugins_list do %>
              <%= inspect plugin %><%= unless last?.(plugins_list, plugin) do %>,<% end %><% end %>
            ]
            """
            |> String.trim_trailing()
            |> EEx.eval_string(plugins_list: plugins_list, last?: &last?/2)

          Sourceror.patch_string(config, [%{range: range, change: change, preserve_indentation: false}])
      end

    {context, config}
  end

  @doc false
  def patch_mime_types({context, config}) do
    plugins = Mix.LiveViewNative.plugins() |> Map.values()

    config =
      config
      |> Sourceror.parse_string!()
      |> Zipper.zip()
      |> Zipper.find(&match?({:config, _, [{:__block__, _, [:mime]}, {:__block__, _, [:types]} | _]}, &1))
      |> case do
        nil ->
          %{start: [line: line, column: column], end: _} =
            config
            |> Sourceror.parse_string!()
            |> Zipper.zip()
            |> Zipper.find(&match?({:import_config, _, _}, &1))
            |> Zipper.node()
            |> Sourceror.get_range()

          range = %{
            start: [line: line, column: column],
            end: [line: line, column: column]
          }

          change = """
          config :mime, :types, %{<%= for plugin <- plugins do %>
            "text/<%= plugin.format %>" => ["<%= plugin.format %>"]<%= unless last?(plugins, plugin) do %>,<% end %><% end %>
          }

          """
          |> compile_string()

          Sourceror.patch_string(config, [%{range: range, change: change}])

        zipper ->
          quoted_map =
            zipper
            |> Zipper.subtree()
            |> Zipper.find(&match?({:%{}, _, _}, &1))
            |> Zipper.node()

          range = Sourceror.get_range(quoted_map)

          types =
            quoted_map
            |> Code.eval_quoted()
            |> elem(0)
            |> Map.values()
            |> Kernel.++(Enum.map(plugins, &(Atom.to_string(&1.format))))
            |> List.flatten()
            |> Enum.uniq()
            |> Enum.sort()

          change = """
            %{<%= for type <- types do %>
              "text/<%= type %>" => ["<%= type %>"]<%= unless last?.(types, type) do %>,<% end %><% end %>
            }
            """
            |> String.trim_trailing()
            |> EEx.eval_string(types: types, last?: &last?/2)

          Sourceror.patch_string(config, [%{range: range, change: change, preserve_indentation: false}])
      end

    {context, config}
  end

  @doc false
  def patch_format_encoders({context, config}) do
    plugins = Mix.LiveViewNative.plugins() |> Map.values()

    config =
      config
      |> Sourceror.parse_string!()
      |> Zipper.zip()
      |> Zipper.find(&match?({:config, _, [{:__block__, _, [:phoenix_template]}, {:__block__, _, [:format_encoders]} | _]}, &1))
      |> case do
        nil ->
          %{start: [line: line, column: column], end: _} =
            config
            |> Sourceror.parse_string!()
            |> Zipper.zip()
            |> Zipper.find(&match?({:import_config, _, _}, &1))
            |> Zipper.node()
            |> Sourceror.get_range()

          range = %{
            start: [line: line, column: column],
            end: [line: line, column: column]
          }

          change = """
          config :phoenix_template, format_encoders: [<%= for plugin <- plugins do %>
            <%= plugin.format %>: Phoenix.HTML.Engine<%= unless last?(plugins, plugin) do %>,<% end %><% end %>
          ]

          """
          |> compile_string()

          Sourceror.patch_string(config, [%{range: range, change: change}])

        zipper ->
          quoted =
            zipper
            |> Zipper.subtree()
            |> Zipper.find(&match?({:__block__, _, [encoders_list]} when is_list(encoders_list), &1))
            |> Zipper.node()

          range = Sourceror.get_range(quoted)

          encoders =
            quoted
            |> Code.eval_quoted()
            |> elem(0)
            |> Kernel.++(Enum.map(plugins, (&({&1.format, Phoenix.HTML.Engine}))))
            |> Enum.uniq()
            |> Enum.sort()

          change = """
            [<%= for {format, engine} = encoder <- encoders do %>
              <%= format %>: <%= inspect engine %><%= unless last?.(encoders, encoder) do %>,<% end %><% end %>
            ]
            """
            |> String.trim_trailing()
            |> EEx.eval_string(encoders: encoders, last?: &last?/2)

          Sourceror.patch_string(config, [%{range: range, change: change, preserve_indentation: false}])
      end

    {context, config}
  end

  @doc false
  def patch_template_engines({context, config}) do


    config =
      config
      |> Sourceror.parse_string!()
      |> Zipper.zip()
      |> Zipper.find(&match?({:config, _, [{:__block__, _, [:phoenix]}, {:__block__, _, [:template_engines]} | _]}, &1))
      |> case do
        nil ->
          %{start: [line: line, column: column], end: _} =
            config
            |> Sourceror.parse_string!()
            |> Zipper.zip()
            |> Zipper.find(&match?({:import_config, _, _}, &1))
            |> Zipper.node()
            |> Sourceror.get_range()

          range = %{
            start: [line: line, column: column],
            end: [line: line, column: column]
          }

          change = """
          config :phoenix, :template_engines,
            neex: LiveViewNative.Engine

          """
          |> compile_string()

          Sourceror.patch_string(config, [%{range: range, change: change}])

        zipper ->
          quoted =
            zipper
            |> Zipper.subtree()
            |> Zipper.find(&match?({:__block__, _, [engines_list]} when is_list(engines_list), &1))
            |> Zipper.node()

          range = Sourceror.get_range(quoted)

          template_engines =
            quoted
            |> Code.eval_quoted()
            |> elem(0)
            |> Kernel.++([neex: LiveViewNative.Engine])
            |> Enum.uniq()
            |> Enum.sort()

          change = """
            [<%= for {format, engine} = template_engine <- template_engines do %>
              <%= format %>: <%= inspect engine %><%= unless last?.(template_engines, template_engine) do %>,<% end %><% end %>
            ]
            """
            |> String.trim_trailing()
            |> EEx.eval_string(template_engines: template_engines, last?: &last?/2)

          Sourceror.patch_string(config, [%{range: range, change: change, preserve_indentation: false}])

      end

    {context, config}
  end

  defp write_file({context, config}, path, original) do

    File.write!(path, config)
  end

  def patch_dev(context, dev) do

    context
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
    plugins = Mix.LiveViewNative.plugins() |> Map.values()

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
    config :<%= context.context_app %>, <%= inspect context.web_module %>.Endpoint,
      live_reload: [
        patterns: [
          ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
          ~r"priv/gettext/.*(po)$",
          ~r"lib/anotherone_web/(controllers|live|components)/.*(ex|heex\e[32;1m|neex\e[0m)$",

          ~r"lib/anotherone_web/(live|components)/.*(ex|neex)$",
          ~r"priv/static/assets/*.styles$",
          ~r"lib/anotherone_web/(styles)/.*ex$"
        ]
      ]
    """
    |> compile_string()
    |> Mix.shell().info()

    context
  end

  defp print_router(context) do
    plugins = Mix.LiveViewNative.plugins() |> Map.values()

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
    # Add the LiveViewNative.LiveReloader to your endpoint
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
    plugins = Mix.LiveViewNative.plugins() |> Map.values()

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
