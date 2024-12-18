defmodule Mix.Tasks.Lvn.Setup do
  use Mix.Task

  import Mix.LiveViewNative, only: [
    detect_necessary_deps: 0
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

    detect_necessary_deps()

    """
    To setup your application with LiveView Native run:

    > mix lvn.setup.config
    > mix lvn.setup.gen
    """
    |> Mix.shell().info()
  end
end
