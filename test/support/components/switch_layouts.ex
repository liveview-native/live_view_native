defmodule LiveViewNativeTest.SwitchLayouts do
  use LiveViewNative.Component,
    format: :switch

  import Phoenix.Controller,
    only: [get_csrf_token: 0]

  embed_templates "switch_layouts/*"
end