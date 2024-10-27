# The content of this file was copy/pasted from LiveViewNative.LVN
# and modified for LiveViewNative

defmodule LiveViewNative.LVN do
  @moduledoc ~S'''
  Provides commands for executing Native utility operations on the client.

  LVN commands support a variety of utility operations for common client-side
  needs, such as adding or removing CSS classes, setting or removing tag attributes,
  showing or hiding content, and transitioning in and out with animations.
  While these operations can be accomplished via client-side hooks,
  LVN commands are ViewTree-patch aware, so operations applied
  by the LVN APIs will stick to elements across patches from the server.

  In addition to purely client-side utilities, the LVN commands include a
  rich `push` API, for extending the default `phx-` binding pushes with
  options to customize targets, loading states, and additional payload values.

  ## Client Utility Commands

  The following utilities are included:

    * `add_class` - Add classes to elements, with optional transitions
    * `remove_class` - Remove classes from elements, with optional transitions
    * `toggle_class` - Sets or removes classes from elements, with optional transitions
    * `set_attribute` - Set an attribute on elements
    * `remove_attribute` - Remove an attribute from elements
    * `toggle_attribute` - Sets or removes element attribute based on attribute presence.
    * `show` - Show elements, with optional transitions
    * `hide` - Hide elements, with optional transitions
    * `toggle` - Shows or hides elements based on visibility, with optional transitions
    * `transition` - Apply a temporary transition to elements for animations
    * `dispatch` - Dispatch a ViewTree event to elements

  For example, the following modal component can be shown or hidden on the
  client without a trip to the server:

      alias LiveViewNative.LVN

      def hide_modal(lvn \\ %LVN{}) do
        lvn
        |> LVN.hide(transition: "fade-out", to: "#modal")
        |> LVN.hide(transition: "fade-out-scale", to: "#modal-content")
      end

      def modal(assigns) do
        ~LVN"""
        <Text id="modal" class="phx-modal" phx-remove={hide_modal()}>
          <Text
            id="modal-content"
            class="phx-modal-content"
            phx-click-away={hide_modal()}
            phx-window-keydown={hide_modal()}
            phx-key="escape"
          >
            <Button class="phx-modal-close" phx-click={hide_modal()}>✖</Button>
            <Text><%= @text %></Text>
          </Text>
        </Text>
        """
      end

  ## Enhanced push events

  The `push/1` command allows you to extend the built-in pushed event handling
  when a `phx-` event is pushed to the server. For example, you may wish to
  target a specific component, specify additional payload values to include
  with the event, apply loading states to external elements, etc. For example,
  given this basic `phx-click` event:

      <Button phx-click="inc">+</Button>

  Imagine you need to target your current component, and apply a loading state
  to the parent container while the client awaits the server acknowledgement:

      alias LiveViewNative.LVN

      <Button phx-click={LVN.push("inc", loading: ".thermo", target: @myself)}>+</Button>

  Push commands also compose with all other utilities. For example,
  to add a class when pushing:

      <Button phx-click={
        LVN.push("inc", loading: ".thermo", target: @myself)
        |> LVN.add_class("warmer", to: ".thermo")
      }>+</Button>

  Any `phx-value-*` attributes will also be included in the payload, their
  values will be overwritten by values given directly to `push/1`. Any
  `phx-target` attribute will also be used, and overwritten.

      <Button
        phx-click={LVN.push("inc", value: %{limit: 40})}
        phx-value-room="bedroom"
        phx-value-limit="this value will be 40"
        phx-target={@myself}
      >+</Button>

  ## Custom LVN events with `LVN.dispatch/1` and `window.addEventListener`

  `dispatch/1` can be used to dispatch custom Native events to
  elements. For example, you can use `LVN.dispatch("click", to: "#foo")`,
  to dispatch a click event to an element.

  This also means you can augment your elements with custom events,
  by using Native's `window.addEventListener` and invoking them
  with `dispatch/1`. For example, imagine you want to provide
  a copy-to-clipboard functionality in your application. You can
  add a custom event for it:

      window.addEventListener("my_app:clipcopy", (event) => {
        if ("clipboard" in navigator) {
          const text = event.target.textContent;
          navigator.clipboard.writeText(text);
        } else {
          alert("Sorry, your browser does not support clipboard copy.");
        }
      });

  Now you can have a Button like this:

      <Button phx-click={LVN.dispatch("my_app:clipcopy", to: "#element-with-text-to-copy")}>
        Copy content
      </Button>

  The combination of `dispatch/1` with `window.addEventListener` is
  a powerful mechanism to increase the amount of actions you can trigger
  client-side from your LiveView code.

  You can also use `window.addEventListener` to listen to events pushed
  from the server. You can learn more in our [LVN interoperability guide](lvn-interop.md).
  '''

  alias LiveViewNative.LVN
  alias Phoenix.LiveView.JS

  defstruct ops: []

  @default_transition_time 200

  defimpl Phoenix.HTML.Safe, for: LiveViewNative.LVN do
    def to_iodata(%LiveViewNative.LVN{} = lvn) do
      Phoenix.HTML.Engine.html_escape(Phoenix.json_library().encode!(lvn.ops))
    end
  end

  @doc """
  Pushes an event to the server.

    * `event` - The string event name to push.

  ## Options

    * `:target` - A selector or component ID to push to. This value will
      overwrite any `phx-target` attribute present on the element.
    * `:loading` - A selector to apply the phx loading classes to.
    * `:page_loading` - Boolean to trigger the phx:page-loading-start and
      phx:page-loading-stop events for this push. Defaults to `false`.
    * `:value` - A map of values to send to the server. These values will be
      merged over any `phx-value-*` attributes that are present on the element.
      All keys will be treated as strings when merging.

  ## Examples

      <Button phx-click={LVN.push("clicked")}>click me!</Button>
      <Button phx-click={LVN.push("clicked", value: %{id: @id})}>click me!</Button>
      <Button phx-click={LVN.push("clicked", page_loading: true)}>click me!</Button>
  """
  def push(event) when is_binary(event) do
    push(%LVN{}, event, [])
  end

  @doc "See `push/1`."
  def push(event, opts) when is_binary(event) and is_list(opts) do
    push(%LVN{}, event, opts)
  end

  def push(%LVN{} = lvn, event) when is_binary(event) do
    push(lvn, event, [])
  end

  @doc "See `push/1`."
  def push(%LVN{} = lvn, event, opts) when is_binary(event) and is_list(opts) do
    js = JS.push(%JS{ops: lvn.ops}, event, opts)
    %LVN{ops: js.ops}
  end

  @doc """
  Dispatches an event to the ViewTree.

    * `event` - The string event name to dispatch.

  *Note*: All events dispatched are of a type
  [CustomEvent](https://developer.mozilla.org/en-US/docs/Web/API/CustomEvent),
  with the exception of `"click"`. For a `"click"`, a
  [MouseEvent](https://developer.mozilla.org/en-US/docs/Web/API/MouseEvent)
  is dispatched to properly simulate a UI click.

  For emitted `CustomEvent`'s, the event detail will contain a `dispatcher`,
  which references the ViewTree node that dispatched the LVN event to the target
  element.

  ## Options

    * `:to` - An optional ViewTree selector to dispatch the event to.
      Defaults to the interacted element.
    * `:detail` - An optional detail map to dispatch along
      with the client event. The details will be available in the
      `event.detail` attribute for event listeners.
    * `:bubbles` – A boolean flag to bubble the event or not. Defaults to `true`.

  ## Examples
      # TODO: replace with native example
      window.addEventListener("click", e => console.log("clicked!", e.detail))

      <Button phx-click={LVN.dispatch("click", to: ".nav")}>Click me!</Button>
  """
  def dispatch(lvn \\ %LVN{}, event)
  def dispatch(%LVN{} = lvn, event), do: dispatch(lvn, event, [])
  def dispatch(event, opts), do: dispatch(%LVN{}, event, opts)

  @doc "See `dispatch/2`."
  def dispatch(%LVN{} = lvn, event, opts) do
    js = JS.dispatch(%JS{ops: lvn.ops}, event, opts)
    %LVN{ops: js.ops}
  end

  @doc """
  Toggles element visibility.

  ## Options

    * `:to` - An optional ViewTree selector to toggle.
      Defaults to the interacted element.
    * `:in` - A string of classes to apply when toggling in, or
      a 3-tuple containing the transition class, the class to apply
      to start the transition, and the ending transition class, such as:
      `{"ease-out duration-300", "opacity-0", "opacity-100"}`
    * `:out` - A string of classes to apply when toggling out, or
      a 3-tuple containing the transition class, the class to apply
      to start the transition, and the ending transition class, such as:
      `{"ease-out duration-300", "opacity-100", "opacity-0"}`
    * `:time` - The time in milliseconds to apply the transition `:in` and `:out` classes.
      Defaults to #{@default_transition_time}.
    * `:display` - An optional display value to set when toggling in. Defaults
      to `"block"`.

  When the toggle is complete on the client, a `phx:show-start` or `phx:hide-start`, and
  `phx:show-end` or `phx:hide-end` event will be dispatched to the toggled elements.

  ## Examples

      <Text id="item">My Item</Text>

      <Button phx-click={LVN.toggle(to: "#item")}>
        toggle item!
      </Button>

      <Button phx-click={LVN.toggle(to: "#item", in: "fade-in-scale", out: "fade-out-scale")}>
        toggle fancy!
      </Button>
  """
  def toggle(opts \\ [])
  def toggle(%LVN{} = lvn), do: toggle(lvn, [])
  def toggle(opts) when is_list(opts), do: toggle(%LVN{}, opts)

  @doc "See `toggle/1`."
  def toggle(lvn, opts) when is_list(opts) do
    js = JS.toggle(%JS{ops: lvn.ops}, opts)
    %LVN{ops: js.ops}
  end

  @doc """
  Shows elements.

  ## Options

    * `:to` - An optional ViewTree selector to show.
      Defaults to the interacted element.
    * `:transition` - A string of classes to apply before showing or
      a 3-tuple containing the transition class, the class to apply
      to start the transition, and the ending transition class, such as:
      `{"ease-out duration-300", "opacity-0", "opacity-100"}`
    * `:time` - The time in milliseconds to apply the transition from `:transition`.
      Defaults to #{@default_transition_time}.
    * `:display` - An optional display value to set when showing. Defaults to `"block"`.

  During the process, the following events will be dispatched to the shown elements:

    * When the action is triggered on the client, `phx:show-start` is dispatched.
    * After the time specified by `:time`, `phx:show-end` is dispatched.

  ## Examples

      <Text id="item">My Item</Text>

      <Button phx-click={LVN.show(to: "#item")}>
        show!
      </Button>

      <Button phx-click={LVN.show(to: "#item", transition: "fade-in-scale")}>
        show fancy!
      </Button>
  """
  def show(opts \\ [])
  def show(%LVN{} = lvn), do: show(lvn, [])
  def show(opts) when is_list(opts), do: show(%LVN{}, opts)

  @doc "See `show/1`."
  def show(lvn, opts) when is_list(opts) do
    js = JS.show(%JS{ops: lvn.ops}, opts)
    %LVN{ops: js.ops}
  end

  @doc """
  Hides elements.

  ## Options

    * `:to` - An optional ViewTree selector to hide.
      Defaults to the interacted element.
    * `:transition` - A string of classes to apply before hiding or
      a 3-tuple containing the transition class, the class to apply
      to start the transition, and the ending transition class, such as:
      `{"ease-out duration-300", "opacity-100", "opacity-0"}`
    * `:time` - The time in milliseconds to apply the transition from `:transition`.
      Defaults to #{@default_transition_time}.

  During the process, the following events will be dispatched to the hidden elements:

    * When the action is triggered on the client, `phx:hide-start` is dispatched.
    * After the time specified by `:time`, `phx:hide-end` is dispatched.

  ## Examples

      <Text id="item">My Item</Text>

      <Button phx-click={LVN.hide(to: "#item")}>
        hide!
      </Button>

      <Button phx-click={LVN.hide(to: "#item", transition: "fade-out-scale")}>
        hide fancy!
      </Button>
  """
  def hide(opts \\ [])
  def hide(%LVN{} = lvn), do: hide(lvn, [])
  def hide(opts) when is_list(opts), do: hide(%LVN{}, opts)

  @doc "See `hide/1`."
  def hide(lvn, opts) when is_list(opts) do
    js = JS.hide(%JS{ops: lvn.ops}, opts)
    %LVN{ops: js.ops}
  end

  @doc """
  Adds classes to elements.

    * `names` - A string with one or more class names to add.

  ## Options

    * `:to` - An optional ViewTree selector to add classes to.
      Defaults to the interacted element.
    * `:transition` - A string of classes to apply before adding classes or
      a 3-tuple containing the transition class, the class to apply
      to start the transition, and the ending transition class, such as:
      `{"ease-out duration-300", "opacity-0", "opacity-100"}`
    * `:time` - The time in milliseconds to apply the transition from `:transition`.
      Defaults to #{@default_transition_time}.

  ## Examples

      <Text id="item">My Item</Text>
      <Button phx-click={LVN.add_class("highlight underline", to: "#item")}>
        highlight!
      </Button>
  """
  def add_class(names) when is_binary(names), do: add_class(%LVN{}, names, [])

  @doc "See `add_class/1`."
  def add_class(%LVN{} = lvn, names) when is_binary(names) do
    add_class(lvn, names, [])
  end

  def add_class(names, opts) when is_binary(names) and is_list(opts) do
    add_class(%LVN{}, names, opts)
  end

  @doc "See `add_class/1`."
  def add_class(%LVN{} = lvn, names, opts) when is_binary(names) and is_list(opts) do
    js = JS.add_class(%JS{ops: lvn.ops}, names, opts)
    %LVN{ops: js.ops}
  end

  @doc """
  Adds or removes element classes based on presence.

    * `names` - A string with one or more class names to toggle.

  ## Options

    * `:to` - An optional ViewTree selector to target.
      Defaults to the interacted element.
    * `:transition` - A string of classes to apply before adding classes or
      a 3-tuple containing the transition class, the class to apply
      to start the transition, and the ending transition class, such as:
      `{"ease-out duration-300", "opacity-0", "opacity-100"}`
    * `:time` - The time in milliseconds to apply the transition from `:transition`.
      Defaults to #{@default_transition_time}.

  ## Examples

      <Text id="item">My Item</Text>
      <Button phx-click={LVN.toggle_class("active", to: "#item")}>
        toggle active!
      </Button>
  """
  def toggle_class(names) when is_binary(names), do: toggle_class(%LVN{}, names, [])

  def toggle_class(%LVN{} = lvn, names) when is_binary(names) do
    toggle_class(lvn, names, [])
  end

  def toggle_class(names, opts) when is_binary(names) and is_list(opts) do
    toggle_class(%LVN{}, names, opts)
  end

  def toggle_class(%LVN{} = lvn, names, opts) when is_binary(names) and is_list(opts) do
    js = JS.toggle_class(%JS{ops: lvn.ops}, names, opts)
    %LVN{ops: js.ops}
  end

  @doc """
  Removes classes from elements.

    * `names` - A string with one or more class names to remove.

  ## Options

    * `:to` - An optional ViewTree selector to remove classes from.
      Defaults to the interacted element.
    * `:transition` - A string of classes to apply before removing classes or
      a 3-tuple containing the transition class, the class to apply
      to start the transition, and the ending transition class, such as:
      `{"ease-out duration-300", "opacity-0", "opacity-100"}`
    * `:time` - The time in milliseconds to apply the transition from `:transition`.
      Defaults to #{@default_transition_time}.

  ## Examples

      <Text id="item">My Item</Text>
      <Button phx-click={LVN.remove_class("highlight underline", to: "#item")}>
        remove highlight!
      </Button>
  """
  def remove_class(names) when is_binary(names), do: remove_class(%LVN{}, names, [])

  @doc "See `remove_class/1`."
  def remove_class(%LVN{} = lvn, names) when is_binary(names) do
    remove_class(lvn, names, [])
  end

  def remove_class(names, opts) when is_binary(names) and is_list(opts) do
    remove_class(%LVN{}, names, opts)
  end

  @doc "See `remove_class/1`."
  def remove_class(%LVN{} = lvn, names, opts) when is_binary(names) and is_list(opts) do
    js = JS.remove_class(%JS{ops: lvn.ops}, names, opts)
    %LVN{ops: js.ops}
  end

  @doc """
  Transitions elements.

    * `transition` - A string of classes to apply before removing classes or
      a 3-tuple containing the transition class, the class to apply
      to start the transition, and the ending transition class, such as:
      `{"ease-out duration-300", "opacity-0", "opacity-100"}`

  Transitions are useful for temporarily adding an animation class
  to elements, such as for highlighting content changes.

  ## Options

    * `:to` - An optional ViewTree selector to apply transitions to.
      Defaults to the interacted element.
    * `:time` - The time in milliseconds to apply the transition from `:transition`.
      Defaults to #{@default_transition_time}.

  ## Examples

      <Text id="item">My Item</Text>
      <Button phx-click={LVN.transition("shake", to: "#item")}>Shake!</Button>
  """
  def transition(transition) when is_binary(transition) or is_tuple(transition) do
    transition(%LVN{}, transition, [])
  end

  @doc "See `transition/1`."
  def transition(transition, opts)
      when (is_binary(transition) or is_tuple(transition)) and is_list(opts) do
    transition(%LVN{}, transition, opts)
  end

  def transition(%LVN{} = lvn, transition) when is_binary(transition) or is_tuple(transition) do
    transition(lvn, transition, [])
  end

  @doc "See `transition/1`."
  def transition(%LVN{} = lvn, transition, opts)
      when (is_binary(transition) or is_tuple(transition)) and is_list(opts) do
    js = JS.transition(%JS{ops: lvn.ops}, transition, opts)
    %LVN{ops: js.ops}
  end

  @doc """
  Sets an attribute on elements.

  Accepts a tuple containing the string attribute name/value pair.

  ## Options

    * `:to` - An optional ViewTree selector to add attributes to.
      Defaults to the interacted element.

  ## Examples

      <Button phx-click={LVN.set_attribute({"aria-expanded", "true"}, to: "#dropdown")}>
        show
      </Button>
  """
  def set_attribute({attr, val}), do: set_attribute(%LVN{}, {attr, val}, [])

  @doc "See `set_attribute/1`."
  def set_attribute({attr, val}, opts) when is_list(opts),
    do: set_attribute(%LVN{}, {attr, val}, opts)

  def set_attribute(%LVN{} = lvn, {attr, val}), do: set_attribute(lvn, {attr, val}, [])

  @doc "See `set_attribute/1`."
  def set_attribute(%LVN{} = lvn, {attr, val}, opts) when is_list(opts) do
    js = JS.set_attribute(%JS{ops: lvn.ops}, {attr, val}, opts)
    %LVN{ops: js.ops}
  end

  @doc """
  Removes an attribute from elements.

    * `attr` - The string attribute name to remove.

  ## Options

    * `:to` - An optional ViewTree selector to remove attributes from.
      Defaults to the interacted element.

  ## Examples

      <Button phx-click={LVN.remove_attribute("aria-expanded", to: "#dropdown")}>
        hide
      </Button>
  """
  def remove_attribute(attr), do: remove_attribute(%LVN{}, attr, [])

  @doc "See `remove_attribute/1`."
  def remove_attribute(attr, opts) when is_list(opts),
    do: remove_attribute(%LVN{}, attr, opts)

  def remove_attribute(%LVN{} = lvn, attr), do: remove_attribute(lvn, attr, [])

  @doc "See `remove_attribute/1`."
  def remove_attribute(%LVN{} = lvn, attr, opts) when is_list(opts) do
    js = JS.remove_attribute(%JS{ops: lvn.ops}, attr, opts)
    %LVN{ops: js.ops}
  end

  @doc """
  Sets or removes element attribute based on attribute presence.

  Accepts a two or three-element tuple:

  * `{attr, val}` - Sets the attribute to the given value or removes it
  * `{attr, val1, val2}` - Toggles the attribute between `val1` and `val2`

  ## Options

    * `:to` - An optional ViewTree selector to set or remove attributes from.
      Defaults to the interacted element.

  ## Examples

      <Button phx-click={LVN.toggle_attribute({"aria-expanded", "true", "false"}, to: "#dropdown")}>
        toggle
      </Button>

      <Button phx-click={LVN.toggle_attribute({"open", "true"}, to: "#dialog")}>
        toggle
      </Button>

  """
  def toggle_attribute({attr, val}), do: toggle_attribute(%LVN{}, {attr, val}, [])
  def toggle_attribute({attr, val1, val2}), do: toggle_attribute(%LVN{}, {attr, val1, val2}, [])

  @doc "See `toggle_attribute/1`."
  def toggle_attribute({attr, val}, opts) when is_list(opts),
    do: toggle_attribute(%LVN{}, {attr, val}, opts)

  def toggle_attribute({attr, val1, val2}, opts) when is_list(opts),
    do: toggle_attribute(%LVN{}, {attr, val1, val2}, opts)

  def toggle_attribute(%LVN{} = lvn, {attr, val}), do: toggle_attribute(lvn, {attr, val}, [])

  def toggle_attribute(%LVN{} = lvn, {attr, val1, val2}),
    do: toggle_attribute(lvn, {attr, val1, val2}, [])

  @doc "See `toggle_attribute/1`."
  def toggle_attribute(%LVN{} = lvn, {attr, val}, opts) when is_list(opts) do
    js = JS.toggle_attribute(%JS{ops: lvn.ops}, {attr, val}, opts)
    %LVN{ops: js.ops}
  end

  def toggle_attribute(%LVN{} = lvn, {attr, val1, val2}, opts) when is_list(opts) do
    js = JS.toggle_attribute(%JS{ops: lvn.ops}, {attr, val1, val2}, opts)
    %LVN{ops: js.ops}
  end

  @doc """
  Sends focus to a selector.

  ## Options

    * `:to` - An optional ViewTree selector to send focus to.
      Defaults to the current element.

  ## Examples

      LVN.focus(to: "main")
  """
  def focus(opts \\ [])
  def focus(%LVN{} = lvn), do: focus(lvn, [])
  def focus(opts) when is_list(opts), do: focus(%LVN{}, opts)

  @doc "See `focus/1`."
  def focus(%LVN{} = lvn, opts) when is_list(opts) do
    js = JS.focus(%JS{ops: lvn.ops}, opts)
    %LVN{ops: js.ops}
  end

  @doc """
  Sends focus to the first focusable child in selector.

  ## Options

    * `:to` - An optional ViewTree selector to focus.
      Defaults to the current element.

  ## Examples

      LVN.focus_first(to: "#modal")
  """
  def focus_first(opts \\ [])
  def focus_first(%LVN{} = lvn), do: focus_first(lvn, [])
  def focus_first(opts) when is_list(opts), do: focus_first(%LVN{}, opts)

  @doc "See `focus_first/1`."
  def focus_first(%LVN{} = lvn, opts) when is_list(opts) do
    js = JS.focus_first(%JS{ops: lvn.ops}, opts)
    %LVN{ops: js.ops}
  end

  @doc """
  Pushes focus from the source element to be later popped.

  ## Options

    * `:to` - An optional ViewTree selector to push focus to.
      Defaults to the current element.

  ## Examples

      LVN.push_focus()
      LVN.push_focus(to: "#my-Button")
  """
  def push_focus(opts \\ [])
  def push_focus(%LVN{} = lvn), do: push_focus(lvn, [])
  def push_focus(opts) when is_list(opts), do: push_focus(%LVN{}, opts)

  @doc "See `push_focus/1`."
  def push_focus(%LVN{} = lvn, opts) when is_list(opts) do
    js = JS.push_focus(%JS{ops: lvn.ops}, opts)
    %LVN{ops: js.ops}
  end

  @doc """
  Focuses the last pushed element.

  ## Examples

      LVN.pop_focus()
  """
  def pop_focus(%LVN{} = lvn \\ %LVN{}) do
    js = JS.pop_focus(%JS{ops: lvn.ops})
    %LVN{ops: js.ops}
  end

  @doc """
  Sends a navigation event to the server and updates the browser's pushState history.

  ## Options

    * `:replace` - Whether to replace the browser's pushState history. Defaults to `false`.

  ## Examples

      LVN.navigate("/my-path")
  """
  def navigate(href) when is_binary(href) do
    navigate(%LVN{}, href, [])
  end

  @doc "See `navigate/1`."
  def navigate(href, opts) when is_binary(href) and is_list(opts) do
    navigate(%LVN{}, href, opts)
  end

  def navigate(%LVN{} = lvn, href) when is_binary(href) do
    navigate(lvn, href, [])
  end

  @doc "See `navigate/1`."
  def navigate(%LVN{} = lvn, href, opts) when is_binary(href) and is_list(opts) do
    js = JS.navigate(%JS{ops: lvn.ops}, href, opts)
    %LVN{ops: js.ops}
  end

  @doc """
  Sends a patch event to the server and updates the browser's pushState history.

  ## Options

    * `:replace` - Whether to replace the browser's pushState history. Defaults to `false`.

  ## Examples

      LVN.patch("/my-path")
  """
  def patch(href) when is_binary(href) do
    patch(%LVN{}, href, [])
  end

  @doc "See `patch/1`."
  def patch(href, opts) when is_binary(href) and is_list(opts) do
    patch(%LVN{}, href, opts)
  end

  def patch(%LVN{} = lvn, href) when is_binary(href) do
    patch(lvn, href, [])
  end

  @doc "See `patch/1`."
  def patch(%LVN{} = lvn, href, opts) when is_binary(href) and is_list(opts) do
    js = JS.patch(%JS{ops: lvn.ops}, href, opts)
    %LVN{ops: js.ops}
  end

  @doc """
  Executes LVN commands located in an element's attribute.

    * `attr` - The string attribute where the LVN command is specified

  ## Options

    * `:to` - An optional ViewTree selector to fetch the attribute from.
      Defaults to the current element.

  ## Examples

      <Text id="modal" phx-remove={LVN.hide("#modal")}>...</Text>
      <Button phx-click={LVN.exec("phx-remove", to: "#modal")}>close</Button>
  """
  def exec(attr) when is_binary(attr) do
    exec(%LVN{}, attr, [])
  end

  @doc "See `exec/1`."
  def exec(attr, opts) when is_binary(attr) and is_list(opts) do
    exec(%LVN{}, attr, opts)
  end

  def exec(%LVN{} = lvn, attr) when is_binary(attr) do
    exec(lvn, attr, [])
  end

  @doc "See `exec/1`."
  def exec(%LVN{} = lvn, attr, opts) when is_binary(attr) and is_list(opts) do
    js = JS.exec(%JS{ops: lvn.ops}, attr, opts)
    %LVN{ops: js.ops}
  end
end
