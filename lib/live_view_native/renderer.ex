defmodule LiveViewNative.Renderer do
  @moduledoc """
  This module contains logic on how template rendering and embedding is implemented
  """

  import LiveViewNative.Utils, only: [
    stringify_format: 1
  ]

  @doc false
  defmacro __before_compile__(%{module: module}) do
    opts = Module.get_attribute(module, :native_opts)
    pattern = build_pattern(module, opts[:format])

    quote do
      embed_templates(unquote(pattern), root: unquote(opts[:root]), name: unquote(opts[:as]))
    end
  end

  @doc false
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
          interface = LiveViewNative.Utils.get_interface(var!(assigns))
          apply(__MODULE__, unquote(name), [var!(assigns), interface])
        end
      end
    end
  end

  @doc """
  Embeds templates as render functions

  This function is mostly identical to `Phoenix.Component.embed_templates/2` but deviates in a few ways

  ## Options
    * `:format` - the format from the client. This will be used for template discovery, for the format
    `:swiftui` templates such as `home_live.swiftui.neex` will collected.
    * `:name` - the name of the generated function. Defaults to the name of the template, for example
    `app.swiftui.neex` will generate `app/2`. If this value is passed in there must only be a single template
    name matched. So if the pattern results in `['home_live.swiftui.neex', 'user_list.swiftui.neex']` and
    you pass `name: :render` there is ambiguity and will `raise`. The exception is when there are multiple
    targets for the same name: `['home_live.swiftui+watchos.neex', 'home_live.swiftui+tvos.neex', 'home_live.swiftui.neex']`
    if `name: :render` this will result:

      def render(assings, %{"target" => "watchos"} = interface)
      def render(assigns, %{"target" => "tvos"} = interface)
      def render(assigns, interface)

    the fallback function will always sort to render last. This allows for a greedy matcher if more than one target
    will be used for the same template.

    * `:root` - the location from which the `pattern` is applied to for finding templates. This is relative
    to the rendering module.
  """
  @doc type: :macro
  defmacro embed_templates(pattern, opts \\ []) do
    %{module: module} = env = __CALLER__
    native_opts = Module.get_attribute(module, :native_opts)
    format = native_opts[:format]

    root = build_root(env.file, opts[:root])

    root
    |> Phoenix.Template.find_all(pattern)
    |> Enum.chunk_by(&chunk_name(&1))
    |> ensure_naming_uniq(env, opts[:name])
    |> Enum.map(&(__embed_templates__(&1,
      format: format,
      name: opts[:name],
      env: env,
      root: root,
      pattern: pattern
    )))
  end

  # this function ensures there is a single template group when applying a custom render function name
  # if there is more than one grouping of templates and a custom render function name
  # then the naming is ambiguous and we `raise`
  defp ensure_naming_uniq([], _pattern, _name), do: []
  defp ensure_naming_uniq([_template_group] = templates, _pattern, name) when not is_nil(name) and is_atom(name), do: templates
  defp ensure_naming_uniq(templates, _pattern, nil), do: templates
  defp ensure_naming_uniq(templates, pattern, name) when not is_nil(name) and is_atom(name) do
    chunk_names =
      templates
      |> Enum.map(fn([template | _templates]) ->
        "* #{chunk_name(template)}"
      end)
      |> Enum.join("\n")

    raise ArgumentError,
      "cannot apply custom render function name `#{inspect(name)} " <>
      "when the following template groupings matched the pattern `#{inspect(pattern)}\n" <>
      chunk_names
  end


  defp chunk_name(template) do
    template
    |> Path.basename()
    |> String.split(".")
    |> List.first()
  end

  defp __embed_templates__(templates, opts) do
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
                def unquote(name)(var!(assigns), _interface) do
                  unquote(ast)
                end
              end

            target ->
              quote do
                @file unquote(template)
                @external_resource unquote(template)
                def unquote(name)(var!(assigns), %{"target" => unquote(target)}) do
                  unquote(ast)
                end
              end
          end
        end)
    end
    |> inject_target_delegate(name)
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
          plugin.module_suffix
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
