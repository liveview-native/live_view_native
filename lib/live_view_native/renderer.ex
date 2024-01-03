defmodule LiveViewNative.Renderer do
  defmacro __before_compile__(%{module: module} = env) do
    render? = Module.defines?(module, {:render, 1})
    suppress_render_warning? = Application.get_env(:live_view_native, :suppress_render_warning, false)
    opts = Module.get_attribute(module, :native_opts)
    format = opts[:format]
    root = opts[:template_path]

    render_1_ast =
      if render? and !suppress_render_warning? do
        IO.warn(
          "#{module}.render/1 is already defined. If you want to define your own and suppress this warning add:\n" <>
          "`config :live_view_native, suppress_render_warning: true`\nto your application config.",
          Macro.Env.stacktrace(env)
        )

        []

      else
        quote do
          def render(%{socket: socket} = var!(assigns)) do
            target = LiveViewNative.Utils.get_target(socket)
            render(var!(assigns), %{target: target})
          end
        end
      end

    render_target? = Module.defines?(module, {:render, 2})
    filename = template_filename(module, format)
    templates = Phoenix.Template.find_all(root, filename)

    render_2_asts =
      case {render_target?, templates} do
        {true, [_template | _templates]} ->
          IO.warn(
            "You have #{module}.render/2 defined as well as at least one template file. You must remove " <>
            " #{module}.render/2 if you wish to use any template files.",
            Macro.Env.stacktrace(env)
          )

          []

        {true, []} -> []

        {false, []} ->
          IO.warn(
            "You do not have any templates or any `render/2` functions defined for #{module}.",
            Macro.Env.stacktrace(env)
          )

          []

        {false, templates} ->
          templates
          |> Enum.sort(&(String.length(&1) >= String.length(&2)))
          |> Enum.map(fn(template) ->

            engine = Map.fetch!(LiveViewNative.Template.engines(), format)
            ast = engine.compile(template, filename)

            case extract_target(template, format) do
              nil ->
                quote do
                  @file unquote(template)
                  @external_resource unquote(template)
                  def render(var!(assigns), _) do
                    unquote(ast)
                  end
                end

              target ->
                quote do
                  @file unquote(template)
                  @external_resource unquote(template)
                  def render(var!(assigns), %{target: unquote(target)}) do
                    unquote(ast)
                  end
                end
            end
          end)
      end

    [render_1_ast | render_2_asts]
  end

  defp extract_target(template, format) do
    Regex.scan(~r/#{format}\+(\w+)/, template)
    |> case do
      [[_, target] | _] -> target
      _ -> nil
    end
  end

  defp template_filename(module, format) do
    case LiveViewNative.fetch_plugin(format) do
      {:ok, plugin} ->
        module_suffix =
          plugin.module_suffix()
          |> Atom.to_string()

        module
        |> Module.split()
        |> Enum.reject(&(&1 == module_suffix))
        |> List.last()
        |> Macro.underscore()
        |> Kernel.<>(".#{format}*")
      :error ->
        IO.warn("missing LiveViewNative plugin for format #{inspect(format)}")

    end
  end
end