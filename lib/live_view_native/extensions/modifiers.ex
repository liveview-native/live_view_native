defmodule LiveViewNative.Extensions.Modifiers do
  @moduledoc """
  LiveView Native extension for platform-specific modifiers. Modifiers refer to
  properties that affect the behavior and visual presentation of native components,
  such as alignment, visibility, styling, and so on. Each platform library defines
  its own set of supported modifiers as well as how to encode those modifiers before
  they are returned from the LiveView server to the client.

  A modifier is a struct that implements the `LiveViewNativePlatform.Modifier` protocol
  and optionally defines any number of functions with the name `params` of any arity up
  to 6. The `params` function is used to encode the modifier before it is added to the
  modifier stack when applying the modifier as part of a LiveView Native HEEx template.
  For example:

  ```elixir
  defmodule MyPlatform.Modifiers.Bold do
    use LiveViewNativePlatform.Modifier

    modifier_schema "bold" do
      field :is_active, :boolean, default: true
    end

    def params(is_active) when is_boolean(is_active), do: [is_active: is_active]
    def params(params), do: params
  end
  ```

  This module defines a modifier named `bold` that can be constructed by passing a boolean
  or any value that can be cast to a modifier schema (an option list, map or struct of the
  same module). It could be called any of the following ways from a LiveView Native HEEx
  template:

  ```heex
  <Text modifiers={bold(true)}>This text is bold</Text>
  ```

  This example demonstrates using `bold/1` as the first modifier in a chain. It is called
  with a boolean which is then passed to `params/1`. `true` matches the `is_boolean/1` guard
  and so an option list is returned with the value of `:is_active` being `true`. Finally,
  that option list is cast to `%MyPlatform.Modifiers.Bold{}` which gets wrapped in a new
  modifier builder as the return value.

  ```heex
  <Text modifiers={bold(is_active: true)}>This text is bold too.</Text>
  ```

  This `bold/1` call also occurs at the beginning of a chain but here it is called with
  an option list. The option list falls back to the second function clause of `params/1`
  and is returned as is, being cast to `%MyPlatform.Modifiers.Bold{}` and wrapped in a
  modifier builder which is returned.

  ```heex
  <Text modifiers={some_other_modifier() |> bold(true)}>Oh, and this one as well.</Text>
  ```

  Here, the modifier is being called in the middle of a chain as `bold/2` with the first
  value being a modifier builder returned by `some_other_modifier/0` and the second value
  being a boolean. All of the same steps as the first example are applied with the return
  value being `%MyPlatform.Modifiers.Bold{is_active: true}`. This modifier is added to the
  modifier builder stack through its implementation of `LiveViewNativePlatform.ModifiersStack`.
  The modifier builder is then returned with the modifier added to the stack.

  ```heex
  <Text modifiers={some_other_modifier() |> bold(%{is_active: true})}>And even this one as well.</Text>
  ```

  This example is the same as the previous one except that the second value is an option
  list. The same steps are applied as the second example, with the same return value being
  added to the passed modifier builder's stack.

  The "modifier builder" that gets returned in all of these examples is a custom struct
  defined by the platform library that provides the modifier function being called. In all
  cases, it is a module that implements the following protocols:

  - `LiveViewNativePlatform.ModifiersStack`
  - `Jason.Encoder`
  - `Phoenix.HTML.Safe`

  These implementations are used for appending modifiers, encoding them as JSON and rendering
  them as HTML attributes respectively. For platforms that don't provide a modifier builder
  struct, a `%LiveViewNativePlatform.GenericModifiers{}` is used as a fallback.
  """
  alias LiveViewNativePlatform.ModifiersStack

  defmacro __using__(opts \\ []) do
    quote bind_quoted: [
            custom_modifiers: opts[:custom_modifiers],
            modifiers_struct: opts[:modifiers_struct],
            platform_modifiers: opts[:platform_modifiers],
            platform_module: opts[:platform_module]
          ] do
      all_modifiers = Keyword.merge(platform_modifiers, custom_modifiers)

      if is_nil(platform_module) do
        for {modifier_key, modifier_module} <- all_modifiers do
          # When a function with the name `params` is defined on a modifier module, a function
          # with the same arity and the name of the modifier is generated. This function takes
          # the same arguments as the `params` function, calling that function before applying
          # a modifier to the stack.

          def unquote(:"#{modifier_key}")({:_apply_mod, {mod_args, mod_builder, opts}}) do
            mod_builder = mod_builder || struct(unquote(modifiers_struct), %{})
            raw_params = Keyword.get(opts, :raw_params)
            params = if raw_params, do: raw_params, else: apply(unquote(modifier_module), :params, mod_args)
            modifier = apply(unquote(modifier_module), :modifier, [params])

            ModifiersStack.append(mod_builder, modifier)
          end

          if Keyword.has_key?(modifier_module.__info__(:functions), :params) do
            # `params/0` for modifier `f` produces:
            # `f/1` - taking a context struct
            # `f/1` - taking a modifier builder
            # `f/0` - taking no arguments
            if Kernel.function_exported?(modifier_module, :params, 0) do
              def unquote(:"#{modifier_key}")(%LiveViewNativePlatform.Context{modifiers: mod}), do:
                unquote(:"#{modifier_key}")({:_apply_mod, {[], mod, []}})

              def unquote(:"#{modifier_key}")(%unquote(modifiers_struct){} = mod), do:
                unquote(:"#{modifier_key}")({:_apply_mod, {[], mod, []}})

              def unquote(:"#{modifier_key}")(), do:
                unquote(:"#{modifier_key}")({:_apply_mod, {[], nil, []}})
            end

            # `params/1` for modifier `f` produces:
            # `f/2` - taking a context struct and `a`
            # `f/2` - taking a modifier builder and `a`
            # `f/1` - taking `a`
            if Kernel.function_exported?(modifier_module, :params, 1) do
              def unquote(:"#{modifier_key}")(%LiveViewNativePlatform.Context{modifiers: mod}, a), do:
                unquote(:"#{modifier_key}")({:_apply_mod, {[a], mod, []}})

              def unquote(:"#{modifier_key}")(%unquote(modifiers_struct){} = mod, a), do:
                unquote(:"#{modifier_key}")({:_apply_mod, {[a], mod, []}})

              def unquote(:"#{modifier_key}")(a), do:
                unquote(:"#{modifier_key}")({:_apply_mod, {[a], nil, []}})
            end

            # `params/2` for modifier `f` produces:
            # `f/3` - taking a context struct, `a` and `b`
            # `f/3` - taking a modifier builder, `a` and `b`
            # `f/2` - taking `a` and `b`
            if Kernel.function_exported?(modifier_module, :params, 2) do
              def unquote(:"#{modifier_key}")(%LiveViewNativePlatform.Context{modifiers: mod}, a, b), do:
                unquote(:"#{modifier_key}")({:_apply_mod, {[a, b], mod, []}})

              def unquote(:"#{modifier_key}")(%unquote(modifiers_struct){} = mod, a, b), do:
                unquote(:"#{modifier_key}")({:_apply_mod, {[a, b], mod, []}})

              def unquote(:"#{modifier_key}")(a, b), do:
                unquote(:"#{modifier_key}")({:_apply_mod, {[a, b], nil, []}})
            end

            # `params/3` for modifier `f` produces:
            # `f/4` - taking a context struct, `a`, `b,` and `c`
            # `f/4` - taking a modifier builder, `a`, `b,` and `c`
            # `f/3` - taking `a`, `b,` and `c`
            if Kernel.function_exported?(modifier_module, :params, 3) do
              def unquote(:"#{modifier_key}")(%LiveViewNativePlatform.Context{modifiers: mod}, a, b, c), do:
                unquote(:"#{modifier_key}")({:_apply_mod, {[a, b, c], mod, []}})

              def unquote(:"#{modifier_key}")(%unquote(modifiers_struct){} = mod, a, b, c), do:
                unquote(:"#{modifier_key}")({:_apply_mod, {[a, b, c], mod, []}})

              def unquote(:"#{modifier_key}")(a, b, c), do:
                unquote(:"#{modifier_key}")({:_apply_mod, {[a, b, c], nil, []}})
            end

            # `params/4` for modifier `f` produces:
            # `f/5` - taking a context struct, `a`, `b,`, `c` and `d`
            # `f/5` - taking a modifier builder, `a`, `b,`, `c` and `d`
            # `f/4` - taking `a`, `b,`, `c` and `d`
            if Kernel.function_exported?(modifier_module, :params, 4) do
              def unquote(:"#{modifier_key}")(%LiveViewNativePlatform.Context{modifiers: mod}, a, b, c, d), do:
                unquote(:"#{modifier_key}")({:_apply_mod, {[a, b, c, d], mod, []}})

              def unquote(:"#{modifier_key}")(%unquote(modifiers_struct){} = mod, a, b, c, d), do:
                unquote(:"#{modifier_key}")({:_apply_mod, {[a, b, c, d], mod, []}})

              def unquote(:"#{modifier_key}")(a, b, c, d), do:
                unquote(:"#{modifier_key}")({:_apply_mod, {[a, b, c, d], nil, []}})
            end

            # `params/5` for modifier `f` produces:
            # `f/6` - taking a context struct, `a`, `b,`, `c`, `d` and `e`
            # `f/6` - taking a modifier builder, `a`, `b,`, `c`, `d` and `e`
            # `f/5` - taking `a`, `b,`, `c`, `d` and `e`
            if Kernel.function_exported?(modifier_module, :params, 5) do
              def unquote(:"#{modifier_key}")(%LiveViewNativePlatform.Context{modifiers: mod}, a, b, c, d, e), do:
                unquote(:"#{modifier_key}")({:_apply_mod, {[a, b, c, d, e], mod, []}})

              def unquote(:"#{modifier_key}")(%unquote(modifiers_struct){} = mod, a, b, c, d, e), do:
                unquote(:"#{modifier_key}")({:_apply_mod, {[a, b, c, d, e], mod, []}})

              def unquote(:"#{modifier_key}")(a, b, c, d, e), do:
                unquote(:"#{modifier_key}")({:_apply_mod, {[a, b, c, d, e], nil, []}})
            end

            # `params/6` for modifier `f` produces:
            # `f/7` - taking a context struct, `a`, `b,`, `c`, `d`, `e` and `f`
            # `f/7` - taking a modifier builder, `a`, `b,`, `c`, `d`, `e` and `f`
            # `f/6` - taking `a`, `b,`, `c`, `d`, `e` and `f`
            if Kernel.function_exported?(modifier_module, :params, 6) do
              def unquote(:"#{modifier_key}")(%LiveViewNativePlatform.Context{modifiers: mod}, a, b, c, d, e, f), do:
                unquote(:"#{modifier_key}")({:_apply_mod, {[a, b, c, d, e, f], mod, []}})

              def unquote(:"#{modifier_key}")(%unquote(modifiers_struct){} = mod, a, b, c, d, e), do:
                unquote(:"#{modifier_key}")({:_apply_mod, {[a, b, c, d, e, f], mod, []}})

              def unquote(:"#{modifier_key}")(a, b, c, d, e), do:
                unquote(:"#{modifier_key}")({:_apply_mod, {[a, b, c, d, e, f], nil, []}})
            end
          else
            # If no `params` callback is exported by the modifier module, only include one and two arity
            # versions that optionally take a platform or modifier builder struct and always an option list,
            # map or modifier struct. Zero arity modifier functions are also included for modifiers without
            # schema fields.
            def unquote(:"#{modifier_key}")(%LiveViewNativePlatform.Context{modifiers: modifiers}, params) do
              mod = struct(unquote(modifiers_struct), Map.from_struct(modifiers))

              unquote(:"#{modifier_key}")(mod, params)
            end

            def unquote(:"#{modifier_key}")(%unquote(modifiers_struct){} = mod, params) do
              modifier = apply(unquote(modifier_module), :modifier, [params])

              ModifiersStack.append(mod, modifier)
            end

            def unquote(:"#{modifier_key}")(params) do
              mod = struct(unquote(modifiers_struct), %{})

              unquote(:"#{modifier_key}")(mod, params)
            end

            def unquote(:"#{modifier_key}")() do
              mod = struct(unquote(modifiers_struct), %{})

              unquote(:"#{modifier_key}")(mod)
            end
          end
        end
      else
        # If a platform module is passed to this extension, it means that this extension macro is
        # being applied to a LiveView or Component module for the purpose of inline rendering. In
        # this case, we only need to generate modifier functions that delegate to the ones defined
        # on the platform module:
        for {modifier_key, modifier_module} <- all_modifiers do
          if Kernel.function_exported?(platform_module, :"#{modifier_key}", 0) do
            defdelegate unquote(:"#{modifier_key}")(), to: platform_module
          end
          if Kernel.function_exported?(platform_module, :"#{modifier_key}", 1) do
            defdelegate unquote(:"#{modifier_key}")(a), to: platform_module
          end
          if Kernel.function_exported?(platform_module, :"#{modifier_key}", 2) do
            defdelegate unquote(:"#{modifier_key}")(a, b), to: platform_module
          end
          if Kernel.function_exported?(platform_module, :"#{modifier_key}", 3) do
            defdelegate unquote(:"#{modifier_key}")(a, b, c), to: platform_module
          end
          if Kernel.function_exported?(platform_module, :"#{modifier_key}", 4) do
            defdelegate unquote(:"#{modifier_key}")(a, b, c, d), to: platform_module
          end
          if Kernel.function_exported?(platform_module, :"#{modifier_key}", 5) do
            defdelegate unquote(:"#{modifier_key}")(a, b, c, d, e), to: platform_module
          end
          if Kernel.function_exported?(platform_module, :"#{modifier_key}", 6) do
            defdelegate unquote(:"#{modifier_key}")(a, b, c, d, e, f), to: platform_module
          end
          if Kernel.function_exported?(platform_module, :"#{modifier_key}", 7) do
            defdelegate unquote(:"#{modifier_key}")(a, b, c, d, e, f, g), to: platform_module
          end
        end
      end
    end
  end
end
