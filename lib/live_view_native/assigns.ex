defmodule LiveViewNative.Assigns do
  defstruct [
    :app_version,
    :app_build,
    :bundle_id,
    :format,
    :native,
    :os,
    :os_version,
    :target
  ]
end
