defmodule LiveViewNative.Renderer do
  import LiveViewNative.Utils, only: [
    stringify_format: 1
  ]

  defmacro __before_compile__(%{module: module}) do
    opts = Module.get_attribute(module, :native_opts)
    pattern = build_pattern(module, opts[:format])

    quote do
      embed_templates(unquote(pattern), root: unquote(opts[:root]), name: unquote(opts[:as]))
    end
  end

  defmacro delegate_to_target(name, opts \\ []) do
    %{module: module} = env = __CALLER__
    render? = Module.defines?(module, {name, 1})
    suppress_render_warning? = opts[:supress_warning] || Application.get_env(:live_view_native, :suppress_render_warning, false)

    if render? and !suppress_render_warning? do
      IO.warn(
        "#{module}.#{name}/1 is already defined. If you want to define your own and suppress this warning add:\n" <>
        "`config :live_view_native, suppress_render_warning: true`\nto your application config.",
        Macro.Env.stacktrace(env)
      )

      []
    else
      quote do
        def unquote(name)(var!(assigns)) do
          target = LiveViewNative.Utils.get_target(var!(assigns))
          apply(__MODULE__, unquote(name), [var!(assigns), %{target: target}])
        end
      end
    end
  end

  defmacro embed_templates(pattern, opts \\ []) do
    %{module: module} = env = __CALLER__
    native_opts = Module.get_attribute(module, :native_opts)
    format = native_opts[:format]

    root = build_root(env.file, opts[:root])

    root
    |> Phoenix.Template.find_all(pattern)
    |> Enum.chunk_by(&chunk_name(&1))
    |> Enum.map(&(__embed_templates__(&1,
      format: format,
      name: opts[:name],
      env: env,
      root: root,
      pattern: pattern
    )))
  end

  def chunk_name(template) do
    template
    |> Path.basename()
    |> String.split(".")
    |> List.first()
  end

  defp __embed_templates__(templates, opts \\ []) do
    %{module: module} = env = opts[:env]
    format = opts[:format]
    name = build_name(templates, opts[:name])

    render? = Module.defines?(module, {name, 2})
    filename = build_filename(module, format)

    case {render?, templates} do
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
                def unquote(name)(var!(assigns), _) do
                  unquote(ast)
                end
              end

            target ->
              quote do
                @file unquote(template)
                @external_resource unquote(template)
                def unquote(name)(var!(assigns), %{target: unquote(target)}) do
                  unquote(ast)
                end
              end
          end
        end)
        |> setup(templates, root: opts[:root], module: module, pattern: opts[:pattern])
    end
    |> inject_target_delegate(name)
  end

  defp setup(triplets, templates, opts) do
    Phoenix.Template.__idempotent_setup__(opts[:module],%{LiveViewNative.Engine => true})

    # Store the hashes so we define __mix_recompile__?
    hash = templates |> Enum.sort() |> :erlang.md5()

    Module.put_attribute(opts[:module], :phoenix_templates_hashes, {hash, [opts[:root], opts[:pattern]]})

    triplets
  end

  defp inject_target_delegate([], _name), do: []
  defp inject_target_delegate(quoted_renders, name) do
    quoted_render =
      quote do
        delegate_to_target unquote(name)
      end

    [quoted_render | quoted_renders]
  end

  defp extract_target(template, format) do
    Regex.scan(~r/#{format}\+(\w+)/, template)
    |> case do
      [[_, target] | _] -> target
      _ -> nil
    end
  end

  defp build_name([template | _tail], nil) do
    template
    |> chunk_name()
    |> Macro.underscore()
    |> String.to_atom()
  end

  defp build_name(_templates, name), do: name

  defp build_root(filename, nil), do: Path.dirname(filename)
  defp build_root(_filename, root), do: root

  defp build_filename(module, format) do
    module
    |> parent_module(format)
    |> Kernel.<>(".#{format}*")
  end

  defp build_pattern(module, format) do
    path = stringify_format(format)

    name =
      module
      |> parent_module(format)
      |> Kernel.<>("*")

    Path.join(path, name)
  end

  defp parent_module(module, format) do
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
      :error ->
        IO.warn("missing LiveViewNative plugin for format #{inspect(format)}")
    end
  end
end