defmodule LiveViewNative.Renderer do
  defmacro __using__(opts) do
    quote do
      Module.register_attribute(__MODULE__, :liveview_native_opts, persist: true)
      Module.put_attribute(__MODULE__, :liveview_native_opts, %{
        format: unquote(opts[:format]),
        layout: unquote(opts[:layout])
      })

      @before_compile LiveViewNative.Renderer
    end
  end

  defmacro __before_compile__(%{module: module, file: file} = env) do
    render? = Module.defines?(module, {:render, 1})
    suppress_render_warning? = Application.get_env(:live_view_native, :suppress_render_warning, false)
    format = Module.get_attribute(module, :liveview_native_opts)[:format]

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
    root = Path.dirname(file)
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
    module
    |> Module.split()
    |> List.last()
    |> Macro.underscore()
    |> Kernel.<>(".#{format}*")
  end
end