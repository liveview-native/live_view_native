defmodule LiveViewNative.TestPlatform do
  defmodule Modifiers do
    defimpl Jason.Encoder do
      def encode(%{stack: stack}, opts) do
        Jason.Encode.list(stack, opts)
      end
    end

    defimpl Phoenix.HTML.Safe do
      def to_iodata(struct) do
        struct
        |> Jason.encode!()
        |> Phoenix.HTML.Engine.html_escape()
      end
    end
  end

  defstruct [:testing_notes]

  defimpl LiveViewNativePlatform.Kit do
    def context(_struct) do
      LiveViewNativePlatform.Context.define(:lvntest,
        template_extension: ".test.heex",
        template_namespace: Test,
        otp_app: :live_view_native
      )
    end
  end
end
