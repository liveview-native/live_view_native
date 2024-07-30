defmodule Mix.Tasks.Lvn.Setup.Gen do
  use Mix.Task

  alias Mix.LiveViewNative.Context

  @shortdoc "Configure LiveView Native within a project"

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

    args
    |> Context.build(__MODULE__)
    |> run_generators()
  end

  @doc false
  def run_generators(context) do
    Mix.Project.deps_tree()
    |> Enum.filter(fn({_app, deps}) -> Enum.member?(deps, :live_view_native) end)
    |> Enum.reduce([generators(context)], fn({app, _deps}, acc) ->
      Application.spec(app)[:modules]
      |> Enum.find(fn(module) ->
        Regex.match?(~r/Mix\.Tasks\.Lvn\.(.+)\.Setup\.Gen/, Atom.to_string(module))
      end)
      |> case do
        nil -> acc
        setup_task ->
          if Kernel.function_exported?(setup_task, :generators, 1) do
            [setup_task.generators(context) | acc]
          else
            acc
          end
      end
    end)
    |> Enum.reverse()
    |> List.flatten()
    |> Enum.each(fn({task, args}) ->
      Mix.Task.reenable(task)
      Mix.Task.run(task, args)
    end)
  end

  def generators(_context) do
    plugins = Mix.LiveViewNative.plugins() |> Map.keys()

    layout_tasks = Enum.map(plugins, &({"lvn.gen.layout", [&1]}))

    [{"lvn.gen", []}] ++ layout_tasks
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
