# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

if config_env() == :test do
  # Define platform support for LiveView Native
  config :live_view_native,
    plugins: [
      LiveViewNative.TestPlatform
    ]

  config :live_view_native, LiveViewNative.TestPlatform, testing_notes: "everything is ok"
end
