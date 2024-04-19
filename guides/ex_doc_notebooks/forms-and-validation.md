# Forms and Validation

[![Run in Livebook](https://livebook.dev/badge/v1/blue.svg)](https://livebook.dev/run?url=https%3A%2F%2Fraw.githubusercontent.com%2Fliveview-native%2Flive_view_native%2Fmain%2Fguides%livebooks%forms-and-validation.livemd)

## Overview

The [LiveView Native Live Form](https://github.com/liveview-native/liveview-native-live-form) project makes it easier to build forms in LiveView Native. This project enables you to group different [Control Views](https://developer.apple.com/documentation/swiftui/controls-and-indicators) inside of a `LiveForm` and control them collectively under a single `phx-change` or `phx-submit` event handler, rather than with multiple different `phx-change` event handlers.

Getting the most out of this material requires some understanding of the [Ecto](https://hexdocs.pm/ecto/Ecto.html) project and in particular a reasonably deep understanding of [Ecto.Changeset](https://hexdocs.pm/ecto/Ecto.Changeset.html). Review the linked Ecto documentation if you find any of the examples difficult to follow.

## Installing LiveView Native Live Form

To install LiveView Native Form, we need to add the `liveview-native-live-form` SwiftUI package to our iOS application.

Follow the [LiveView Native Form Installation Guide](https://github.com/liveview-native/liveview-native-live-form?tab=readme-ov-file#liveviewnativeliveform) on that project's README and come back to this guide after you have finished the installation process.

## Creating a Basic Form

Once you have the LiveView Native Form package installed, you can use the `LiveForm` and `LiveSubmitButton` views to build forms more conveniently.

Here's a basic example of a `LiveForm`. Keep in mind that `LiveForm` requires an `id` attribute.

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5FeGFtcGxlTGl2ZSBkb1xuICB1c2UgUGhvZW5peC5MaXZlVmlld1xuICB1c2UgTGl2ZVZpZXdOYXRpdmUuTGl2ZVZpZXdcblxuICBAaW1wbCB0cnVlXG4gIGRlZiByZW5kZXIoJXtmb3JtYXQ6IDpzd2lmdHVpfSA9IGFzc2lnbnMpIGRvXG4gICAgflNXSUZUVUlcIlwiXCJcbiAgICA8TGl2ZUZvcm0gaWQ9XCJteWZvcm1cIiBwaHgtc3VibWl0PVwic3VibWl0XCI+XG4gICAgICA8VGV4dEZpZWxkIG5hbWU9XCJteS10ZXh0XCIgPlBsYWNlaG9sZGVyPC9UZXh0RmllbGQ+XG4gICAgICA8TGl2ZVN1Ym1pdEJ1dHRvbj5TdWJtaXQ8L0xpdmVTdWJtaXRCdXR0b24+XG4gICAgPC9MaXZlRm9ybT5cbiAgICBcIlwiXCJcbiAgZW5kXG5cbiAgQGltcGwgdHJ1ZVxuICBkZWYgaGFuZGxlX2V2ZW50KFwic3VibWl0XCIsIHBhcmFtcywgc29ja2V0KSBkb1xuICAgIElPLmluc3BlY3QocGFyYW1zKVxuICAgIHs6bm9yZXBseSwgc29ja2V0fVxuICBlbmRcbmVuZCIsInBhdGgiOiIvIn0","chunks":[[0,109],[111,463],[576,45],[623,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
require KinoLiveViewNative.Livebook
import KinoLiveViewNative.Livebook
import Kernel, except: [defmodule: 2]

defmodule Server.ExampleLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <LiveForm id="myform" phx-submit="submit">
      <TextField name="my-text">Placeholder</TextField>
      <LiveSubmitButton>Submit</LiveSubmitButton>
    </LiveForm>
    """
  end

  @impl true
  def handle_event("submit", params, socket) do
    IO.inspect(params)
    {:noreply, socket}
  end
end
|> KinoLiveViewNative.register("/", ":index")

import KinoLiveViewNative.Livebook, only: []
import Kernel
:ok
```

When a form is submitted, its data is sent as a map where each key is the 'name' attribute of the form's control views. Evaluate the example above in your simulator and you will see a map similar to the following:

<!-- livebook:{"force_markdown":true} -->

```elixir
%{"my-text" => "some value"}
```

In a real-world application you could use these params to trigger some application logic, such as inserting a record into the database.

## Controls and Indicators

We've already covered many individual controls and indicator views that you can use inside of forms. For more information on those, go to the [Interactive SwiftUI Views](https://hexdocs.pm/live_view_native/interactive-swiftui-views.html) guide.

<!-- livebook:{"break_markdown":true} -->

### Your Turn

Create a form that has `TextField`, `Slider`, `Toggle`, and `DatePicker` fields.

### Example Solution

```elixir
defmodule Server.MultiInputFormLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <LiveForm id="myform" phx-submit="submit">
      <TextField name="my-text" >Placeholder</TextField>
      <Slider name="my-slider" />
      <Toggle name="my-toggle" />
      <DatePicker name="my-date-picker" />
      <LiveSubmitButton>Submit</LiveSubmitButton>
    </LiveForm>
    """
  end

  @impl true
  def handle_event("submit", params, socket) do
    IO.inspect(params)
    {:noreply, socket}
  end
end
```



<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5NdWx0aUlucHV0Rm9ybUxpdmUgZG9cbiAgdXNlIFBob2VuaXguTGl2ZVZpZXdcbiAgdXNlIExpdmVWaWV3TmF0aXZlLkxpdmVWaWV3XG5cbiAgQGltcGwgdHJ1ZVxuICBkZWYgcmVuZGVyKCV7Zm9ybWF0OiA6c3dpZnR1aX0gPSBhc3NpZ25zKSBkb1xuICAgIH5TV0lGVFVJXCJcIlwiXG4gICAgPCEtLSBFbnRlciB5b3VyIHNvbHV0aW9uIGhlcmUgLS0+XG4gICAgXCJcIlwiXG4gIGVuZFxuXG4gICMgWW91IG1heSB1c2UgdGhpcyBoYW5kbGVyIHRvIHRlc3QgeW91ciBzb2x1dGlvbi5cbiAgIyBZb3Ugc2hvdWxkIG5vdCBuZWVkIHRvIG1vZGlmeSB0aGlzIGhhbmRsZXIuXG4gIEBpbXBsIHRydWVcbiAgZGVmIGhhbmRsZV9ldmVudChcInN1Ym1pdFwiLCBwYXJhbXMsIHNvY2tldCkgZG9cbiAgICBJTy5pbnNwZWN0KHBhcmFtcylcbiAgICB7Om5vcmVwbHksIHNvY2tldH1cbiAgZW5kXG5lbmQiLCJwYXRoIjoiLyJ9","chunks":[[0,109],[111,438],[551,45],[598,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
require KinoLiveViewNative.Livebook
import KinoLiveViewNative.Livebook
import Kernel, except: [defmodule: 2]

defmodule Server.MultiInputFormLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <!-- Enter your solution here -->
    """
  end

  # You may use this handler to test your solution.
  # You should not need to modify this handler.
  @impl true
  def handle_event("submit", params, socket) do
    IO.inspect(params)
    {:noreply, socket}
  end
end
|> KinoLiveViewNative.register("/", ":index")

import KinoLiveViewNative.Livebook, only: []
import Kernel
:ok
```

### Controlled Values

Some control views such as the `Stepper` require manually displaying their value. In this case, we can store the form params in the socket and update them everytime the `phx-change` form binding submits an event. You can also use this pattern to provide default values.

Evaluate the example below to see this in action.

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5TdGVwcGVyTGl2ZSBkb1xuICB1c2UgUGhvZW5peC5MaXZlVmlld1xuICB1c2UgTGl2ZVZpZXdOYXRpdmUuTGl2ZVZpZXdcblxuICBAaW1wbCB0cnVlXG4gIGRlZiBtb3VudChfcGFyYW1zLCBfc2Vzc2lvbiwgc29ja2V0KSBkb1xuICAgIHs6b2ssIGFzc2lnbihzb2NrZXQsIHBhcmFtczogJXtcIm15LXN0ZXBwZXJcIiA9PiAxfSl9XG4gIGVuZFxuXG4gIEBpbXBsIHRydWVcbiAgZGVmIHJlbmRlcigle2Zvcm1hdDogOnN3aWZ0dWl9ID0gYXNzaWducykgZG9cbiAgICB+U1dJRlRVSVwiXCJcIlxuICAgIDxMaXZlRm9ybSBpZD1cIm15Zm9ybVwiIHBoeC1jaGFuZ2U9XCJjaGFuZ2VcIj5cbiAgICAgIDxTdGVwcGVyIG5hbWU9XCJteS1zdGVwcGVyXCIgdmFsdWU9e0BwYXJhbXNbXCJteS1zdGVwcGVyXCJdfT48JT0gQHBhcmFtc1tcIm15LXN0ZXBwZXJcIl0gJT48L1N0ZXBwZXI+XG4gICAgPC9MaXZlRm9ybT5cbiAgICBcIlwiXCJcbiAgZW5kXG5cbiAgQGltcGwgdHJ1ZVxuICBkZWYgaGFuZGxlX2V2ZW50KFwiY2hhbmdlXCIsIHBhcmFtcywgc29ja2V0KSBkb1xuICAgIElPLmluc3BlY3QocGFyYW1zKVxuICAgIHs6bm9yZXBseSwgYXNzaWduKHNvY2tldCwgcGFyYW1zOiBwYXJhbXMpfVxuICBlbmRcbmVuZCIsInBhdGgiOiIvIn0","chunks":[[0,109],[111,600],[713,45],[760,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
require KinoLiveViewNative.Livebook
import KinoLiveViewNative.Livebook
import Kernel, except: [defmodule: 2]

defmodule Server.StepperLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, params: %{"my-stepper" => 1})}
  end

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <LiveForm id="myform" phx-change="change">
      <Stepper name="my-stepper" value={@params["my-stepper"]}><%= @params["my-stepper"] %></Stepper>
    </LiveForm>
    """
  end

  @impl true
  def handle_event("change", params, socket) do
    IO.inspect(params)
    {:noreply, assign(socket, params: params)}
  end
end
|> KinoLiveViewNative.register("/", ":index")

import KinoLiveViewNative.Livebook, only: []
import Kernel
:ok
```

### Secure Field

For password entry, or anytime you want to hide a given value, you can use the [SecureField](https://developer.apple.com/documentation/swiftui/securefield) view. This field works mostly the same as a `TextField` but hides the visual text.

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5TZWN1cmVMaXZlIGRvXG4gIHVzZSBQaG9lbml4LkxpdmVWaWV3XG4gIHVzZSBMaXZlVmlld05hdGl2ZS5MaXZlVmlld1xuXG4gIEBpbXBsIHRydWVcbiAgZGVmIHJlbmRlcigle2Zvcm1hdDogOnN3aWZ0dWl9ID0gYXNzaWducykgZG9cbiAgICB+U1dJRlRVSVwiXCJcIlxuICAgIDxTZWN1cmVGaWVsZCBwaHgtY2hhbmdlPVwiY2hhbmdlXCI+RW50ZXIgYSBQYXNzd29yZDwvU2VjdXJlRmllbGQ+XG4gICAgXCJcIlwiXG4gIGVuZFxuXG4gIEBpbXBsIHRydWVcbiAgZGVmIGhhbmRsZV9ldmVudChcImNoYW5nZVwiLCBwYXJhbXMsIHNvY2tldCkgZG9cbiAgICBJTy5pbnNwZWN0KHBhcmFtcylcbiAgICB7Om5vcmVwbHksIHNvY2tldH1cbiAgZW5kXG5lbmQiLCJwYXRoIjoiLyJ9","chunks":[[0,109],[111,360],[473,45],[520,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
require KinoLiveViewNative.Livebook
import KinoLiveViewNative.Livebook
import Kernel, except: [defmodule: 2]

defmodule Server.SecureLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <SecureField phx-change="change">Enter a Password</SecureField>
    """
  end

  @impl true
  def handle_event("change", params, socket) do
    IO.inspect(params)
    {:noreply, socket}
  end
end
|> KinoLiveViewNative.register("/", ":index")

import KinoLiveViewNative.Livebook, only: []
import Kernel
:ok
```

## Keyboard Types

To format a `TextField` for specific input types we can use the [keyboardType](https://developer.apple.com/documentation/swiftui/view/keyboardtype(_:)) modifier.

For a complete list of accepted keyboard types, see the [UIKeyboardType](https://developer.apple.com/documentation/uikit/uikeyboardtype) documentation.

Below we've created several different common keyboard types. We've also included a generic `keyboard-*` to demonstrate how you can make a reusable class.

```elixir
defmodule KeyboardStylesheet do
  use LiveViewNative.Stylesheet, :swiftui

  ~SHEET"""
  "number-pad" do
    keyboardType(.numberPad)
  end

  "email-address" do
    keyboardType(.emailAddress)
  end

  "phone-pad" do
    keyboardType(.phonePad)
  end

  "keyboard-" <> type do
    keyboardType(to_ime(type))
  end
  """
end
```

Evaluate the example below to see the different keyboards as you focus on each input. If you don't see the keyboard, go to `I/O` -> `Keyboard` -> `Toggle Software Keyboard` to enable the software keyboard in your simulator.

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5LZXlib2FyZExpdmUgZG9cbiAgdXNlIFBob2VuaXguTGl2ZVZpZXdcbiAgdXNlIExpdmVWaWV3TmF0aXZlLkxpdmVWaWV3XG4gIHVzZSBLZXlib2FyZFN0eWxlc2hlZXRcblxuICBAaW1wbCB0cnVlXG4gIGRlZiByZW5kZXIoJXtmb3JtYXQ6IDpzd2lmdHVpfSA9IGFzc2lnbnMpIGRvXG4gICAgflNXSUZUVUlcIlwiXCJcbiAgICA8VGV4dEZpZWxkIGNsYXNzPVwiZW1haWwtYWRkcmVzc1wiPkVudGVyIEVtYWlsPC9UZXh0RmllbGQ+XG4gICAgPFRleHRGaWVsZCBjbGFzcz1cInBob25lLXBhZFwiPkVudGVyIFBob25lPC9UZXh0RmllbGQ+XG4gICAgPFRleHRGaWVsZCBjbGFzcz1cIm51bWJlci1wYWRcIj5FbnRlciBOdW1iZXI8L1RleHRGaWVsZD5cbiAgICA8VGV4dEZpZWxkIGNsYXNzPVwia2V5Ym9hcmQtbnVtYmVyUGFkXCI+RW50ZXIgTnVtYmVyPC9UZXh0RmllbGQ+XG4gICAgXCJcIlwiXG4gIGVuZFxuXG4gIGRlZiByZW5kZXIoYXNzaWducykgZG9cbiAgICB+SFwiXCJcIlxuICAgIDxwPkhlbGxvIGZyb20gTGl2ZVZpZXchPC9wPlxuICAgIFwiXCJcIlxuICBlbmRcbmVuZCIsInBhdGgiOiIvIn0","chunks":[[0,109],[111,531],[644,45],[691,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
require KinoLiveViewNative.Livebook
import KinoLiveViewNative.Livebook
import Kernel, except: [defmodule: 2]

defmodule Server.KeyboardLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView
  use KeyboardStylesheet

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <TextField class="email-address">Enter Email</TextField>
    <TextField class="phone-pad">Enter Phone</TextField>
    <TextField class="number-pad">Enter Number</TextField>
    <TextField class="keyboard-numberPad">Enter Number</TextField>
    """
  end

  def render(assigns) do
    ~H"""
    <p>Hello from LiveView!</p>
    """
  end
end
|> KinoLiveViewNative.register("/", ":index")

import KinoLiveViewNative.Livebook, only: []
import Kernel
:ok
```

## Validation

In this section, we'll focus mainly on using [Ecto Changesets](https://hexdocs.pm/ecto/Ecto.Changeset.html) to validate data, but know that this is not the only way to validate data if you would like to write your own custom logic in the form event handlers, you absolutely can.

<!-- livebook:{"break_markdown":true} -->

### LiveView Native Changesets Coming Soon!

LiveView Native Form doesn't currently natively support [Changesets](https://hexdocs.pm/ecto/Ecto.Changeset.html) and [Phoenix.HTML.Form](https://hexdocs.pm/phoenix_html/Phoenix.HTML.Form.html) structs the way a traditional [Phoenix.Component.form](https://hexdocs.pm/phoenix_live_view/Phoenix.Component.html#form/1) does. However there is an [open issue](https://github.com/liveview-native/liveview-native-live-form/issues/5) to add this behavior so this may change in the near future. As a result, this section is somewhat more verbose than will be necessary in the future, as we have to manually define much of the error handling logic that we expect will no longer be necessary in version `0.3` of LiveView Native.

To make error handling easier, we've defined an `ErrorUtils` module below that will handle extracting the error message out of a Changeset. This will not be necessary in future versions of LiveView Native, but is a convenient helper for now.

```elixir
defmodule ErrorUtils do
  def error_message(errors, field) do
    with {msg, opts} <- errors[field] do
      Server.CoreComponents.translate_error({msg, opts})
    else
      _ -> ""
    end
  end
end
```

For the sake of context, the `translate_message/2` function handles formatting Ecto Changeset errors. For example, it will inject values such as `count` into the string.

```elixir
Server.CoreComponents.translate_error(
  {"name must be longer than %{count} characters", [count: 10]}
)
```

### Changesets

Here's a `User` changeset we're going to use to validate a `User` struct's `email` field.

```elixir
defmodule User do
  import Ecto.Changeset
  defstruct [:email]
  @types %{email: :string}

  def changeset(user, params) do
    {user, @types}
    |> cast(params, [:email])
    |> validate_required([:email])
    |> validate_format(:email, ~r/@/)
  end
end
```

We're going to define an `error` class so errors will appear red and be left-aligned.

```elixir
defmodule ErrorStylesheet do
  use LiveViewNative.Stylesheet, :swiftui

  ~SHEET"""
  "error" do
    foregroundStyle(.red)
    frame(maxWidth: .infinity, alignment: .leading)
  end
  """
end
```

Then, we're going to create a LiveView that uses the `User` changeset to validate data.

Evaluate the example below and view it in your simulator. We've included and `IO.inspect/2` call to view the changeset after submitting the form. Try submitting the form with different values to understand how those values affect the changeset.

<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5Gb3JtVmFsaWRhdGlvbkxpdmUgZG9cbiAgdXNlIFBob2VuaXguTGl2ZVZpZXdcbiAgdXNlIExpdmVWaWV3TmF0aXZlLkxpdmVWaWV3XG4gIHVzZSBFcnJvclN0eWxlc2hlZXRcblxuICBAaW1wbCB0cnVlXG4gIGRlZiBtb3VudChfcGFyYW1zLCBfc2Vzc2lvbiwgc29ja2V0KSBkb1xuICAgIHVzZXJfY2hhbmdlc2V0ID0gVXNlci5jaGFuZ2VzZXQoJVVzZXJ7fSwgJXt9KVxuICAgIHs6b2ssIGFzc2lnbihzb2NrZXQsIDp1c2VyX2NoYW5nZXNldCwgdXNlcl9jaGFuZ2VzZXQpfVxuICBlbmRcblxuICBAaW1wbCB0cnVlXG4gIGRlZiByZW5kZXIoJXtmb3JtYXQ6IDpzd2lmdHVpfSA9IGFzc2lnbnMpIGRvXG4gICAgflNXSUZUVUlcIlwiXCJcbiAgICA8TGl2ZUZvcm0gaWQ9XCJteWZvcm1cIiBwaHgtY2hhbmdlPVwidmFsaWRhdGVcIiBwaHgtc3VibWl0PVwic3VibWl0XCI+XG4gICAgICA8VGV4dEZpZWxkIG5hbWU9XCJlbWFpbFwiID5FbnRlciB5b3VyIGVtYWlsPC9UZXh0RmllbGQ+XG4gICAgICA8VGV4dCA6aWY9e0B1c2VyX2NoYW5nZXNldC5hY3Rpb259IGNsYXNzPVwiZXJyb3JcIj5cbiAgICAgICAgPCU9IEVycm9yVXRpbHMuZXJyb3JfbWVzc2FnZShAdXNlcl9jaGFuZ2VzZXQuZXJyb3JzLCA6ZW1haWwpICU+XG4gICAgICA8L1RleHQ+XG4gICAgICA8TGl2ZVN1Ym1pdEJ1dHRvbj5TdWJtaXQ8L0xpdmVTdWJtaXRCdXR0b24+XG4gICAgPC9MaXZlRm9ybT5cbiAgICBcIlwiXCJcbiAgZW5kXG5cbiAgQGltcGwgdHJ1ZVxuICBkZWYgaGFuZGxlX2V2ZW50KFwidmFsaWRhdGVcIiwgcGFyYW1zLCBzb2NrZXQpIGRvXG4gICAgdXNlcl9jaGFuZ2VzZXQgPVxuICAgICAgVXNlci5jaGFuZ2VzZXQoJVVzZXJ7fSwgcGFyYW1zKVxuICAgICAgIyBQcmVzZXJ2ZSB0aGUgYDphY3Rpb25gIGZpZWxkIHNvIGVycm9ycyBkbyBub3QgdmFuaXNoLlxuICAgICAgfD4gTWFwLnB1dCg6YWN0aW9uLCBzb2NrZXQuYXNzaWducy51c2VyX2NoYW5nZXNldC5hY3Rpb24pXG5cbiAgICB7Om5vcmVwbHksIGFzc2lnbihzb2NrZXQsIDp1c2VyX2NoYW5nZXNldCwgdXNlcl9jaGFuZ2VzZXQpfVxuICBlbmRcblxuICBkZWYgaGFuZGxlX2V2ZW50KFwic3VibWl0XCIsIHBhcmFtcywgc29ja2V0KSBkb1xuICAgIHVzZXJfY2hhbmdlc2V0ID1cbiAgICAgIFVzZXIuY2hhbmdlc2V0KCVVc2Vye30sIHBhcmFtcylcbiAgICAgICMgZmFraW5nIGEgRGF0YWJhc2UgaW5zZXJ0IGFjdGlvblxuICAgICAgfD4gTWFwLnB1dCg6YWN0aW9uLCA6aW5zZXJ0KVxuICAgICAgIyBTdWJtaXQgdGhlIGZvcm0gYW5kIGluc3BlY3QgdGhlIGxvZ3MgYmVsb3cgdG8gdmlldyB0aGUgY2hhbmdlc2V0LlxuICAgICAgfD4gSU8uaW5zcGVjdChsYWJlbDogXCJGb3JtIEZpZWxkIFZhbHVlc1wiKVxuXG4gICAgezpub3JlcGx5LCBhc3NpZ24oc29ja2V0LCA6dXNlcl9jaGFuZ2VzZXQsIHVzZXJfY2hhbmdlc2V0KX1cbiAgZW5kXG5lbmQiLCJwYXRoIjoiLyJ9","chunks":[[0,109],[111,1412],[1525,45],[1572,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
require KinoLiveViewNative.Livebook
import KinoLiveViewNative.Livebook
import Kernel, except: [defmodule: 2]

defmodule Server.FormValidationLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView
  use ErrorStylesheet

  @impl true
  def mount(_params, _session, socket) do
    user_changeset = User.changeset(%User{}, %{})
    {:ok, assign(socket, :user_changeset, user_changeset)}
  end

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <LiveForm id="myform" phx-change="validate" phx-submit="submit">
      <TextField name="email" >Enter your email</TextField>
      <Text :if={@user_changeset.action} class="error">
        <%= ErrorUtils.error_message(@user_changeset.errors, :email) %>
      </Text>
      <LiveSubmitButton>Submit</LiveSubmitButton>
    </LiveForm>
    """
  end

  @impl true
  def handle_event("validate", params, socket) do
    user_changeset =
      User.changeset(%User{}, params)
      # Preserve the `:action` field so errors do not vanish.
      |> Map.put(:action, socket.assigns.user_changeset.action)

    {:noreply, assign(socket, :user_changeset, user_changeset)}
  end

  def handle_event("submit", params, socket) do
    user_changeset =
      User.changeset(%User{}, params)
      # faking a Database insert action
      |> Map.put(:action, :insert)
      # Submit the form and inspect the logs below to view the changeset.
      |> IO.inspect(label: "Form Field Values")

    {:noreply, assign(socket, :user_changeset, user_changeset)}
  end
end
|> KinoLiveViewNative.register("/", ":index")

import KinoLiveViewNative.Livebook, only: []
import Kernel
:ok
```

In the code above, the `"sumbit"` and `"validate"` events update the changeset based on the current form params. This fills the `errors` field used by the `ErrorUtils` module to format the error message.

After submitting the form, the `:action` field of the changeset has a value of `:insert`, so the red Text appears using the `:if` conditional display logic.

In the future, this complexity will likely be handled by the `live_view_native_form` library, but for now this example exists to show you how to write your own error handling based on changesets if needed.

<!-- livebook:{"break_markdown":true} -->

### Empty Fields Send `"null"`.

If you submit a form with empty fields, those fields may currently send `"null"`. There is an [open issue](https://github.com/liveview-native/liveview-native-live-form/issues/6) to fix this bug, but it may affect your form behavior for now and require a temporary workaround until the issue is fixed.

## Mini Project: User Form

Taking everything you've learned, you're going to create a more complex user form with data validation and error displaying. We've defined a `FormStylesheet` you can use (and modify) if you would like to style your form.

```elixir
defmodule FormStylesheet do
  use LiveViewNative.Stylesheet, :swiftui

  ~SHEET"""
  "error" do
    foregroundStyle(.red)
    frame(maxWidth: .infinity, alignment: .leading)
  end

  "keyboard-" <> type do
    keyboardType(to_ime(type))
  end
  """
end
```

### User Changeset

First, create a `CustomUser` changeset below that handles data validation.

**Requirements**

* A user should have a `name` field
* A user should have a `password` string field of 10 or more characters. Note that for simplicity we are not hashing the password or following real security practices since our pretend application doesn't have a database. In real-world apps passwords should **never** be stored as a simple string, they should be encrypted.
* A user should have an `age` number field greater than `0` and less than `200`.
* A user should have an `email` field which matches an email format (including `@` is sufficient).
* A user should have a `accepted_terms` field which must be true.
* A user should have a `birthdate` field which is a date.
* All fields should be required

### Example Solution

```elixir
defmodule CustomUser do
  import Ecto.Changeset
  defstruct [:name, :password, :age, :email, :accepted_terms, :birthdate]

  @types %{
    name: :string,
    password: :string,
    age: :integer,
    email: :string,
    accepted_terms: :boolean,
    birthdate: :date
  }

  def changeset(user, params) do
    {user, @types}
    |> cast(params, Map.keys(@types))
    |> validate_required(Map.keys(@types))
    |> validate_length(:password, min: 10)
    |> validate_number(:age, greater_than: 0, less_than: 200)
    |> validate_acceptance(:accepted_terms)
  end

  def error_message(changeset, field) do
    with {msg, _reason} <- changeset.errors[field] do
      msg
    else
      _ -> ""
    end
  end
end
```



```elixir
defmodule CustomUser do
  # define the struct keys
  defstruct []

  # define the types
  @types %{}

  def changeset(user, params) do
    # Enter your solution
  end
end
```

### LiveView

Next, create the `CustomUserFormLive` Live View that lets the user enter their information and displays errors for invalid information upon form submission.

**Requirements**

* The `name` field should be a `TextField`.
* The `email` field should be a `TextField`.
* The `password` field should be a `SecureField`.
* The `age` field should be a `TextField` with a `.numberPad` keyboard or a `Slider`.
* The `accepted_terms` field should be a `Toggle`.
* The `birthdate` field should be a `DatePicker`.

### Example Solution

```elixir
defmodule Server.CustomUserFormLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView
  use FormStylesheet

  @impl true
  def mount(_params, _session, socket) do
    changeset = CustomUser.changeset(%CustomUser{}, %{})

    {:ok, assign(socket, :changeset, changeset)}
  end

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <LiveForm id="my-form" phx-change="validate" phx-submit="submit">
      <TextField name="name">name...</TextField>
      <.form_error changeset={@changeset} field={:name}/>

      <TextField name="email">email...</TextField>
      <.form_error changeset={@changeset} field={:email}/>

      <TextField name="age" class="keyboard-numberPad">age...</TextField>
      <.form_error changeset={@changeset} field={:age}/>

      <SecureField name="password">password...</SecureField>
      <.form_error changeset={@changeset} field={:password}/>

      <Toggle name="accepted_terms">Accept the Terms and Conditions:</Toggle>
      <.form_error changeset={@changeset} field={:accepted_terms}/>

      <DatePicker name="birthdate">Birthday:</DatePicker>
      <.form_error changeset={@changeset} field={:birthdate}/>
      <LiveSubmitButton>Submit</LiveSubmitButton>
    </LiveForm>
    """
  end

  @impl true
  def handle_event("validate", params, socket) do
    user_changeset =
      CustomUser.changeset(%CustomUser{}, params)
      |> Map.put(:action, socket.assigns.changeset.action)

    {:noreply, assign(socket, :changeset, user_changeset)}
  end

  def handle_event("submit", params, socket) do
    user_changeset =
      CustomUser.changeset(%CustomUser{}, params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, :changeset, user_changeset)}
  end

  # While not strictly required, the form_error component reduces code bloat.
  def form_error(assigns) do
    ~SWIFTUI"""
    <Text :if={@changeset.action} class="error">
      <%= CustomUser.error_message(@changeset, @field) %>
    </Text>
    """
  end
end
```



<!-- livebook:{"attrs":"eyJhY3Rpb24iOiI6aW5kZXgiLCJjb2RlIjoiZGVmbW9kdWxlIFNlcnZlci5DdXN0b21Vc2VyRm9ybUxpdmUgZG9cbiAgdXNlIFBob2VuaXguTGl2ZVZpZXdcbiAgdXNlIExpdmVWaWV3TmF0aXZlLkxpdmVWaWV3XG4gIHVzZSBGb3JtU3R5bGVzaGVldFxuXG4gIEBpbXBsIHRydWVcbiAgZGVmIG1vdW50KF9wYXJhbXMsIF9zZXNzaW9uLCBzb2NrZXQpIGRvXG4gICAgIyBSZW1lbWJlciB0byBwcm92aWRlIHRoZSBpbml0aWFsIGNoYW5nZXNldFxuICAgIHs6b2ssIHNvY2tldH1cbiAgZW5kXG5cbiAgQGltcGwgdHJ1ZVxuICBkZWYgcmVuZGVyKCV7Zm9ybWF0OiA6c3dpZnR1aX0gPSBhc3NpZ25zKSBkb1xuICAgIH5TV0lGVFVJXCJcIlwiXG4gICAgPCEtLSBMaXZlRm9ybSBnb2VzIGhlcmUgLS0+XG4gICAgXCJcIlwiXG4gIGVuZFxuXG4gIEBpbXBsIHRydWVcbiAgIyBXcml0ZSB5b3VyIGBcInZhbGlkYXRlXCJgIGV2ZW50IGhhbmRsZXJcbiAgZGVmIGhhbmRsZV9ldmVudChcInZhbGlkYXRlXCIsIHBhcmFtcywgc29ja2V0KSBkb1xuICAgIHs6bm9yZXBseSwgc29ja2V0fVxuICBlbmRcblxuICAjIFdyaXRlIHlvdXIgYFwic3VibWl0XCJgIGV2ZW50IGhhbmRsZXJcbiAgZGVmIGhhbmRsZV9ldmVudChcInN1Ym1pdFwiLCBwYXJhbXMsIHNvY2tldCkgZG9cbiAgICB7Om5vcmVwbHksIHNvY2tldH1cbiAgZW5kXG5lbmQiLCJwYXRoIjoiLyJ9","chunks":[[0,109],[111,620],[733,45],[780,63]],"kind":"Elixir.KinoLiveViewNative","livebook_object":"smart_cell"} -->

```elixir
require KinoLiveViewNative.Livebook
import KinoLiveViewNative.Livebook
import Kernel, except: [defmodule: 2]

defmodule Server.CustomUserFormLive do
  use Phoenix.LiveView
  use LiveViewNative.LiveView
  use FormStylesheet

  @impl true
  def mount(_params, _session, socket) do
    # Remember to provide the initial changeset
    {:ok, socket}
  end

  @impl true
  def render(%{format: :swiftui} = assigns) do
    ~SWIFTUI"""
    <!-- LiveForm goes here -->
    """
  end

  @impl true
  # Write your `"validate"` event handler
  def handle_event("validate", params, socket) do
    {:noreply, socket}
  end

  # Write your `"submit"` event handler
  def handle_event("submit", params, socket) do
    {:noreply, socket}
  end
end
|> KinoLiveViewNative.register("/", ":index")

import KinoLiveViewNative.Livebook, only: []
import Kernel
:ok
```
