defmodule LiveViewNativeWeb.Router do
  use LiveViewNativeWeb, :router

  if Mix.env() == :dev do
    scope "/live-view-native" do
    end
  end
end
