defmodule Mix.Tasks.Lvn.Setup do
  use Mix.Task

  import Mix.LiveViewNative.Context, only: [
    compile_string: 1
  ]

  @shortdoc "Prints LiveView Native Setup information"

  @moduledoc """
  @{shortdoc}

      $ mix lvn.setup
  """

  @impl true
  @doc false
  def run(_args) do
    if Mix.Project.umbrella?() do
      Mix.raise(
        "mix lvn must be invoked from within your *_web application root directory"
      )
    end

    detect_recommended_deps()
    |> case do
      [] -> :noop
      deps ->
        """
        <%= IO.ANSI.red() %><%= IO.ANSI.bright() %>The following dependencies are missing from your application:<%= IO.ANSI.reset() %>
        <%= for dep <- deps do %>
        * <%= dep %><% end %>

        While not necessary it is highly recommended that you install them before continuing.
        """
        |> compile_string()
        |> Mix.shell.info()
    end

    """
    To setup your application with LiveView Native run:

    > mix lvn.setup.config
    > mix lvn.setup.gen
    """
    |> Mix.shell().info()
  end

  defp detect_recommended_deps() do
    deps = [
      :live_view_native_stylesheet,
      :live_view_native_live_form
    ]

    installed_deps = Mix.Project.deps_tree() |> Map.keys()

    Enum.reject(deps, fn(dep) -> dep in installed_deps end)
  end
end
