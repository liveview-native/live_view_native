defmodule Mix.Tasks.Lvn.Gen do
  use Mix.Task

  alias Mix.LiveViewNative.Context

  import Mix.LiveViewNative.Context, only: [
    last?: 2
  ]

  @shortdoc "Generates the Native module"

  @moduledoc """
  #{@shortdoc}

      $ mix lvn.gen

  Instructions will be printed for configuring your application. And a
  new `Native` module will be copied into the `lib/` directory of your application.

  ## Options

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

    args
    |> Context.build(__MODULE__)
    |> gen()
  end

  def gen(context) do
    files = files_to_be_generated(context)
    Context.prompt_for_conflicts(files)
    copy_new_files(context, files)
  end

  @doc false
  def switches, do: [
    context_app: :string,
    web: :string,
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
