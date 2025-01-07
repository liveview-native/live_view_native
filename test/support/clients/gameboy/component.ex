defmodule LiveViewNativeTest.GameBoy.Component do
  defmacro __using__(_) do
    quote location: :keep do
      import LiveViewNative.Component, only: [sigil_LVN: 2]

      attr(:upload, Phoenix.LiveView.UploadConfig,
        required: true,
        doc: "The `Phoenix.LiveView.UploadConfig` struct"
      )

      attr(:accept, :string,
        doc:
          "the optional override for the accept attribute. Defaults to :accept specified by allow_upload"
      )

      attr(:rest, :global, include: ~w(webkitdirectory required disabled capture form))

      def live_file_input(assigns, interface)
      def live_file_input(%{upload: upload} = var!(assigns), _interface) do
        var!(assigns) = assign_new(var!(assigns), :accept, fn -> upload.accept != :any && upload.accept end)

        ~LVN"""
        <Input
          id={@upload.ref}
          type="file"
          name={@upload.name}
          accept={@accept}
          data-phx-hook="Phoenix.LiveFileUpload"
          data-phx-update="ignore"
          data-phx-upload-ref={@upload.ref}
          data-phx-active-refs={join_refs(for(entry <- @upload.entries, do: entry.ref))}
          data-phx-done-refs={join_refs(for(entry <- @upload.entries, entry.done?, do: entry.ref))}
          data-phx-preflighted-refs={
            join_refs(for(entry <- @upload.entries, entry.preflighted?, do: entry.ref))
          }
          data-phx-auto-upload={@upload.auto_upload?}
          {if @upload.max_entries > 1, do: Map.put(@rest, :multiple, true), else: @rest}
        />
        """
      end
      defp join_refs(entries), do: Enum.join(entries, ",")
    end
  end
end
