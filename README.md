# LiveViewNative

## Installation

To install LiveView Native, add it to your list of dependencies in `mix.exs`.

```elixir
def deps do
  [{:live_view_native, "~> 0.1.0"}]
end
```

## Usage

```elixir
def MyAppWeb.HelloLive do
  use ScratchboardWeb, :live_view
  use LiveViewNative.LiveView

  def render(assigns) do
    render_native(assigns)
  end
end
```

## Learn more

  * Official website: https://native.live
  * Guides: https://hexdocs.pm/live_view_native/overview.html
  * Docs: https://hexdocs.pm/live_view_native
  * Source: https://github.com/liveviewnative/live_view_native
