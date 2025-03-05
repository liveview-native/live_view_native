defmodule LiveViewNative.Component do
  @moduledoc """
  Define reusable LiveView Native function components with NEEx templates.

  This module is used for the following

  * format specific render components
  * format specific functional components
  * format specific layouts

  LiveView Native Components differ from Phoenix Components in that they make
  use of a two-argument function instead of a single argument function. For example,
  with a Phoenix Component that has a template named `foo_bar.html.heex` it would define
  `foo_bar/1` as the rendering function for that template when embedded. LiveView Native Components
  would definee `foo_bar/2` for `foo_bar.swiftui.neex` with the 1st argument still being `assigns` and
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

  Assuming there is a `swiftui/home_live.swiftui.neex` this will be embedded in the render
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

        import LiveViewNative.Component, only: [csrf_token: 2]

        embed_templates "layouts_swiftui/*"
      end

  Most times you will want to provide `app` and `root` templates.
  For stylesheet embedding refer to `LiveViewNative.Stylesheet.Component`
  '''
  defmacro __using__(opts) do
    %{module: module} = __CALLER__
    {opts, _} = Code.eval_quoted(opts)
    format = opts[:format]

    declarative_opts = Keyword.drop(opts, [:as, :format, :root])
    Module.put_attribute(module, :native_opts, %{
      as: opts[:as],
      format: format,
      root: opts[:root]
    })

    quote do
      @declarative LiveViewNative.Component.Declarative

      require Phoenix.Template
      import Phoenix.Component.Declarative, only: []
      import LiveViewNative.Component
      import Phoenix.Component, only: [
        assign: 2, assign: 3,
        assign_new: 3,
        assigns_to_attributes: 2,
        attr: 2, attr: 3,
        changed?: 2,
        live_flash: 2,
        live_render: 3,
        render_slot: 1, render_slot: 2,
        update: 3,
        upload_errors: 1,
        upload_errors: 2,
        used_input?: 1,
        slot: 1, slot: 2, slot: 3
      ]

      @doc false
      def __native_opts__, do: @native_opts

      Module.register_attribute(__MODULE__, :template_files, accumulate: true)
      Module.register_attribute(__MODULE__, :embedded_templates_opts, accumulate: true)

      import LiveViewNative.Renderer, only: [
        delegate_to_target: 1,
        delegate_to_target: 2,
        embed_templates: 1,
        embed_templates: 2
      ]

      if (unquote(opts[:as])) do
        @before_compile LiveViewNative.Renderer
        @before_compile {LiveViewNative.Renderer, :__inject_mix_recompile__}
      end

      @before_compile LiveViewNative.Component

      import Kernel, except: [def: 2, defp: 2]
      import LiveViewNative.Component.Declarative
      unquote(
        case LiveViewNative.fetch_plugin(format) do
          {:ok, %{component: component}} -> quote do: use unquote(component)
          :error -> quote do end
        end
      )

      for {prefix_match, value} <- @declarative.__setup__(__MODULE__, unquote(declarative_opts)) do
        @doc false
        def __global__?(prefix_match), do: value
      end
    end
  end

  @doc false
  defmacro __before_compile__(_env) do
    quote do
      delegate_to_target :render, suppress_warning: true
    end
  end

  @doc """
  The `~LVN` sigil for writing HEEx templates inside source files.

  Using `~LVN` is nearly identical to `~H` in `Phoenix.Component` but deviates
  in various ways.

  One common misconception is that LiveView Native templates are just HTML or XML. This is not true.
  Both HTML and XML have specifications that at times conflict with the needs of how LiveView Native client
  UI frameworks should be represented. Think of LiveView Native templates as a composable markup whose specification
  is currently under development. As we continue to expand the LiveView Native ecosystem this list will likely grow:

    * casing - `~LVN` does not enforce downcasing of tag names so `<Text>` is a valid tag name

  ### Special attributes

  LVN tempalates support all of the [HEEx special attributes](https://hexdocs.pm/phoenix_live_view/Phoenix.Component.html#sigil_H/2-special-attributes)
  in addition to LVN-specific special attributes:

  #### :interface-

  The `:interface-` attribute allows you to match against a given `interface` value from the client. Similar to `data-` in HTML the name that is appended
  is the key within the deeply nested value to match against. For example `:interface-target`:

  ```heex
  <Text :interface-target="mobile">This is a phone</Text>
  <Text :interface-target="watch">This is a watch</Text>
  ```

  The elements will conditionally render based upon a matching `interface["target"]` value. Internally this is converted to `:if`:

  ```heex
  <Text :if={get_in(assigns, [:_interface, "mobile"])}>This is a phone</Text>
  <Text :if={get_in(assigns, [:_interface, "watch"])}>This is a watch</Text>
  ```

  This convenience is intended for UI where one-off changes are necessary for specific cases to avoid having to define an entirely new template.
  """
  @doc type: :macro
  defmacro sigil_LVN({:<<>>, meta, [expr]}, _modifiers) do
    unless Macro.Env.has_var?(__CALLER__, {:assigns, nil}) do
      raise "~LVN requires a variable named \"assigns\" to exist and be set to a map"
    end

    options = [
      engine: LiveViewNative.TagEngine,
      file: __CALLER__.file,
      line: __CALLER__.line + 1,
      caller: __CALLER__,
      indentation: meta[:indentation] || 0,
      source: expr,
      tag_handler: LiveViewNative.Template.Engine
    ]

    EEx.compile_string(expr, options)
  end

  import Kernel, except: [def: 2, defp: 2]
  import LiveViewNative.Component.Declarative
  alias LiveViewNative.Component.Declarative

  # We need to bootstrap by hand to avoid conflicts.
  [] = Declarative.__setup__(__MODULE__, [])

  attr = fn name, type, opts ->
    Declarative.__attr__!(__MODULE__, name, type, opts, __ENV__.line, __ENV__.file)
  end

  slot = fn name, opts ->
    Declarative.__slot__!(__MODULE__, name, opts, __ENV__.line, __ENV__.file, fn -> nil end)
  end

  @doc """
  Please see the documentation for Phoenix.Component.async_result/1
  """
  @doc type: :component
  attr.(:assign, Phoenix.LiveView.AsyncResult, required: true)
  slot.(:loading, doc: "rendered while the assign is loading for the first time")

  slot.(:failed,
    doc:
      "rendered when an error or exit is caught or assign_async returns `{:error, reason}` for the first time. Receives the error as a `:let`"
  )

  slot.(:inner_block,
    doc:
      "rendered when the assign is loaded successfully via `AsyncResult.ok/2`. Receives the result as a `:let`"
  )

  import Phoenix.Component, only: [
    render_slot: 2
  ]

  def async_result(%{assign: async_assign} = var!(assigns), _interface) do
    cond do
      async_assign.ok? ->
        ~LVN|{render_slot(@inner_block, @assign.result)}|

      async_assign.loading ->
        ~LVN|{render_slot(@loading, @assign.loading)}|

      async_assign.failed ->
        ~LVN|{render_slot(@failed, @assign.failed)}|
    end
  end

  def live_component(assigns, _interface),
    do: Phoenix.Component.live_component(assigns)

  @doc """
  Embed the CSRF token for LiveView as a tag
  """
  def csrf_token(assigns, _interface) do
    IO.warn("csrf_token component has been deprecated. Please chance to raw dog markup: <csrf-token value={Phoenix.Controller.get_csrf_token()}/>")

    csrf_token = Phoenix.Controller.get_csrf_token()

    assigns = Map.put(assigns, :csrf_token, csrf_token)

    ~LVN"""
    <csrf-token value={@csrf_token} />
    """
  end
end
