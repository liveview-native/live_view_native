# Release Notes

## 0.4.0-rc.1

This release candidate represents a major refactor of our client networking layer in LVN Core.
It also changes how we encode stylesheets, from Elixir literals to JSON.

The other major change is that all LVN related function components now *must* have arity of 2.
For example, if you previously had function components in a render component such as:

```elixir
def clock(assigns) do
  ~LVN"""
  <Clock time={@time} />
  """
end
```

it must now be changed to:

```elixir
def clock(assigns, _interface) do
  ~LVN"""
  <Clock time={@time} />
  """
end
```

This aligns with the `render/2` in LVN render components but also it allows for granular conditionals within function components.

You will need to update the `CoreComponents` file for your client so that all function components respond to arity of 2. Compilation will
fail if there are any function components intended for LVN templates still using arity 1.

### Known issues

The SwiftUI client *will* fail to compile in Xcode 16.3 beta. The `SDKROOT` environment variable, which has been in Xcode for over 25 years,
was removed in that beta relase with no explanation as to why or what should be used instead. We are working to resolve this for the upcoming
release of Xcode.
