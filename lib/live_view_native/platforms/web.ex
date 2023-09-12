defmodule LiveViewNative.Platforms.Web do
  @moduledoc false

  defstruct []

  defimpl LiveViewNativePlatform.Kit do
    def compile(_struct) do
      LiveViewNativePlatform.Env.define(:html,
        tag_handler: Phoenix.LiveView.HTMLEngine,
        template_extension: ".html.heex",
        template_namespace: LiveViewNativeWeb,
        otp_app: :live_view_native
      )
    end
  end
end
