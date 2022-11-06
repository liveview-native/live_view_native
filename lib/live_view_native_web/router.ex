defmodule LiveViewNativeWeb.Router do
  use LiveViewNativeWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", LiveViewNativeWeb do
    pipe_through :api
  end
end
