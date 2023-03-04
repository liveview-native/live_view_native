defmodule LiveViewNative.Bindings do
  defmacro native_binding(name, type, default) do
    quote bind_quoted: [name: name, type: type, default: default] do
      case Module.get_attribute(__MODULE__, :_native_bindings) do
        nil ->
          @_native_bindings %{name => {type, default}}

        existing ->
          @_native_bindings Map.put(existing, name, {type, default})
      end

      def _native_bindings, do: @_native_bindings
      defoverridable [{:_native_bindings, 0}]

      unless Module.get_attribute(__MODULE__, :_defined_native_binding_functions, false) do
        @_defined_native_binding_functions true

        on_mount {__MODULE__, :_set_native_binding_defaults}

        def on_mount(:_set_native_binding_defaults, _params, _session, socket) do
          defaults =
            Enum.map(_native_bindings(), fn {name, {_type, default}} -> {name, default} end)

          {
            :cont,
            socket
            |> assign_native_bindings(defaults)
          }
        end

        def handle_event("_native_bindings", values, socket) do
          assigns =
            Enum.reduce(values, %{}, fn {name, json_value}, acc ->
              name_as_atom = String.to_existing_atom(name)

              case Map.get(_native_bindings(), name_as_atom) do
                nil ->
                  acc

                {type, _default} ->
                  impl_module = Module.concat(LiveViewNative.JSONCoercable, type)

                  Map.put(
                    acc,
                    name_as_atom,
                    impl_module.from_json(json_value)
                  )
              end
            end)

          {:noreply, assign(socket, assigns)}
        end

        def assign_native_bindings(socket, map) do
          event_payload =
            Map.new(map, fn {name, value} ->
              {name, LiveViewNative.JSONCoercable.to_json(value)}
            end)

          socket
          |> assign(map)
          |> push_event("_native_bindings", event_payload)
        end
      end
    end
  end
end
