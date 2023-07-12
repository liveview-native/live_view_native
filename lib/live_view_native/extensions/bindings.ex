defmodule LiveViewNative.Extensions.Bindings do
  import Phoenix.Component
  import Phoenix.LiveView
  import Ecto.Changeset

  defmacro __using__(_opts \\ []) do
    quote do
      import unquote(__MODULE__)
      @before_compile unquote(__MODULE__)

      Module.register_attribute(__MODULE__, :__native_bindings__, accumulate: true)

      on_mount {__MODULE__, :_set_native_binding_defaults}

      def on_mount(:_set_native_binding_defaults, _params, _session, socket) do
        defaults = Enum.map(__native_bindings__(), fn {name, {_type, opts}} -> {name, Keyword.get(opts, :default)} end)

        {:cont, assign_native_bindings(socket, defaults)}
      end

      def handle_event("_native_bindings", values, socket) do
        assigns = Enum.reduce(values, %{}, fn {name, json_value}, acc ->
          name = String.to_existing_atom(name)

          case Map.get(__native_bindings__(), name) do
            nil ->
              acc
            {type, default} ->
              Map.put(acc, name, json_value)
          end
        end)

        {:noreply, assign(socket, assigns)}
      end
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def __native_bindings__, do: Enum.into(@__native_bindings__, %{})
    end
  end

  defmacro native_binding(name, type, opts \\ []) do
    quote bind_quoted: [name: name, type: type, opts: opts] do
      @__native_bindings__ {name, {type, opts}}
    end
  end

  defmacro assign_native_bindings(socket, map, opts \\ []) do
    quote bind_quoted: [socket: socket, map: map, opts: opts] do
      data = Enum.into(map, %{})
      types = Map.new(__native_bindings__(), fn {name, {type, _opts}} -> {name, type} end)
      changeset = cast({data, types}, data, Map.keys(data))
      data = Map.merge(data, changeset.changes)

      animation = case Keyword.get(opts, :animation) do
        nil ->
          nil
        type when is_atom(type) ->
          %{ type: type, properties: %{}, modifiers: [] }
        {type, [ {k, _} | _ ] = properties} when is_atom(type) and is_atom(k) ->
          %{ type: type, properties: Enum.into(properties, %{}), modifiers: [] }
        {type, [ {k, _} | _ ] = properties, modifiers} when is_atom(type) and is_atom(k) and is_list(modifiers) ->
          {:ok, %{ type: type, properties: Enum.into(properties, %{}), modifiers: Enum.map(modifiers, fn
            {type, properties} ->
              %{ type: type, properties: Enum.into(properties, %{}) }
          end) }}
      end

      socket
        |> assign(map)
        |> push_event("_native_bindings", %{ data: data, animation: animation })
    end
  end
end
