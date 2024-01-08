defmodule LiveViewNativeTest.GameBoyLayouts do
  use LiveViewNative.Component,
    format: :gameboy

  import Phoenix.Controller,
    only: [get_csrf_token: 0]

  embed_templates "gameboy_layouts/*"
end