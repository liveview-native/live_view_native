defmodule LiveViewNativeTest.SwitchLayouts do
  use Phoenix.Component

  import Phoenix.Controller,
    only: [get_csrf_token: 0]

  embed_templates "switch_layouts/*"
end