defmodule Mix.LiveViewNative.Context do
  @moduledoc false

  defstruct context_app: nil,
    base_module: nil,
    schema_module: nil,
    web_module: nil,
    native_module: nil,
    module_suffix: nil,
    native_path: nil,
    format: nil,
    opts: nil

  def build(args, caller) do
    {parsed_opts, parsed, _other} = parse_opts(args, caller.switches())
    [format, schema_module] =
      parsed
      |> caller.validate_args!()
      |> parse_args()

    context_app = parsed_opts[:context_app] || Mix.Phoenix.context_app()
    base_module = Module.concat([Mix.Phoenix.context_base(context_app)])
    native_module = Module.concat([inspect(base_module) <> "Native"])
    web_module = Mix.Phoenix.web_module(base_module)
    native_path = Path.join(["native", Atom.to_string(format)])

    %__MODULE__{
      context_app: context_app,
      base_module: base_module,
      schema_module: schema_module,
      native_module: native_module,
      web_module: web_module,
      module_suffix: get_module_suffix(format),
      native_path: native_path,
      format: format,
      opts: parsed_opts
    }
  end

  defp parse_args(args) do
    format = Enum.at(args, 0) |> atomize()
    schema_module =
      Enum.at(args, 1)
      |> case do
        nil -> nil
        schema ->
          Module.concat([schema])
      end

    [format, schema_module]
  end

  defp atomize(atom) when is_atom(atom), do: atom
  defp atomize(string) when is_binary(string),
    do: String.to_atom(string)

  defp get_module_suffix(nil), do: nil
  defp get_module_suffix(format),
    do:
      LiveViewNative.fetch_plugin!(format).module_suffix
      |> List.wrap()
      |> Module.concat()

  def valid_format?(format) do
    LiveViewNative.fetch_plugin(format)
    |> case do
      {:ok, _plugin} -> true
      :error -> false
    end
  end

  def valid_module?(module_name) do
    Mix.Phoenix.Context.valid?(module_name)
  end

  def apps(format, default_app \\ :live_view_native) do
    plugin_otp_app_name =
      format
      |> LiveViewNative.fetch_plugin!()
      |> Map.get(:__struct__)
      |> Application.get_application()

    [".", plugin_otp_app_name, default_app]
    |> Enum.reject(&(&1 == nil))
  end

  def prompt_for_conflicts(generator_files) do
    file_paths =
      Enum.flat_map(generator_files, fn
        {:new_eex, _, _path} -> []
        {_kind, _, path} -> [path]
      end)

    case Enum.filter(file_paths, &File.exists?(&1)) do
      [] -> :ok
      conflicts ->
        Mix.shell().info"""
        The following files conflict with new files to be generated:

        #{Enum.map_join(conflicts, "\n", &"  * #{&1}")}
        """
        unless Mix.shell().yes?("Proceed with interactive overwrite?") do
          System.halt()
        end
    end
  end

  defp parse_opts(args, switches) do
    {opts, parsed, invalid} = OptionParser.parse(args, switches: switches)

    merged_opts = put_context_app(opts, opts[:context_app])

    {merged_opts, parsed, invalid}
  end

  defp put_context_app(opts, nil), do: opts

  defp put_context_app(opts, string) do
    Keyword.put(opts, :context_app, String.to_atom(string))
  end

  defmacro compile_string(string) do
    EEx.compile_string(string)
  end

  def last?(plugins, plugin),
    do: Enum.at(plugins, -1) == plugin
end
