defmodule Mix.Tasks.Lvn.Gen.Live do
  use Mix.Task

  alias Mix.LiveViewNative.Context

  @shortdoc "Generates a new format specific LiveView rener component and template"

  @moduledoc """
  #{@shortdoc}

      $ mix lvn.gen.live swiftui Home

  """

  @impl true
  @doc false
  def run(args) do
    context = Context.build(args, __MODULE__)

    files = files_to_be_generated(context)

    Context.prompt_for_conflicts(files)

    copy_new_files(context, files)
  end

  @doc false
  def switches, do: [
    context_app: :string,
    web: :string
  ]

  @doc false
  def validate_args!([format, _name | _] = args) do
    cond do
      not Context.valid_format?(format) ->
        formats =
          LiveViewNative.available_formats()
          |> Enum.map(&("* #{&1}"))
          |> Enum.join("\n")

        Mix.raise("""
        #{format} is an unregistered format.
        Available formats:
        #{formats}

        Please see the documentation for how to register new LiveView Native plugins
        """)

      true ->
        args
    end
  end

  @doc false
  def validate_args!(_) do
    formats =
      LiveViewNative.available_formats()
      |> Enum.map(&("* #{&1}"))
      |> Enum.join("\n")

    Mix.raise("""
    You must pass a valid format and the name of the parent LiveView. Available formats:
    #{formats}

    Example: mix lvn.gen.live swiftui Home
    """)
  end

  defp files_to_be_generated(%Context{format: format, schema_module: schema_module, context_app: context_app}) do
    web_prefix = Mix.Phoenix.web_path(context_app)

    name =
      Module.concat([inspect(schema_module) <> "Live"])
      |> Macro.underscore()

    live_path = Path.join(web_prefix, "live")
    live_format_path = Path.join(live_path, "#{format}")

    [
      {:eex, "live.ex", Path.join(live_path, "#{name}.#{format}.ex")},
      {:eex, "template.neex", Path.join(live_format_path, "#{name}.#{format}.neex")}
    ]
  end

  defp copy_new_files(%Context{} = context, files) do
    binding = [
      context: context,
      assigns: %{
        gettext: true
      }
    ]

    apps = Context.apps(context.format)

    Mix.Phoenix.copy_from(apps, "priv/templates/lvn.gen.live", binding, files)

    context
  end
end
