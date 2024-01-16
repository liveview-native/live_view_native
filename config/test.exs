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

config :live_view_native_test,
  formats: [:html, :gameboy, :switch],
  otp_app: :live_view_native,
  routes: [
    %{path: "/inline", module: LiveViewNativeTest.InlineLive},
    %{path: "/template", module: LiveViewNativeTest.TemplateLive}
  ]

config :phoenix, :plug_init_mode, :runtime
