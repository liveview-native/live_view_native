defmodule LiveViewNativeTest.Router do
  use Phoenix.Router
  import Phoenix.LiveView.Router

  pipeline :setup_session do
    plug Plug.Session,
      store: :cookie,
      key: "_live_view_key",
      signing_salt: "/VEDsdfsffMnp5"

    plug :fetch_session
  end

  pipeline :browser do
    plug :setup_session
    plug :accepts, ["html", "gameboy", "switch"]
    plug :fetch_live_flash
  end

  scope "/", LiveViewNativeTest do
    pipe_through [:browser]

    live "/inline", InlineLive
    live "/template", TemplateLive
    live "/html-inline", HTMLInlineLive
    live "/html-template", HTMLTemplateLive
  end
end
