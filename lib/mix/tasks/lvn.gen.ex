defmodule Mix.Tasks.Lvn.Gen do
  alias Mix.Phoenix.Context

  @switches [
    context_app: :string
  ]

  def run(args) do
    context = build_context(args)

    binding = [context: context]

    paths = [".", :live_view_native]

    prompt_for_conflicts(context)

    context
    |> copy_new_files(binding, paths)
    |> maybe_inject_config()
    |> print_shell_instructions()
  end

  def build_context(args) do
    {opts, _parsed, _} = parse_opts(args)
    ctx_app = opts[:context_app] || Mix.Phoenix.context_app()
    base = Module.concat([Mix.Phoenix.context_base(ctx_app)])
    name = "#{inspect(base)}" <> "Native"
    module = Module.concat([name])
    basename = Phoenix.Naming.underscore(name)
    dir = Mix.Phoenix.context_app_path(ctx_app, Path.join("lib", basename))
    file = dir <> ".ex"

    %Context{
      base_module: base,
      name: name,
      module: module,
      file: file,
      generate?: false,
      context_app: ctx_app
    }
  end

  defp maybe_inject_config(context), do: context

  @doc false
  def print_shell_instructions(%Context{} = context) do
    context
    # prefix = Module.concat(context.web_module, schema.web_namespace)
    # web_path = Mix.Phoenix.web_path(ctx_app)

    # if schema.web_namespace do
    #   Mix.shell().info("""

    #   Add the live routes to your #{schema.web_namespace} :browser scope in #{web_path}/router.ex:

    #       scope "/#{schema.web_path}", #{inspect(prefix)}, as: :#{schema.web_path} do
    #         pipe_through :browser
    #         ...

    #   #{for line <- live_route_instructions(schema), do: "      #{line}"}
    #       end
    #   """)
    # else
    #   Mix.shell().info("""

    #   Add the live routes to your browser scope in #{Mix.Phoenix.web_path(ctx_app)}/router.ex:

    #   #{for line <- live_route_instructions(schema), do: "    #{line}"}
    #   """)
    # end

    # if context.generate?, do: Gen.Context.print_shell_instructions(context)
    # maybe_print_upgrade_info()
  end

  defp files_to_be_generated(context) do
    [{:eex, "app_name_native.ex", context.file}]
  end

  defp prompt_for_conflicts(context) do
    context
    |> files_to_be_generated()
    |> Mix.Phoenix.prompt_for_conflicts()
  end

  defp copy_new_files(%Context{} = context, binding, paths) do
    files = files_to_be_generated(context)
    web_module = Mix.Phoenix.web_module(context.base_module)

    binding =
      Keyword.merge(binding,
        assigns: %{
          gettext: true,
          formats: formats(),
          layouts: layouts(web_module),
          web_module: web_module
        }
      )

    Mix.Phoenix.copy_from(paths, "priv/templates/lvn.gen", binding, files)

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

  defp parse_opts(args) do
    {opts, parsed, invalid} = OptionParser.parse(args, switches: @switches)

    merged_opts = put_context_app(opts, opts[:context_app])

    {merged_opts, parsed, invalid}
  end

  defp put_context_app(opts, nil), do: opts

  defp put_context_app(opts, string) do
    Keyword.put(opts, :context_app, String.to_atom(string))
  end
end
