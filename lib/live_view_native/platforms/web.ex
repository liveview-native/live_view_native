defmodule LiveViewNative.Platforms.Web do
  defstruct []

  defimpl LiveViewNativePlatform do
    def context(_struct) do
      %LiveViewNativePlatform.Context{
        tag_handler: Phoenix.LiveView.HTMLEngine,
        platform_id: :web,
        template_extension: ".html.heex",
        template_namespace: Web
      }
    end

    def start_simulator(_struct, _opts \\ []) do
      {:ok, :skipped}
    end
  end
end
