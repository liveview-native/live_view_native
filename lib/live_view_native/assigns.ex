defmodule LiveViewNative.Assigns do
  defstruct [
    :app_version,
    :app_build,
    :format,
    :native,
    :os,
    :os_version,
    :target
  ]
end
