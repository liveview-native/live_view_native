defmodule LiveViewNative.TestPlatform do
  defstruct [:testing_notes]

  defimpl LiveViewNativePlatform.Kit do
    def compile(_struct) do
      LiveViewNativePlatform.Env.define(:lvntest,
        default_layouts: %{
          app: "<%= @inner_content %>",
          root: "<%= @inner_content %>"
        },
        template_extension: ".test.heex",
        template_namespace: Test,
        otp_app: :live_view_native,
        valid_targets: ~w(testsuite)a
      )
    end
  end
end
