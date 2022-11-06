defmodule LiveViewNative.Platforms.Web do
  defstruct []

  defimpl LiveViewNativePlatform.Platform do
    def platform_meta(_struct) do
      %LiveViewNativePlatform.Metadata{
        modifiers: %{},
        platform_id: :web,
        template_extension: ".web.html.heex",
        template_namespace: Web
      }
    end

    def start_simulator(_struct, opts \\ []) do
      IO.inspect opts
      raise "TODO: Implement this"
    end
  end
end
