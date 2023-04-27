defmodule LiveViewNative.TestPlatform do
  defstruct [:testing_notes]

  defimpl LiveViewNativePlatform do
    def context(_struct) do
      LiveViewNativePlatform.Context.define(:lvntest,
        template_extension: ".test.heex",
        template_namespace: Test,
        otp_app: :live_view_native
      )
    end

    def start_simulator(_struct, _opts \\ []) do
      {:ok, "start_simulator/2 was called from LiveViewNative.TestPlatform"}
    end
  end
end
