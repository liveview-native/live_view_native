defmodule LiveViewNative.LiveComponent do
  @moduledoc false

  defmodule CID do
    @moduledoc """
    The struct representing an internal unique reference to the component instance,
    available as the `@myself` assign in live components.

    Read more about the uses of `@myself` in the `Phoenix.LiveComponent` docs.
    """

    defstruct [:cid]

    defimpl LiveViewNative.Template.Safe do
      def to_iodata(%{cid: cid}), do: Integer.to_string(cid)
    end

    defimpl String.Chars do
      def to_string(%{cid: cid}), do: Integer.to_string(cid)
    end
  end

  defmacro __using__(opts \\ []) do
    quote do
      import Phoenix.LiveView
      @behaviour Phoenix.LiveComponent

      use LiveViewNative.Component, Keyword.take(unquote(opts), [:as, :format, :global_prefixes, :root])

      @doc false
      def __live__, do: %{kind: :component, layout: false}
    end
  end
end
