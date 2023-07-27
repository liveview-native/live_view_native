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

    * `LiveViewNativePlatform.ModifiersStack`
    * `Jason.Encoder`
    * `Phoenix.HTML.Safe`

  These implementations are used for appending modifiers, encoding them as JSON and rendering
  them as HTML attributes respectively. For platforms that don't provide a modifier builder
  struct, a `%LiveViewNativePlatform.GenericModifiers{}` is used as a fallback.
  """
  alias LiveViewNativePlatform.ModifiersStack

  @max_constructor_arity 21

  defmacro __using__(opts \\ []) do
    quote bind_quoted: [
            custom_modifiers: opts[:custom_modifiers],
            max_constructor_arity: @max_constructor_arity,
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

            params =
              if raw_params,
                do: raw_params,
                else: apply(unquote(modifier_module), :params, mod_args)

            modifier = apply(unquote(modifier_module), :modifier, [params])

            ModifiersStack.append(mod_builder, modifier)
          end

          if Keyword.has_key?(modifier_module.__info__(:functions), :params) do
            for n <- 0..max_constructor_arity do
              # `params/n` for modifier `f` produces:
              # `f/(n + 1)` - taking a context struct
              # `f/(n + 1)` - taking a modifier builder
              # `f/n` - taking no arguments
              if Kernel.function_exported?(modifier_module, :params, n) do
                args = Macro.generate_arguments(n, nil)

                def unquote(:"#{modifier_key}")(
                      %LiveViewNativePlatform.Env{modifiers: mod},
                      unquote_splicing(args)
                    ),
                    do:
                      unquote(:"#{modifier_key}")(
                        {:_apply_mod, {[unquote_splicing(args)], mod, []}}
                      )

                def unquote(:"#{modifier_key}")(
                      %unquote(modifiers_struct){} = mod,
                      unquote_splicing(args)
                    ),
                    do:
                      unquote(:"#{modifier_key}")(
                        {:_apply_mod, {[unquote_splicing(args)], mod, []}}
                      )

                def unquote(:"#{modifier_key}")(unquote_splicing(args)),
                  do:
                    unquote(:"#{modifier_key}")(
                      {:_apply_mod, {[unquote_splicing(args)], nil, []}}
                    )
              end
            end
          else
            # If no `params` callback is exported by the modifier module, only include one and two arity
            # versions that optionally take a platform or modifier builder struct and always an option list,
            # map or modifier struct. Zero arity modifier functions are also included for modifiers without
            # schema fields.
            def unquote(:"#{modifier_key}")(
                  %LiveViewNativePlatform.Env{modifiers: modifiers},
                  params
                ) do
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
          for n <- 0..max_constructor_arity do
            args = Macro.generate_arguments(n, nil)

            if Kernel.function_exported?(platform_module, :"#{modifier_key}", n) do
              defdelegate unquote(:"#{modifier_key}")(unquote_splicing(args)), to: platform_module
            end
          end
        end
      end
    end
  end
end
