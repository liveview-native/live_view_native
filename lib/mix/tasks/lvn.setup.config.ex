defmodule Mix.Tasks.Lvn.Setup.Config do
  use Mix.Task

  alias Mix.LiveViewNative.Context

  import Mix.LiveViewNative.CodeGen.Patch, only: [
    doc_ref: 0,
    patch_plugins: 4,
    patch_mime_types: 4,
    patch_format_encoders: 4,
    patch_template_engines: 4,
    patch_live_reload_patterns: 4,
    patch_live_reloader: 4,
    patch_browser_pipeline: 4,
    write_file: 3
  ]

  @shortdoc "Configure LiveView Native within a Phoenix LiveView application"

  @moduledoc """
  #{@shortdoc}

  This setup will

      $ mix lvn.setup.config

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

    run_changesets(context, build_all_changesets())

    """

    Don't forget to run #{IO.ANSI.green()}#{IO.ANSI.bright()}mix lvn.setup.gen#{IO.ANSI.reset()}
    """
    |> Mix.shell.info()
  end

  @doc false
  defp build_all_changesets() do
    Mix.Project.deps_tree()
    |> Enum.filter(fn({_app, deps}) -> Enum.member?(deps, :live_view_native) end)
    |> Enum.reduce([&build_changesets/1], fn({app, _deps}, acc) ->
      Application.spec(app)[:modules]
      |> Enum.find(fn(module) ->
        Regex.match?(~r/Mix\.Tasks\.Lvn\.(.+)\.Setup\.Config/, Atom.to_string(module))
      end)
      |> case do
        nil -> acc
        task ->
          Code.ensure_loaded(task)
          if Kernel.function_exported?(task, :build_changesets, 1) do
            [&task.build_changesets/1 | acc]
          else
            acc
          end
      end
    end)
    |> Enum.reverse()
  end

  @doc false
  def config_path_for(file) do
    config_dir =
      Mix.Project.config()
      |> Keyword.fetch(:config_path)
      |> case do
        {:ok, path} -> Path.dirname(path)
        :error -> "config/"
      end

    Path.join(config_dir, file)
  end

  @doc false
  def build_changesets(context) do
    config_path = config_path_for("config.exs")
    dev_path = config_path_for("dev.exs")

    web_path = Mix.Phoenix.web_path(context.context_app)
    endpoint_path = Path.join(web_path, "endpoint.ex")
    router_path = Path.join(web_path, "router.ex")

    [
      {patch_plugins_data(context), &patch_plugins/4, config_path},
      {patch_mime_types_data(context), &patch_mime_types/4, config_path},
      {patch_format_encoders_data(context), &patch_format_encoders/4, config_path},
      {patch_template_engines_data(context), &patch_template_engines/4, config_path},
      {patch_live_reload_patterns_data(context), &patch_live_reload_patterns/4, dev_path},
      {nil, &patch_live_reloader/4, endpoint_path},
      {patch_browser_pipeline_data(context), &patch_browser_pipeline/4, router_path}
    ]
  end

  @doc false
  def run_changesets(context, changesets) do
    changesets
    |> List.wrap()
    |> Enum.map(&(&1.(context)))
    |> List.flatten()
    |> Enum.group_by(
      fn({_data, _patch_fn, path}) -> path end,
      fn({data, patch_fn, _path}) -> {data, patch_fn} end
    )
    |> Enum.each(fn({path, change_sets}) ->
      case File.read(path) do
        {:ok, source} ->
          source =
            change_sets
            |> Enum.group_by(
              fn({_data, patch_fn}) -> patch_fn end,
              fn({data, _patch_fn}) -> data end
            )
            |> Enum.reduce(source, fn({patch_fn, data}, source) ->
              case patch_fn.(context, data, source, path) do
                {:ok, source} -> source
                {:error, msg} ->
                  Mix.shell().info(msg)
                  source
              end
            end)

            write_file(context, source, path)
        {:error, _reason} ->
          """
          #{IO.ANSI.red()}#{IO.ANSI.bright()}Cannot read #{path} for configuration.#{IO.ANSI.reset()}

          #{doc_ref() |> String.trim()}
          """
          |> Mix.shell().info()
      end
    end)

    context
  end

  defp patch_plugins_data(_context) do
    Mix.LiveViewNative.plugins()
    |> Map.values()
    |> Enum.map(&(&1.__struct__))
  end

  defp patch_mime_types_data(_context) do
    Mix.LiveViewNative.plugins()
    |> Map.values()
    |> Enum.map(&(&1.format))
  end

  defp patch_format_encoders_data(_context) do
    Mix.LiveViewNative.plugins()
    |> Map.values()
    |> Enum.map(&(&1.format))
  end

  defp patch_template_engines_data(_context) do
    [{:neex, LiveViewNative.Template.Engine}]
  end

  defp patch_live_reload_patterns_data(context) do
    web_path = Mix.Phoenix.web_path(context.context_app)

    [~s'~r"#{web_path}/(live|components)/.*neex$"']
  end

  defp patch_browser_pipeline_data(context) do
    [
      accepts: patch_accepts_data(context),
      root_layouts: patch_root_layouts_data(context)
    ]
  end

  defp patch_accepts_data(_context) do
    Mix.LiveViewNative.plugins()
    |> Map.values()
    |> Enum.map(&(Atom.to_string(&1.format)))
  end

  defp patch_root_layouts_data(_context) do
    base_module =
      Mix.Phoenix.base()
      |> Mix.Phoenix.web_module()

    Mix.LiveViewNative.plugins()
    |> Map.values()
    |> Enum.map(fn(plugin) ->
      {plugin.format, {Module.concat([base_module, :Layouts, plugin.module_suffix]), :root}}
    end)
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
