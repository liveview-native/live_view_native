defmodule Mix.Tasks.Lvn.Gen do
  use Mix.Task

  alias Mix.LiveViewNative.{CodeGen, Context}
  alias Sourceror.Zipper

  import Mix.LiveViewNative.Context, only: [
    compile_string: 1,
    last?: 2
  ]

  import Mix.LiveViewNative.CodeGen, only: [
    build_patch: 2
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
  end

  @doc false
  def setup(context) do
    context
    |> patch_config()
    |> patch_dev()
    |> patch_endpoint()
    |> patch_router()
  end

  @doc false
  def patch_config(context) do
    original = config = File.read!("config/config.exs")

    {context, config}
    |> patch_plugins()
    |> patch_mime_types()
    |> patch_format_encoders()
    |> patch_template_engines()
    |> write_file("config/config.exs", original)

    context
  end

  @doc false
  def patch_plugins({context, config}) do
    plugins = Mix.LiveViewNative.plugins() |> Map.values()

    change = """
    config :live_view_native, plugins: [<%= for plugin <- plugins do %>
      <%= inspect plugin.__struct__ %><%= unless last?(plugins, plugin) do %>,<% end %><% end %>
    ]
    """
    |> compile_string()

    matcher = &(match?({:import_config, _, _}, &1))

    fail_msg = """
    failed to merge or inject the following in code into config/config.exs

    #{change}

    you can do this manually or inspect config/config.exs for errors and try again
    """

    config = CodeGen.patch(config, change, merge: &merge_plugins/2, inject: {:before, matcher}, fail_msg: fail_msg)

    {context, config}
  end

  defp merge_plugins(source, change) do
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
          %{node: {{:__block__, _, [:plugins]}, quoted_source_block}} ->
            {:config, _, [_, [{_, quoted_change_block}]]} = quoted_change
            range = Sourceror.get_range(quoted_source_block)
            source_list = Code.eval_quoted(quoted_source_block) |> elem(0)
            change_list = Code.eval_quoted(quoted_change_block) |> elem(0)

            plugins_list = (source_list ++ change_list) |> Enum.uniq() |> Enum.sort()

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

  @doc false
  def patch_mime_types({context, config}) do
    plugins = Mix.LiveViewNative.plugins() |> Map.values()

    change = """
    config :mime, :types, %{<%= for plugin <- plugins do %>
      "text/<%= plugin.format %>" => ["<%= plugin.format %>"]<%= unless last?(plugins, plugin) do %>,<% end %><% end %>
    }
    """
    |> compile_string()

    matcher = &(match?({:import_config, _, _}, &1))

    fail_msg = """
    failed to merge or inject the following in code into config/config.exs

    #{change}

    you can do this manually or inspect config/config.exs for errors and try again
    """

    config = CodeGen.patch(config, change, merge: &merge_mime_types/2, inject: {:before, matcher}, fail_msg: fail_msg)

    {context, config}
  end

  defp merge_mime_types(source, change) do
    quoted_change = Sourceror.parse_string!(change)

    source
    |> Sourceror.parse_string!()
    |> Zipper.zip()
    |> Zipper.find(&match?({:config, _, [{:__block__, _, [:mime]}, {:__block__, _, [:types]} | _]}, &1))
    |> case do
      nil -> :error
      %{node: {:config, _, [_, _, quoted_source_map]}} ->
        {:config, _, [_, _, quoted_change_map]} = quoted_change
        range = Sourceror.get_range(quoted_source_map)
        source_map = Code.eval_quoted(quoted_source_map) |> elem(0)
        change_map = Code.eval_quoted(quoted_change_map) |> elem(0)

        plugins_list = Map.merge(source_map, change_map) |> Map.to_list()

        change = """
          %{<%= for {mime_type, extension} = plugin <- plugins_list do %>
            <%= inspect mime_type %> => <%= inspect extension %><%= unless last?(plugins_list, plugin) do %>,<% end %><% end %>
          }
          """
          |> compile_string()
          |> String.trim()

        [build_patch(range, change)]
    end
  end

  @doc false
  def patch_format_encoders({context, config}) do
    plugins = Mix.LiveViewNative.plugins() |> Map.values()

    change = """
    config :phoenix_template, :format_encoders, [<%= for plugin <- plugins do %>
      <%= plugin.format %>: Phoenix.HTML.Engine<%= unless last?(plugins, plugin) do %>,<% end %><% end %>
    ]
    """
    |> compile_string()

    matcher = &(match?({:import_config, _, _}, &1))

    fail_msg = """
    failed to merge or inject the following in code into config/config.exs

    #{change}

    you can do this manually or inspect config/config.exs for errors and try again
    """

    config = CodeGen.patch(config, change, merge: &merge_format_encoders/2, inject: {:before, matcher}, fail_msg: fail_msg)

    {context, config}
  end

  defp merge_format_encoders(source, change) do
    quoted_change = Sourceror.parse_string!(change)

    source
    |> Sourceror.parse_string!()
    |> Zipper.zip()
    |> Zipper.find(&match?({:config, _, [{:__block__, _, [:phoenix_template]}, {:__block__, _, [:format_encoders]} | _]}, &1))
    |> case do
      nil -> :error
      %{node: {:config, _, [_, _, quoted_source_list]}} ->
        {:config, _, [_, _, quoted_change_list]} = quoted_change
        range = Sourceror.get_range(quoted_source_list)
        source_list = Code.eval_quoted(quoted_source_list) |> elem(0)
        change_list = Code.eval_quoted(quoted_change_list) |> elem(0)

        plugins_list =
          (source_list ++ change_list)
          |> Enum.uniq_by(fn({x, _}) -> x end)
          |> Enum.sort_by(fn({x, _}) -> x end)

        change = """
          [<%= for {format, encoder} = plugin <- plugins_list do %>
            <%= Atom.to_string(format) %>: <%= inspect encoder %><%= unless last?(plugins_list, plugin) do %>,<% end %><% end %>
          ]
          """
          |> compile_string()
          |> String.trim()

        [build_patch(range, change)]
    end
  end

  @doc false
  def patch_template_engines({context, config}) do
    change = """
    config :phoenix, :template_engines, [
      neex: LiveViewNative.Engine
    ]
    """
    |> compile_string()

    matcher = &(match?({:import_config, _, _}, &1))

    fail_msg = """
    failed to merge or inject the following in code into config/config.exs

    #{change}

    you can do this manually or inspect config/config.exs for errors and try again
    """

    config = CodeGen.patch(config, change, merge: &merge_template_engines/2, inject: {:before, matcher}, fail_msg: fail_msg)

    {context, config}
  end

  defp merge_template_engines(source, change) do
    quoted_change = Sourceror.parse_string!(change)

    source
    |> Sourceror.parse_string!()
    |> Zipper.zip()
    |> Zipper.find(&match?({:config, _, [{:__block__, _, [:phoenix]}, {:__block__, _, [:template_engines]} | _]}, &1))
    |> case do
      nil -> :error
      %{node: {:config, _, [_, _, quoted_source_list]}} ->
        {:config, _, [_, _, quoted_change_list]} = quoted_change
        range = Sourceror.get_range(quoted_source_list)
        source_list = Code.eval_quoted(quoted_source_list) |> elem(0)
        change_list = Code.eval_quoted(quoted_change_list) |> elem(0)

        plugins_list =
          (source_list ++ change_list)
          |> Enum.uniq_by(fn({x, _}) -> x end)
          |> Enum.sort_by(fn({x, _}) -> x end)

        change = """
          [<%= for {extension, engine} = plugin <- plugins_list do %>
            <%= Atom.to_string(extension) %>: <%= inspect engine %><%= unless last?(plugins_list, plugin) do %>,<% end %><% end %>
          ]
          """
          |> compile_string()
          |> String.trim()

        [build_patch(range, change)]
    end
  end

  @doc false
  def patch_dev(context) do
    original = dev = File.read!("config/dev.exs")

    {context, dev}
    |> patch_live_reload_patterns()
    |> write_file("config/dev.exs", original)

    context
  end

  @doc false
  def patch_live_reload_patterns({context, config}) do
    web_path = Mix.Phoenix.web_path(context.context_app)

    change = """
    [
      ~r"<%= web_path %>/(live|components)/.*neex$"
    ]
    """
    |> compile_string()

    fail_msg = """
    failed to merge the following live_reload pattern into config/dev.exs

    #{change}

    you can do this manually or inspect config/dev.exs for errors and try again
    """

    config = CodeGen.patch(config, change, merge: &merge_live_reload_patterns/2, fail_msg: fail_msg)

    {context, config}
  end

  defp merge_live_reload_patterns(source, change) do
    quoted_change_list = Sourceror.parse_string!(change)

    source
    |> Sourceror.parse_string!()
    |> Zipper.zip()
    |> Zipper.find(&match?({{:__block__, _, [:live_reload]}, {:__block__, _, [[{{:__block__, _, [:patterns]}, _patterns} | _]]}}, &1))
    |> case do
      nil -> :error
      %{node: {{:__block__, _, [:live_reload]}, {:__block__, _, [[{{:__block__, _, [:patterns]}, quoted_source_list} | _]]}}} ->
        range = Sourceror.get_range(quoted_source_list)
        {:__block__, _, [quoted_source_members]} = quoted_source_list
        {:__block__, _, [quoted_change_members]} = quoted_change_list

        source_list = Enum.map(quoted_source_members, &Sourceror.to_string/1)
        change_list = Enum.map(quoted_change_members, &Sourceror.to_string/1)

        patterns = Enum.uniq(source_list ++ change_list)

        change = """
          [<%= for pattern <- patterns do %>
            <%= pattern %><%= unless last?(patterns, pattern) do %>,<% end %><% end %>
          ]
          """
          |> compile_string()
          |> String.trim()

        [build_patch(range, change)]
    end
  end

  @doc false
  def patch_endpoint(context) do
    path =
      Mix.Phoenix.web_path(context.context_app)
      |> Path.join("endpoint.ex")

    original = endpoint = File.read!(path)

    change = "plug LiveViewNative.LiveReloader"

    matcher = &(match?({:plug, {}, [{:__aliases__, {}, [:Phoenix, :LiveReloader]}]}, &1))
    endpoint = CodeGen.patch(endpoint, change, inject: {:after, matcher})

    write_file({context, endpoint}, path, original)

    context
  end

  @doc false
  def patch_router(context) do
    path =
      Mix.Phoenix.web_path(context.context_app)
      |> Path.join("router.ex")

    original = router = File.read!(path)

    quoted_source = Sourceror.parse_string!(router)

    quoted_source
    |> Zipper.zip()
    |> Zipper.find(&(match?({:pipeline, _, [{:__block__, _, [:browser]} | _]}, &1)))
    |> case do
      nil -> Mix.shell.info("No browser pipeline!")
      _quoted_browser_pipeline ->
          {context, router}
          |> patch_accepts()
          |> patch_root_layouts()
          |> write_file(path, original)
    end

    context
  end

  def patch_accepts({context, router}) do
    change =
      Mix.LiveViewNative.plugins()
      |> Map.values()
      |> Enum.map(&(Atom.to_string(&1.format)))

    router = CodeGen.patch(router, change, merge: &merge_accepts/2)

    {context, router}
  end

  defp merge_accepts(source, new_formats) do
    source
    |> Sourceror.parse_string!()
    |> Zipper.zip()
    |> Zipper.find(&(match?({:pipeline, _, [{:__block__, _, [:browser]} | _]}, &1)))
    |> Zipper.find(&(match?({:plug, _, [{:__block__, _, [:accepts]} | _]}, &1)))
    |> case do
      nil ->
        """
        The :accepts plug is missing from the :browser pipeline.
        LiveView Native requires the following formats to be accepted: #{inspect new_formats}
        """
        |> Mix.shell.info()

      %{node: {:plug, _, [{:__block__, _, [:accepts]}, quoted_format_list]}}->
        range = Sourceror.get_range(quoted_format_list)
        old_formats = Code.eval_quoted(quoted_format_list) |> elem(0)

        formats = (old_formats ++ new_formats) |> Enum.uniq() |> Enum.sort()

        change = """
          [<%= for format <- formats do %>
            <%= inspect format %><%= unless last?(formats, format) do %>,<% end %><% end %>
          ]
          """
          |> compile_string()
          |> String.trim()

        [build_patch(range, change)]
    end
  end

  def patch_root_layouts({context, router}) do
    base_module =
      Mix.Phoenix.base()
      |> Mix.Phoenix.web_module()

    change =
      Mix.LiveViewNative.plugins()
      |> Map.values()
      |> Enum.map(fn(plugin) ->
        {plugin.format, {Module.concat([base_module, :Layouts, plugin.module_suffix]), :root}}
      end)

    router = CodeGen.patch(router, change, merge: &merge_root_layouts/2)

    {context, router}
  end

  defp merge_root_layouts(source, new_root_layouts) do
    source
    |> Sourceror.parse_string!()
    |> Zipper.zip()
    |> Zipper.find(&(match?({:pipeline, _, [{:__block__, _, [:browser]} | _]}, &1)))
    |> Zipper.find(&(match?({:plug, _, [{:__block__, _, [:put_root_layout]} | _]}, &1)))
    |> case do
      nil ->
        """
        The :put_root_layout plug is missing from the :browser pipeline.
        LiveView Native requires the following root_layouts: #{inspect new_root_layouts}
        """
        |> Mix.shell.info()

      %{node: {:plug, _, [{:__block__, _, [:put_root_layout]}, quoted_root_layouts]} = quoted_plug}->
        range = Sourceror.get_range(quoted_plug)
        old_root_layouts = Code.eval_quoted(quoted_root_layouts) |> elem(0)

        root_layouts =
          (old_root_layouts ++ new_root_layouts)
          |> Enum.uniq_by(fn({format, _}) -> format end)
          |> Enum.sort_by(fn({format, _}) -> format end)

        change = """
          plug :put_root_layout,<%= for {format, layout_tuple} = root_layout <- root_layouts do %>
            <%= format %>: <%= inspect layout_tuple %><%= unless last?(root_layouts, root_layout) do %>,<% end %><% end %>
          """
          |> compile_string()
          |> String.trim()

        [build_patch(range, change)]
    end
  end

  defp write_file({context, source}, path, original) do
    Rewrite.TextDiff.format(original, source)
    |> Mix.shell.info
    File.write!(path, source)
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
