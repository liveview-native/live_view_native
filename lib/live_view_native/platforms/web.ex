defmodule LiveViewNative.Platforms.Web do
  defstruct []

  defimpl LiveViewNativePlatform do
    def context(_struct) do
      %LiveViewNativePlatform.Context{
        platform_id: :web,
        template_extension: ".web.html.heex",
        template_namespace: Web
      }
    end

    def start_simulator(_struct, opts \\ []) do
      IO.inspect(opts)
      raise "TODO: Implement this"
    end
  end
end
