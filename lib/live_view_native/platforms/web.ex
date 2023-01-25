defmodule LiveViewNative.Platforms.Web do
  defstruct []

  defimpl LiveViewNativePlatform do
    def context(_struct) do
      %LiveViewNativePlatform.Context{
        platform_id: :web,
        template_engine: Phoenix.LiveView.HTMLEngine,
        template_extension: ".html.heex",
        template_namespace: Web
      }
    end

    def start_simulator(_struct, _opts \\ []) do
      {:ok, :skipped}
    end
  end
end
