defmodule LiveViewNative.Extensions.Persistence do
  import Phoenix.Component
  import Phoenix.LiveView

  defmacro __using__(_opts \\ []) do
    quote do
      import unquote(__MODULE__)
    end
  end

  def push_persistent_value(socket, key, value, opts \\ []) do
    push_event(
      socket,
      "_native_persistence_store",
      %{ value: value, key: key, options: Enum.into(opts, %{}) }
    )
  end

  def load_persistent_value(socket, key, event, opts \\ []) do
    push_event(
      socket,
      "_native_persistence_load",
      %{ key: key, event: event, options: Enum.into(opts, %{}) }
    )
  end
end
