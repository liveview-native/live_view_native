defmodule LiveViewNative.Renderer do
  @moduledoc """
  This module contains logic on how template rendering and embedding is implemented
  """

  import LiveViewNative.Utils, only: [
    get_interface: 1,
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
  defmacro __inject_mix_recompile__(_env) do
    quote do
      @template_file_hash @template_files |> Enum.sort() |> :erlang.md5()

      @doc false
      def __mix_recompile__? do
        files =
          @embeded_templates_opts
          |> Enum.reduce([], fn({root, pattern, name}, templates_acc) ->
            root
            |> LiveViewNative.Renderer.find_templates(pattern, __MODULE__, name)
            |> Enum.reduce(templates_acc, fn
              {:no_embed, _reason}, templates_acc -> templates_acc
              {:embed, templates}, templates_acc -> templates_acc ++ templates
            end)
          end)

        file_hash =
          files
          |> Enum.sort()
          |> :erlang.md5()

        !(file_hash == @template_file_hash)
      end
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
        @doc false
        def unquote(name)(var!(assigns)) do
          interface = get_interface(var!(assigns))
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
    name = opts[:name]


    attr_ast = quote do
      Module.put_attribute(__MODULE__, :embeded_templates_opts, {
        unquote(root),
        unquote(pattern),
        unquote(name)
      })
    end

    templates_ast = root
    |> find_templates(pattern, module, name)
    |> Enum.map(&(__embed_templates__(&1,
      format: format,
      name: opts[:name],
      env: env,
      root: root,
      pattern: pattern
    )))

    [attr_ast | templates_ast]
  end

  @doc false
  def find_templates(root, pattern, module, default_name) do
    root
    |> Phoenix.Template.find_all(pattern)
    |> Enum.chunk_by(&chunk_name(&1))
    |> ensure_naming_uniq(pattern, default_name)
    |> Enum.map(fn(templates) ->
      name = build_name(templates, default_name)
      render? = case Code.ensure_compiled(module) do
        {:error, _} -> Module.defines?(module, {name, 2})
        {:module, _} -> false
      end

      case {render?, templates} do
        {true, [_template | _templates]} -> {:no_embed, :render_defined_with_templates}
        {true, []} -> {:no_embed, :render_defined_no_templates}
        {false, []} -> {:no_embed, :no_render_no_templates}
        {false, templates} -> {:embed, templates}
      end
    end)
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

  defp __embed_templates__({:no_embed, reason}, opts) do
    %{module: module} = env = opts[:env]
    name = build_name([], opts[:name])

    case reason do
      :render_defined_with_templates ->
        IO.warn(
          "You have #{module}.#{name}/2 defined as well as at least one template file. You must remove " <>
          " #{module}.#{name}/2 if you wish to use any template files.",
          Macro.Env.stacktrace(env)
        )

        []
      :render_defined_no_templates -> []
      :no_render_no_templates ->
        IO.warn(
          "You do not have any templates or any `render/2` functions defined for #{module}.",
          Macro.Env.stacktrace(env)
        )

        []
      _unmatched_reason -> []
    end
  end

  defp __embed_templates__({:embed, templates}, opts) do
    %{module: module} = opts[:env]
    format = opts[:format]
    name = build_name(templates, opts[:name])
    filename = build_filename(module, format)

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
            @template_files unquote(template)
            @doc false
            def unquote(name)(var!(assigns), _interface) do
              unquote(ast)
            end
          end

        target ->
          quote do
            @file unquote(template)
            @external_resource unquote(template)
            @template_files unquote(template)
            @doc false
            def unquote(name)(var!(assigns), %{"target" => unquote(target)}) do
              unquote(ast)
            end
          end
      end
    end)
    |> List.insert_at(-1, quote do
      delegate_to_target unquote(name)
    end)
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
