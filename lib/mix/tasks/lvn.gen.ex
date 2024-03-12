defmodule Mix.Tasks.Lvn.Gen do
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

  def validate_args!([]), do: [nil]
  def validate_args!(_args) do
    Mix.raise("""
    mix lvn.gen does not take any arguments, only the following switches:

    --context-app
    --web
    """)
  end

  defp files_to_be_generated(context) do
    path = Mix.Phoenix.context_app_path(context.context_app, "lib")
    file = Phoenix.Naming.underscore(context.native_module) <> ".ex"

    [{:eex, "app_name_native.ex", Path.join(path, file)}]
  end

  defp copy_new_files(%Context{} = context, files) do
    binding = [
      context: context,
      assigns: %{
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
