defmodule Mix.LiveViewNative.CodeGen.Patch do
  @moduledoc false

  import Mix.LiveViewNative.Context, only: [
    compile_string: 1,
    last?: 2
  ]

  import Mix.LiveViewNative.CodeGen, only: [
    build_patch: 2
  ]

  alias Mix.LiveViewNative.CodeGen
  alias Sourceror.Zipper

  @doc false
  def patch_plugins(_context, plugins, source, path) do
    plugins =
      plugins
      |> List.flatten()
      |> Enum.uniq()
      |> Enum.sort()

    change = """

    config :live_view_native, plugins: [<%= for plugin <- plugins do %>
      <%= inspect plugin %><%= unless last?(plugins, plugin) do %>,<% end %><% end %>
    ]
    """
    |> compile_string()

    fail_msg = fail_msg("inject", "code", path, change, &doc_ref/0)

    CodeGen.patch(source, change, merge: &merge_plugins/2, inject: {:after, {:last, &config_matcher/1}}, fail_msg: fail_msg, path: path)
  end

  defp merge_plugins(source, change) do
    quoted_change = Sourceror.parse_string!(change)

    source
    |> Sourceror.parse_string!()
    |> Zipper.zip()
    |> Zipper.find(&match?({:config, _, [{:__block__, _, [:live_view_native]} | _]}, &1))
    |> case do
      nil -> :error
      found ->
        Zipper.find(found, &match?({{:__block__, _, [:plugins]}, _}, &1))
        |> case do
          nil -> :error
          %{node: {{:__block__, _, [:plugins]}, quoted_source_block}} ->
            {:config, _, [_, [{_, quoted_change_block}]]} = quoted_change
            range = Sourceror.get_range(quoted_source_block)
            source_list = Code.eval_quoted(quoted_source_block) |> elem(0)
            change_list = Code.eval_quoted(quoted_change_block) |> elem(0)

            plugins_list = (source_list ++ change_list) |> Enum.uniq() |> Enum.sort()

            change = """
              [<%= for plugin <- plugins_list do %>
                <%= inspect plugin %><%= unless last?(plugins_list, plugin) do %>,<% end %><% end %>
              ]
              """
              |> compile_string()
              |> String.trim()

            [build_patch(range, change)]
        end
    end
  end

  @doc false
  def patch_mime_types(_context, formats, source, path) do
    formats =
      formats
      |> List.flatten()
      |> Enum.uniq()
      |> Enum.sort()

    change = """

    config :mime, :types, %{<%= for format <- formats do %>
      "text/<%= format %>" => ["<%= format %>"]<%= unless last?(formats, format) do %>,<% end %><% end %>
    }
    """
    |> compile_string()

    fail_msg = fail_msg("inject", "code", path, change, &doc_ref/0)

    CodeGen.patch(source, change, merge: &merge_mime_types/2, inject: {:after, {:last, &config_matcher/1}}, fail_msg: fail_msg, path: path)
  end

  defp merge_mime_types(source, change) do
    quoted_change = Sourceror.parse_string!(change)

    source
    |> Sourceror.parse_string!()
    |> Zipper.zip()
    |> Zipper.find(&match?({:config, _, [{:__block__, _, [:mime]}, {:__block__, _, [:types]} | _]}, &1))
    |> case do
      nil -> :error
      %{node: {:config, _, [_, _, quoted_source_map]}} ->
        {:config, _, [_, _, quoted_change_map]} = quoted_change
        range = Sourceror.get_range(quoted_source_map)
        source_map = Code.eval_quoted(quoted_source_map) |> elem(0)
        change_map = Code.eval_quoted(quoted_change_map) |> elem(0)

        plugins_list = Map.merge(source_map, change_map) |> Map.to_list()

        change = """
          %{<%= for {mime_type, extension} = plugin <- plugins_list do %>
            <%= inspect mime_type %> => <%= inspect extension %><%= unless last?(plugins_list, plugin) do %>,<% end %><% end %>
          }
          """
          |> compile_string()
          |> String.trim()

        [build_patch(range, change)]
    end
  end

  @doc false
  def patch_format_encoders(_context, formats, source, path) do
    formats =
      formats
      |> List.flatten()
      |> Enum.uniq()
      |> Enum.sort()

    change = """

    config :phoenix_template, :format_encoders, [<%= for format <- formats do %>
      <%= format %>: Phoenix.HTML.Engine<%= unless last?(formats, format) do %>,<% end %><% end %>
    ]
    """
    |> compile_string()

    fail_msg = fail_msg("inject", "code", path, change, &doc_ref/0)

    CodeGen.patch(source, change, merge: &merge_format_encoders/2, inject: {:after, {:last, &config_matcher/1}}, fail_msg: fail_msg, path: path)
  end

  defp merge_format_encoders(source, change) do
    quoted_change = Sourceror.parse_string!(change)

    source
    |> Sourceror.parse_string!()
    |> Zipper.zip()
    |> Zipper.find(&match?({:config, _, [{:__block__, _, [:phoenix_template]}, {:__block__, _, [:format_encoders]} | _]}, &1))
    |> case do
      nil -> :error
      %{node: {:config, _, [_, _, quoted_source_list]}} ->
        {:config, _, [_, _, quoted_change_list]} = quoted_change
        range = Sourceror.get_range(quoted_source_list)
        source_list = Code.eval_quoted(quoted_source_list) |> elem(0)
        change_list = Code.eval_quoted(quoted_change_list) |> elem(0)

        plugins_list =
          (source_list ++ change_list)
          |> Enum.uniq_by(fn({x, _}) -> x end)
          |> Enum.sort_by(fn({x, _}) -> x end)

        change = """
          [<%= for {format, encoder} = plugin <- plugins_list do %>
            <%= Atom.to_string(format) %>: <%= inspect encoder %><%= unless last?(plugins_list, plugin) do %>,<% end %><% end %>
          ]
          """
          |> compile_string()
          |> String.trim()

        [build_patch(range, change)]
    end
  end

  @doc false
  def patch_template_engines(_context, template_engines, source, path) do
    template_engines =
      template_engines
      |> List.flatten()
      |> Enum.uniq_by(fn({ext, _engine}) -> ext end)
      |> Enum.sort_by(fn({ext, _engine}) -> ext end)

    change = """

    config :phoenix, :template_engines, [<%= for {ext, engine} <- template_engines do %>
      <%= ext%>: <%= inspect engine %><%= unless last?(template_engines, {ext, engine}) do %>,<% end %><% end %>
    ]
    """
    |> compile_string()

    fail_msg = fail_msg("inject", "code", path, change, &doc_ref/0)

    CodeGen.patch(source, change, merge: &merge_template_engines/2, inject: {:after, {:last, &config_matcher/1}}, fail_msg: fail_msg, path: path)
  end

  defp merge_template_engines(source, change) do
    quoted_change = Sourceror.parse_string!(change)

    source
    |> Sourceror.parse_string!()
    |> Zipper.zip()
    |> Zipper.find(&match?({:config, _, [{:__block__, _, [:phoenix]}, {:__block__, _, [:template_engines]} | _]}, &1))
    |> case do
      nil -> :error
      %{node: {:config, _, [_, _, quoted_source_list]}} ->
        {:config, _, [_, _, quoted_change_list]} = quoted_change
        range = Sourceror.get_range(quoted_source_list)
        source_list = Code.eval_quoted(quoted_source_list) |> elem(0)
        change_list = Code.eval_quoted(quoted_change_list) |> elem(0)

        plugins_list =
          (source_list ++ change_list)
          |> Enum.uniq_by(fn({x, _}) -> x end)
          |> Enum.sort_by(fn({x, _}) -> x end)

        change = """
          [<%= for {extension, engine} = plugin <- plugins_list do %>
            <%= Atom.to_string(extension) %>: <%= inspect engine %><%= unless last?(plugins_list, plugin) do %>,<% end %><% end %>
          ]
          """
          |> compile_string()
          |> String.trim()

        [build_patch(range, change)]
    end
  end

  @doc false
  def patch_live_reload_patterns(_context, patterns, source, path) do
    patterns =
      patterns
      |> List.flatten()
      |> Enum.uniq()
      |> Enum.sort()

    change = """
    [<%= for pattern <- patterns do %>
      <%= pattern %><%= unless last?(patterns, pattern) do %>,<% end %><% end %>
    ]
    """
    |> compile_string()

    fail_msg = fail_msg("merge", "live_reload pattern", path, change, &doc_ref/0)

    CodeGen.patch(source, change, merge: &merge_live_reload_patterns/2, fail_msg: fail_msg, path: path)
  end

  defp merge_live_reload_patterns(source, change) do
    quoted_change_list = Sourceror.parse_string!(change)

    source
    |> Sourceror.parse_string!()
    |> Zipper.zip()
    |> Zipper.find(&match?({{:__block__, _, [:live_reload]}, {:__block__, _, _}}, &1))
    |> case do
      nil -> :error
      %{node: {{:__block__, _, [:live_reload]}, {:__block__, _, [live_reload_kw_list]}}} ->
        live_reload_kw_list
        |> Zipper.zip()
        |> Zipper.find(&match?({{:__block__, _, [:patterns]}, _}, &1))
        |> case do
          nil -> :error
          %{node: {{:__block__, _, [:patterns]}, quoted_source_list}} ->
            range = Sourceror.get_range(quoted_source_list)
            {:__block__, _, [quoted_source_members]} = quoted_source_list
            {:__block__, _, [quoted_change_members]} = quoted_change_list

            source_list = Enum.map(quoted_source_members, &Sourceror.to_string/1)
            change_list = Enum.map(quoted_change_members, &Sourceror.to_string/1)

            patterns = Enum.uniq(source_list ++ change_list)

            change = """
              [<%= for pattern <- patterns do %>
                <%= pattern %><%= unless last?(patterns, pattern) do %>,<% end %><% end %>
              ]
              """
              |> compile_string()
              |> String.trim()

            [build_patch(range, change)]
        end
    end
  end

  @doc false
  def patch_live_reloader(_context, _data, source, path) do
    change = "plug LiveViewNative.LiveReloader\n"
    matcher = &(match?({:plug, _, [{:__aliases__, _, [:Phoenix, :LiveReloader]}]}, &1))
    CodeGen.patch(source, change, merge: &merge_live_reloader/2, inject: {:after, matcher}, path: path)
  end

  defp merge_live_reloader(source, _change) do
    source
    |> Sourceror.parse_string!()
    |> Zipper.zip()
    |> Zipper.find(&(match?({:plug, _, [{:__aliases__, _, [:LiveViewNative, :LiveReloader]}]}, &1)))
    |> case do
      nil -> :error
      _found -> []
    end
  end

  @doc false
  def patch_browser_pipeline(context, data, source, path) do
    quoted_source = Sourceror.parse_string!(source)

    data = List.flatten(data)

    quoted_source
    |> Zipper.zip()
    |> Zipper.find(&(match?({:pipeline, _, [{:__block__, _, [:browser]} | _]}, &1)))
    |> case do
      nil ->
        msg =
          """
          #{IO.ANSI.red()}#{IO.ANSI.bright()}No :browser_pipeline found in application router.#{IO.ANSI.reset()}
          You will need to manually configure your router for LiveView Native.

          #{doc_ref()}
          """

        {:error, msg}

      _quoted_browser_pipeline ->
        accepts_data = Keyword.get(data, :accepts)
        root_layouts_data = Keyword.get(data, :root_layouts)

        source =
          [
            {accepts_data, &patch_accepts/4},
            {root_layouts_data, &patch_root_layouts/4}
          ]
          |> Enum.reduce(source, fn({data, patch_fn}, source) ->
            case patch_fn.(context, data, source, path) do
              {:ok, source} -> source
              {:error, msg} ->
                Mix.shell().info(msg)
                source
            end
          end)

        {:ok, source}
    end
  end

  @doc false
  def patch_accepts(_context, formats, source, path) do
    formats =
      formats
      |> List.flatten()
      |> Enum.uniq()
      |> Enum.sort()

    CodeGen.patch(source, formats, merge: &merge_accepts/2, path: path)
  end

  defp merge_accepts(source, new_formats) do
    source
    |> Sourceror.parse_string!()
    |> Zipper.zip()
    |> Zipper.find(&(match?({:pipeline, _, [{:__block__, _, [:browser]} | _]}, &1)))
    |> Zipper.find(&(match?({:plug, _, [{:__block__, _, [:accepts]} | _]}, &1)))
    |> case do
      nil ->
        """
        #{IO.ANSI.red()}#{IO.ANSI.bright()}The :accepts plug is missing from the :browser pipeline.#{IO.ANSI.reset()}
        LiveView Native requires the following formats to be accepted: #{IO.ANSI.green()}#{IO.ANSI.bright()}#{inspect new_formats}#{IO.ANSI.reset()}

        #{doc_ref()}
        """
        |> Mix.shell.info()

      %{node: {:plug, _, [{:__block__, _, [:accepts]}, quoted_format_list]}}->
        range = Sourceror.get_range(quoted_format_list)
        old_formats = Code.eval_quoted(quoted_format_list) |> elem(0)

        formats = (old_formats ++ new_formats) |> Enum.uniq() |> Enum.sort()

        change = """
          [<%= for format <- formats do %>
            <%= inspect format %><%= unless last?(formats, format) do %>,<% end %><% end %>
          ]
          """
          |> compile_string()
          |> String.trim()

        [build_patch(range, change)]
    end
  end

  @doc false
  def patch_root_layouts(_context, layouts, source, path) do
    layouts =
      layouts
      |> List.flatten()
      |> Enum.uniq_by(fn({format, _layout_mod}) -> format end)
      |> Enum.sort_by(fn({format, _layout_mod}) -> format end)

    CodeGen.patch(source, layouts, merge: &merge_root_layouts/2, path: path)
  end

  defp merge_root_layouts(source, new_root_layouts) do
    source
    |> Sourceror.parse_string!()
    |> Zipper.zip()
    |> Zipper.find(&(match?({:pipeline, _, [{:__block__, _, [:browser]} | _]}, &1)))
    |> Zipper.find(&(match?({:plug, _, [{:__block__, _, [:put_root_layout]} | _]}, &1)))
    |> case do
      nil ->
        """
        #{IO.ANSI.red()}#{IO.ANSI.bright()}The :put_root_layout plug is missing from the :browser pipeline.#{IO.ANSI.reset()}
        LiveView Native requires the following root_layouts: #{IO.ANSI.green()}#{IO.ANSI.bright()}#{inspect new_root_layouts}#{IO.ANSI.reset()}

        #{doc_ref()}
        """
        |> Mix.shell.info()

      %{node: {:plug, _, [{:__block__, _, [:put_root_layout]}, quoted_root_layouts]} = quoted_plug}->
        range = Sourceror.get_range(quoted_plug)
        old_root_layouts =
          (Code.eval_quoted(quoted_root_layouts) |> elem(0))
          |> case do
            old_root_layout when is_tuple(old_root_layout) -> [html: old_root_layout]
            old_root_layouts -> old_root_layouts
          end

        root_layouts =
          (old_root_layouts ++ new_root_layouts)
          |> Enum.uniq_by(fn({format, _}) -> format end)
          |> Enum.sort_by(fn({format, _}) -> format end)

        change = """
          plug :put_root_layout,<%= for {format, layout_tuple} = root_layout <- root_layouts do %>
            <%= format %>: <%= inspect layout_tuple %><%= unless last?(root_layouts, root_layout) do %>,<% end %><% end %>
          """
          |> compile_string()
          |> String.trim()

        [build_patch(range, change)]
    end
  end

  @doc false
  def write_file(context, source, path) do
    original = File.read!(path)

    if original != source do
      "#{IO.ANSI.yellow()}Write to #{IO.ANSI.green()}#{IO.ANSI.bright()}#{path}#{IO.ANSI.reset()}\n(Y)es (n)o (d)iff\n>"
      |> Mix.Shell.IO.prompt()
      |> String.trim()
      |> case do
        "d" ->
          path
          |> File.read!()
          |> TextDiff.format(source)
          |> Mix.shell.info()

          write_file(context, source, path)
        char when char in ["y", "Y", ""] -> File.write!(path, source)
        "n" -> nil
        _other -> write_file(context, source, path)
      end
    end
  end

  @doc false
  def config_matcher({:config, meta, _args}),
    do: Keyword.get(meta, :column) == 1

  def config_matcher(_other),
    do: false

  def fail_msg(action, type, path, change, doc_ref) do
    """
    #{IO.ANSI.red()}#{IO.ANSI.bright()}Failed to #{action} the following #{type} into #{path}#{IO.ANSI.reset()}

    #{IO.ANSI.green}#{IO.ANSI.bright()}#{String.trim(change)}#{IO.ANSI.reset}

    You can do this manually or inspect #{IO.ANSI.yellow}#{IO.ANSI.bright()}#{path}#{IO.ANSI.reset()} for errors and try again

    #{doc_ref.() |> String.trim()}
    """
  end

  def doc_ref() do
    version = Application.spec(:live_view_native)[:vsn]

    """
    Please reference the documentation for more information on configuring LiveView Native:
    https://hexdocs.pm/live_view_native/#{version}/LiveViewNative.html#module-configuration
    """
  end
end
