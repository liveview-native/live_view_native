Application.put_env(:live_view_native, MyApp.Endpoint,
  pubsub_server: MyApp.PubSub,
  live_reload: [
    url: "ws://localhost:4000",
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif)$},
      ~r{web/views/.*(ex)$},
      ~r{web/templates/.*(eex)$}
    ]
  ]
)

defmodule MyApp.Endpoint do
  use Phoenix.Endpoint, otp_app: :live_view_native

  plug LiveViewNative.SessionPlug
end

children = [
  MyApp.Endpoint
]

Supervisor.start_link(children, strategy: :one_for_one)

ExUnit.start()
