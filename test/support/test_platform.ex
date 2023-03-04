defmodule LiveViewNative.TestPlatform do
  defstruct [:testing_notes]

  defimpl LiveViewNativePlatform do
    def context(_struct) do
      %LiveViewNativePlatform.Context{
        tag_handler: LiveViewNative.TagEngine,
        platform_id: :_live_view_native_test_internal,
        template_extension: ".test.heex",
        template_namespace: Test
      }
    end

    def start_simulator(_struct, _opts \\ []) do
      {:ok, "start_simulator/2 was called from LiveViewNative.TestPlatform"}
    end
  end
end
