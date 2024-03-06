defmodule Mix.LiveViewNative.Context do
  # alias Mix.Phoenix.Context

  # @switches [
  #   context_app: :string
  # ]

  # def build(_args) do
  #   {opts, _parsed, _} = parse_opts(args)
  #   ctx_app = opts[:context_app] || Mix.Phoenix.context_app()
  #   ctx_module = Module.concat([ctx_app])
  #   name = "#{inspect(ctx_module)}" <> "Native"
  #   module = Module.concat([name])
  #   basedir = Phoenix.Naming.underscore(name)
  #   dir = Mix.Phoenix.context_app_path(ctx_app, "lib")
  #   file = dir <> ".ex"

  #   context = %Context{
  #     name: name,
  #     module: module,
  #     file: file,
  #     generate?: false
  #   }
  # end

  # defp parse_opts(args) do
  #   {opts, parsed, invalid} = OptionParser.parse(args, switches: @switches)

  #   merged_opts =
  #     @default_opts
  #     |> Keyword.merge(opts)
  #     |> put_context_app(opts[:context_app])

  #   {merged_opts, parsed, invalid}
  # end

  # defp put_context_app(opts, nil), do: opts

  # defp put_context_app(opts, string) do
  #   Keyword.put(opts, :context_app, String.to_atom(string))
  # end
end
