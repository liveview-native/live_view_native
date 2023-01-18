defmodule LiveViewNative.Extensions.Modifiers do
  @moduledoc """
  LiveView Native extension for platform-specific modifiers. Modifiers refer to
  properties that affect the behavior and visual presentation of native components,
  such as alignment, visibility, styling, and so on. Each platform library defines
  its own set of supported modifiers as well as how to encode those modifiers before
  they are returned from the LiveView server to the client.

  Each modifier for a platform is exposed to its platform-specific templates as a
  function named after the modifier and taking one argument, the `@native` assign.
  These function names may overlap between platforms that co-mingle within a LiveView
  Native application without conflict, thanks to each platform having its own render
  context as part of `LiveViewNative.Extensions.Render`.
  """
  defmacro __using__(opts \\ []) do
    platform_modifiers = opts[:platform_modifiers]

    quote bind_quoted: [platform_modifiers: platform_modifiers] do
      defp map_property(element, {idx, acc}) when is_list(element) do
        [element | _] = element
        {
          idx + 1,
          acc ++ [{elem(element, 0), elem(element, 1)}]
        }
      end
      defp map_property(element, {idx, acc}), do: {idx + 1, acc ++ [element]}

      defp build_modifiers({:|>, _, children}, acc) do
        Enum.reduce(children, acc, &build_modifiers/2) ++ acc
      end
      defp build_modifiers({name, _, props}, acc) do
        props = props |> Enum.reduce({0, []}, &map_property/2) |> elem(1)
        [{:%{}, [], [type: name] ++ props} | acc]
      end

      @doc """
      Generates the `modifier=""` attribute from the passed arguments.

      The modifiers are expected to be in a pipe:

      ```ex
      modify padding(all: 16)
        |> font(:large_title)
        |> navigation_title(title: "My App")
      ```
      """
      defmacro modify(modifier_stack) do
        built = build_modifiers(modifier_stack, [])
        quote do
          {:ok, result} = unquote(built) |> Jason.encode
          dbg result
          %{ modifiers: result }
        end
      end
    end
  end
end
