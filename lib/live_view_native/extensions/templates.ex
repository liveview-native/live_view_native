defmodule LiveViewNative.Extensions.Templates do
  @moduledoc """
  LiveView Native extension for rendering platform-specific templates.
  Takes the following parameters which are typically derived from a `Macro.Env`
  struct:

  - `template_basename` - base filename of the template
  - `template_directory` - root path of the template
  - `template_extension` - file extension of the template
  - `template_engine` (optional) - a module implementation of `Phoenix.Template.Engine`
    to use for rendering the template. Defaults to `Phoenix.LiveView.HTMLEngine`

  If a template file and engine exist for the given parameters, a `render/1` function
  is generated which renders the template using that template engine.
  """
  defmacro __using__(opts \\ []) do
    template_basename = opts[:template_basename]
    template_directory = opts[:template_directory]
    template_extension = opts[:template_extension]
    template_engine = opts[:template_engine] || Phoenix.LiveView.HTMLEngine

    quote bind_quoted: [template_basename: template_basename, template_directory: template_directory, template_extension: template_extension, template_engine: template_engine] do
      template_path = Path.join(template_directory, template_basename) <> template_extension

      if is_binary(template_path) and File.exists?(template_path) do
        require EEx

        EEx.function_from_file(:def, :render, template_path, [:assigns], engine: template_engine)
      end
    end
  end
end
