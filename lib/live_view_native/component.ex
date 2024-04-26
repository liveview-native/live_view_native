defmodule LiveViewNative.Component do
  @moduledoc """
  Define reusable LiveView Native function components with NEEx templates.

  This module is used for the following

  * format specific render components
  * format specific functional components
  * format specific layouts

  LiveView Native Components differ from Phoenix Components in that they make
  user of a two-argument function instead of a single argument function. For example,
  with a Phoenix Component that has a template named `foo_bar.html.heex` it would define
  `foo_bar/1` as the rendering function for that template when embeded. LiveView Native Components
  would definee `foo_bar/2` for `foo_bar.swiftui.neex` with the 1st argument still being `assings` and
  the 2nd argument being `interface` map with information about the native client that is connecting.

  For more information on template embedding see `LiveViewNative.Renderer.embed_templates/2`

  ### Interface map

  Each native client can optionally send along an interface map that has at least the following information:

    * `"target"` - the target device within the platform family. For example, `ios`, `ipados`, `watchos` are all targets
    for the SwiftUI platform. Each client library should have information on the valid targets
    * `"version"` - the version of your application. This is a value that you can control and pattern match on. The `version`
    will need to be set in the native client build.
    * `"client_version"` - the version of the client library that is connecting. The client will set this.
  """

  @doc ~S'''
  Uses LiveView Native Component in the current module

  ## Options
    * `:format` - the format that corresponds to a LiveView Native client format for this component
    * `:root` - the directory relative to the component module's location where templates are stored.
    See `LiveViewNative.Renderer.embed_templates/2` for more information.
    * `:as` - will override the name of the rendering function injected into the module.
    See `LiveViewNative.Renderer.embed_templates/2` for more information.

  ## Format-Specific Render Component
      defmodule MyAppWeb.HomeLive.SwiftUI do
        use LiveViewNative.Component,
          format: :swiftui,
          as: :render
      end

  In this example `:as` is used and this will inject following:

      embed_templates("swiftui/home_live*", root: nil, name: :render)

  Assuming there is a `swiftui/home_live.swiftui.neex` this will be embeded in the render
  component as `render/2`.

  Alternatively if you do not want to use templates but the in-line rendering you can declare your own
  `render/2` functions

      def render(assigns, %{"target" => "watchos"}) do
        ~LVN"""
        <Text>Hello, from WatchOS!</Text>
        """
      end

      def render(assigns, %{"target" => target}) when target in ~w{macos tvos} do
        ~LVN"""
        <Text>Hello, from <%= target %>!</Text>
        """
      end

      def render(assigns, _interface) do
        ~LVN"""
        <Text>Hello, from SwiftUI!</Text>
        """
      end

  ## Format-Specific Function Component
      defmodule MyAppWeb.NativeComponent.SwiftUI do
        use LiveViewNative.Component,
          format: :swiftui
      end

  When using to write your own function components it is nearly identical to `Phoenix.Component`.
  You will use `embed_templates/2` for template embedding and this will inject functions that take
  `assigns` and `interface` as arguments.

  You can also define your own functions but you lose the 2 arity, or you can create it yourself.

      def radio_button(assigns) do
        interface = LiveViewNative.Utils.get_interface(assigns)
        radio_button(assign, interface)
      end

      def radio_button(assigns, %{"target" => "watchos"}) do
        ~LVN"""
          ...
        """
      end

  ## Format-Specific Layouts
      defmodule MyAppWeb.Layouts.SwiftUI do
        use LiveViewNative.Component,
          format: :swiftui

        import LiveViewNative.Component, only: [csrf_token: 1]

        embed_templates "layouts_swiftui/*"
      end

  Most times you will want to provide `app` and `root` templates.
  For stylesheet embedding refer to `LiveViewNative.Stylesheet.Component`
  '''
  defmacro __using__(opts) do
    %{module: module} = __CALLER__
    format = opts[:format]

    Module.put_attribute(module, :native_opts, %{
      as: opts[:as],
      format: format,
      root: opts[:root]
    })

    declarative_opts = Keyword.drop(opts, [:as, :format, :root])

    component_ast = quote do
      import Phoenix.LiveView.Helpers
      import Kernel, except: [def: 2, defp: 2]
      import Phoenix.Component, except: [
        embed_templates: 1, embed_templates: 2,
        sigil_H: 2,

        async_result: 1,
        dynamic_tag: 1,
        focus_wrap: 1,
        form: 1,
        inputs_for: 1,
        intersperse: 1,
        link: 1,
        live_component: 1,
        live_file_input: 1,
        live_img_preview: 1,
        live_title: 1
      ]

      import Phoenix.Component.Declarative
      require Phoenix.Template

      for {prefix_match, value} <- Phoenix.Component.Declarative.__setup__(__MODULE__, unquote(declarative_opts)) do
        @doc false
        def __global__?(prefix_match), do: value
      end

      def __native_opts__, do: @native_opts
    end

    plugin_component_ast = plugin_component_ast(format, opts)

    [component_ast, plugin_component_ast]
  end

  defp plugin_component_ast(nil, _opts) do
    quote do
      import LiveViewNative.Component, only: [sigil_LVN: 2]
    end
  end

  defp plugin_component_ast(format, opts) do
    case LiveViewNative.fetch_plugin(format) do
      {:ok, plugin} ->
        quote do
          import LiveViewNative.Renderer, only: [
            delegate_to_target: 1,
            delegate_to_target: 2,
            embed_templates: 1,
            embed_templates: 2
          ]
          use unquote(plugin.component)

          if (unquote(opts[:as])) do
            @before_compile LiveViewNative.Renderer
          end

          @before_compile LiveViewNative.Component
        end

      :error ->
        IO.warn("tried to load LiveViewNative plugin for format #{inspect(format)} but none was found")

        nil
    end
  end

  @doc false
  defmacro __before_compile__(_env) do
    quote do
      delegate_to_target :render, supress_warning: true
    end
  end

  @doc """
  The `~LVN` sigil for writing HEEx templates inside source files.

  Using `~LVN` is nearly identical to `~H` in `Phoenix.Component` but deviates
  in various ways.

  One common misconception is that LiveView Native templates are just HTML or XML. This is not true.
  Both HTML and XML have specifications that at times conflict with the needs of how LiveView Native client
  UI frameworks should be represented. Think of LiveView Native templates as a composable markup who's specificatin
  is currently under development. As we continue to expand the LiveView Native ecosystem this list will likely grow:

  * casing - `~LVN` does not enforce downcasing of tag names so `<Text>` is a valid tag name
  """
  @doc type: :macro
  defmacro sigil_LVN({:<<>>, meta, [expr]}, _modifiers) do
    unless Macro.Env.has_var?(__CALLER__, {:assigns, nil}) do
      raise "~LVN requires a variable named \"assigns\" to exist and be set to a map"
    end

    options = [
      engine: Phoenix.LiveView.TagEngine,
      file: __CALLER__.file,
      line: __CALLER__.line + 1,
      caller: __CALLER__,
      indentation: meta[:indentation] || 0,
      source: expr,
      tag_handler: LiveViewNative.TagEngine
    ]

    EEx.compile_string(expr, options)
  end

  @doc """
  Embed the CSRF token for LiveView as a tag
  """
  def csrf_token(assigns) do
    csrf_token = Phoenix.Controller.get_csrf_token()

    assigns = Map.put(assigns, :csrf_token, csrf_token)

    ~LVN"""
    <csrf-token value={@csrf_token} />
    """
  end
end
