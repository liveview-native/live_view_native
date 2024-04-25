defmodule Mix.Tasks.Lvn.Setup do
  use Mix.Task

  alias Mix.Tasks.Phx.Gen
  alias Mix.LiveViewNative.Context

  @shortdoc "Setup LiveView Native within a project"

  @moduledoc """
  #{@shortdoc}

      $ mix lvn.setup

  ## Options

  * `--no-stylesheet` - don't print `LiveViewNative.Stylesheet` config info and don't run `lvn.stylesheet.gen`
  * `--no-live-form` - don't include `LiveViewNative.LiveForm` content in the `Native` module
  """

  @impl true
  @doc false
  def run(args) do
    context = Context.build(args, __MODULE__)

    plugins =
      LiveViewNative.plugins()
      |> Map.values()

    plugins? = length(plugins) > 0

    apps = Mix.Project.deps_apps()

    stylesheet_opt? = Keyword.get(context.opts, :stylesheet, true)
    stylesheet_app? = Enum.member?(apps, :live_view_native_stylesheet)
    stylesheet? = stylesheet_opt? && stylesheet_app?

    live_form_opt? = Keyword.get(context.opts, :live_form, true)
    live_form_app? = Enum.member?(apps, :live_view_native_live_form)

    if !plugins? do
      Mix.shell().info("""
      You have no client plugins configured. `mix lvn.setup` requires
      at least one LiveView Native client plugin configured. Add one LVN client
      as a dependency then configure it. For example, if you have both `live_view_native_swiftui`
      and `live_view_native_jetpack` added as dependencies you would add the following:

      \e[93;1m# config/config.exs\e[0m

      \e[32;1mconfig :live_view_native, plugins: [
        LiveViewNative.Jetpack,
        LiveViewNative.SwiftUI
      ]\e[0m
      """)
    end

    if stylesheet_opt? && !stylesheet_app? do
      Mix.shell().info("""
      `live_view_native_styelsheet` is not included as a dependency. Please add it and re-run
      this setup task. If you do not wish to use `live_view_native_stylesheet` run this task as
      `mix lvn.setup --no-stylesheet`
      """)
    end

    if live_form_opt? && !live_form_app? do
       Mix.shell().info("""
       `live_view_native_live_form` is not included as a dependency. Please add it and re-run
       this setup task. If you do not wish to generate `live_form` components run this task
       as `mix lvn.setup --no-live-form`
       """)
    end

    if plugins? &&
      ((stylesheet_opt? && stylesheet_app?) || !stylesheet_opt?) &&
      ((live_form_opt? && live_form_app?) || !live_form_opt?) do
      Mix.Task.run("lvn.gen", ["--no-info"])

      Enum.each(plugins, fn(plugin) ->
        format = Atom.to_string(plugin.format)

        args = if !live_form_opt? do
          ["--no-live-form"]
        else
          []
        end

        format_task_gen_module = Module.concat([Mix.Tasks.Lvn, Macro.camelize(format), Gen])

        if Mix.Task.task?(format_task_gen_module) do
          Mix.Task.run("lvn.#{format}.gen", args)
        end

        Mix.Task.run("lvn.gen.layout", [format])

        if stylesheet? do
          Mix.Task.run("lvn.stylesheet.gen", [format, "App", "--no-info"])
        end
      end)

      Mix.Task.rerun("lvn.gen", ["--no-copy"])

      if stylesheet? do
        Mix.Task.rerun("lvn.stylesheet.gen", ["--no-copy"])
      end
    end
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
