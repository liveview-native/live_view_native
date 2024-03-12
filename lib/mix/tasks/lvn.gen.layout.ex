defmodule Mix.Tasks.Lvn.Gen.Layout do
  alias Mix.LiveViewNative.Context

  def run(args) do
    context = Context.build(args, __MODULE__)

    files = files_to_be_generated(context)

    Context.prompt_for_conflicts(files)

    copy_new_files(context, files)
  end

  def switches, do: [
    context_app: :string,
    web: :string
  ]

  def validate_args!([]) do
    formats =
      LiveViewNative.available_formats()
      |> Enum.map(&("* #{&1}"))
      |> Enum.join("\n")

    Mix.raise("""
    You must pass a valid format. Available formats:
    #{formats}
    """)
  end

  def validate_args!([format | _] = args) do
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

  defp files_to_be_generated(%Context{format: format, context_app: context_app}) do
    web_prefix = Mix.Phoenix.web_path(context_app)

    components_path = Path.join(web_prefix, "components")
    layouts_path = Path.join(components_path, "layouts_#{format}")

    [
      {:eex, "layout.ex", Path.join(components_path, "layouts.#{format}.ex")},
      {:eex, "app.neex", Path.join(layouts_path, "app.#{format}.neex")},
      {:eex, "root.neex", Path.join(layouts_path, "root.#{format}.neex")}
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

    Mix.Phoenix.copy_from(apps, "priv/templates/lvn.gen.layout", binding, files)

    context
  end
end
