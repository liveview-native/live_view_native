import Config

config :mime, :types, %{
  "text/gameboy" => ["gameboy"],
  "text/switch" => ["switch"]
}

config :live_view_native, plugins: [
  LiveViewNativeTest.GameBoy,
  LiveViewNativeTest.Switch
]

config :phoenix_template, format_encoders: [
  gameboy: Phoenix.HTML.Engine,
  switch: Phoenix.HTML.Engine
]

config :phoenix, template_engines: [
  neex: LiveViewNative.Engine
]