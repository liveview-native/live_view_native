defmodule LiveViewNative.Extensions.Templates do
  @moduledoc """
  LiveView Native extension for rendering platform-specific templates.
  Takes the following parameters which are typically derived from a `Macro.Env`
  struct:

  - `tag_handler` (optional) - a module implementation of `Phoenix.LiveView.TagEngine`
  - `template_basename` - base filename of the template
  - `template_directory` - root path of the template
  - `template_extension` - file extension of the template

  If a template file and engine exist for the given parameters, a `render/1` function
  is generated which renders the template using that template engine.
  """
  defmacro __using__(opts \\ []) do
    caller = opts[:caller]
    eex_engine = opts[:eex_engine]
    platform_module = opts[:platform_module]
    tag_handler = opts[:tag_handler]
    template_basename = opts[:template_basename]
    template_directory = opts[:template_directory]
    template_extension = opts[:template_extension]

    quote bind_quoted: [
            caller: caller,
            eex_engine: eex_engine,
            platform_module: platform_module,
            tag_handler: tag_handler,
            template_basename: template_basename,
            template_directory: template_directory,
            template_extension: template_extension,
          ] do
      template_path = Path.join(template_directory, template_basename) <> template_extension

      if is_binary(template_path) and File.exists?(template_path) do
        require EEx

        EEx.function_from_file(
          :def,
          :render,
          template_path,
          [:assigns],
          caller: caller,
          engine: eex_engine,
          source: File.read!(template_path),
          tag_handler: tag_handler
        )
      end
    end
  end
end
