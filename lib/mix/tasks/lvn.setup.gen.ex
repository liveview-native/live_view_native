defmodule Mix.Tasks.Lvn.Setup.Gen do
  use Mix.Task

  alias Mix.LiveViewNative.Context

  @shortdoc "Run LiveView Native setup generators within a Phoenix LiveView application"

  @moduledoc """
  #{@shortdoc}

  This setup will

      $ mix lvn.setup.gen

    ## Options

    * `--no-gettext` - don't include Gettext support

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

    version = Application.spec(:live_view_native)[:vsn]

    """

    Now that your app is configured please follow these instructions for enabling a LiveView for LiveView Native
    https://hexdocs.pm/live_view_native/#{version}/LiveViewNative.html#module-enabling-liveview-for-native
    """
    |> Mix.shell.info()
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
        task ->
          Code.ensure_loaded(task)
          if Kernel.function_exported?(task, :generators, 1) do
            [task.generators(context) | acc]
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

  def generators(context) do
    plugins = Mix.LiveViewNative.plugins() |> Map.keys()

    apps = Mix.Project.deps_apps()

    gen_args =
      (Keyword.get(context.opts, :gettext, true) && Enum.member?(apps, :gettext))
      |> if do
        []
      else
        ["--no-gettext"]
      end

    layout_tasks = Enum.map(plugins, &({"lvn.gen.layout", [&1]}))

    [{"lvn.gen", gen_args}] ++ layout_tasks
  end

  @doc false
  def switches, do: [
    context_app: :string,
    web: :string,
    gettext: :boolean
  ]

  @doc false
  def validate_args!([]), do: [nil]
  def validate_args!(_args) do
    Mix.raise("""
    mix lvn.gen does not take any arguments, only the following switches:

    --context-app
    --web
    --no-gettext
    """)
  end
end
