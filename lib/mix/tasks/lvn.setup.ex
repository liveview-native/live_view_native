defmodule Mix.Tasks.Lvn.Setup do
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

  @shortdoc "Setup LiveView Native within a project"

  @moduledoc """
  #{@shortdoc}

  This setup will

      $ mix lvn.setup

  ## Options

  * `--skip-generators` - don't generate any files
  * `--no-stylesheet` - don't run the LiveViewNative Stylesheet generator or merge configuration
  * `--no-live-form` - don't run the LiveViewNative LiveForm generator or merge configuration
  """

  @impl true
  @doc false
  def run(args) do
    if Mix.Project.umbrella?() do
      Mix.raise(
        "mix lvn.setup must be invoked from within your *_web application root directory"
      )
    end

    context = Context.build(args, __MODULE__)

    context
    |> run_setups()
    |> run_generators()
  end

  @doc false
  def run_setups(context) do
    web_path = Mix.Phoenix.web_path(context.context_app)

    source_files = build_file_map(%{
      config: "config/config.exs",
      dev: "config/dev.exs",
      endpoint: Path.join(web_path, "endpoint.ex"),
      router: Path.join(web_path, "router.ex")
    })

    Mix.Project.deps_tree()
    |> Enum.filter(fn({_app, deps}) -> Enum.member?(deps, :live_view_native) end)
    |> Enum.reduce([&setup/1], fn(app, acc) ->
      Application.spec(app)[:modules]
      |> Enum.find(fn(module) ->
        Regex.match?(~r/Mix\.Tasks\.Lvn\.(.+)\.Setup/, Atom.to_string(module))
      end)
      |> case do
        nil -> acc
        task ->
          if Kernel.function_exported?(task, :setup, 1) do
            [&task.setup/1 | acc]
          else
            acc
          end
      end
    end)
    |> Enum.reverse()
    |> Enum.reduce({context, source_files}, &(&1.(&2)))
    |> write_files()

    context
  end

  @doc false
  def run_generators(context) do
    task = &Mix.Tasks.Lvn.Gen.gen/1
    Mix.Project.deps_tree()
    |> Enum.filter(fn({_app, deps}) -> Enum.member?(deps, :live_view_native) end)
    |> Enum.reduce([task], fn(app, acc) ->
      Application.spec(app)[:modules]
      |> Enum.find(fn(module) ->
        Regex.match?(~r/Mix\.Tasks\.Lvn\.(.+)\.Gen/, Atom.to_string(module))
      end)
      |> case do
        nil -> acc
        task ->
          if Kernel.function_exported?(task, :gen, 1) do
            [&task.gen/1 | acc]
          else
            acc
          end
      end
    end)
    |> Enum.reverse()
    |> Enum.reduce(context, &(&1.(&2)))
  end

  @doc false
  def build_file_map(file_map) do
    Enum.into(file_map, %{}, fn({key, path}) ->
      {key, {File.read!(path), path}}
    end)
  end

  @doc false
  def setup({context, source_files}) do
    {context, source_files}
    |> patch_config()
    |> patch_dev()
    |> patch_endpoint()
    |> patch_router()
  end

  @doc false
  def patch_config({context, %{config: {source, path}} = source_files}) do
    {_context, source} =
      {context, source}
      |> patch_plugins()
      |> patch_mime_types()
      |> patch_format_encoders()
      |> patch_template_engines()

    {context, %{source_files | config: {source, path}}}
  end

  @doc false
  def patch_plugins({context, source}) do
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

    source = CodeGen.patch(source, change, merge: &merge_plugins/2, inject: {:before, matcher}, fail_msg: fail_msg)

    {context, source}
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
  def patch_mime_types({context, source}) do
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

    source = CodeGen.patch(source, change, merge: &merge_mime_types/2, inject: {:before, matcher}, fail_msg: fail_msg)

    {context, source}
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
  def patch_format_encoders({context, source}) do
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

    source = CodeGen.patch(source, change, merge: &merge_format_encoders/2, inject: {:before, matcher}, fail_msg: fail_msg)

    {context, source}
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
  def patch_template_engines({context, source}) do
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

    source = CodeGen.patch(source, change, merge: &merge_template_engines/2, inject: {:before, matcher}, fail_msg: fail_msg)

    {context, source}
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
  def patch_dev({context, %{dev: {source, path}} = source_files}) do

    {_context, source} =
      {context, source}
      |> patch_live_reload_patterns()

    {context, %{source_files | dev: {source, path}}}
  end

  @doc false
  def patch_live_reload_patterns({context, source}) do
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

    source = CodeGen.patch(source, change, merge: &merge_live_reload_patterns/2, fail_msg: fail_msg)

    {context, source}
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
  def patch_endpoint({context, %{endpoint: {source ,path}} = source_files}) do
    change = "plug LiveViewNative.LiveReloader"

    matcher = &(match?({:plug, {}, [{:__aliases__, {}, [:Phoenix, :LiveReloader]}]}, &1))
    source = CodeGen.patch(source, change, inject: {:after, matcher})

    {context, %{source_files | endpoint: {source, path}}}
  end

  @doc false
  def patch_router({context, %{router: {source, path}} = source_files}) do
    quoted_source = Sourceror.parse_string!(source)

    quoted_source
    |> Zipper.zip()
    |> Zipper.find(&(match?({:pipeline, _, [{:__block__, _, [:browser]} | _]}, &1)))
    |> case do
      nil ->
        Mix.shell.info("No browser pipeline!")
        {context, source_files}

      _quoted_browser_pipeline ->
          {_context, source} =
            {context, source}
            |> patch_accepts()
            |> patch_root_layouts()

          {context, %{source_files | router: {source, path}}}
    end
  end

  @doc false
  def patch_accepts({context, source}) do
    change =
      Mix.LiveViewNative.plugins()
      |> Map.values()
      |> Enum.map(&(Atom.to_string(&1.format)))

    source = CodeGen.patch(source, change, merge: &merge_accepts/2)

    {context, source}
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

  @doc false
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

  @doc false
  def write_files({context, source_files}) do
    Enum.each(source_files, fn({_key, {source, path}}) ->
      write_file({context, {source, path}})
    end)
  end

  defp write_file({context, {source, path}}) do
    original = File.read!(path)

    Rewrite.TextDiff.format(original, source)
    |> Mix.shell.info

    File.write!(path, source)
  end

  @doc false
  def switches, do: [
    context_app: :string,
    web: :string,
    stylesheet: :boolean,
    live_form: :boolean
  ]

  @doc false
  def validate_args!([]), do: [nil]
  def validate_args!(_args) do
    Mix.raise("""
    mix lvn.gen does not take any arguments, only the following switches:

    --context-app
    --web
    --no-stylesheet
    --no-live-form
    """)
  end
end
