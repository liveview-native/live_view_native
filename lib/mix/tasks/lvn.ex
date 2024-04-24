
defmodule Mix.Tasks.Lvn do
  use Mix.Task

  @shortdoc "Prints LiveView Native help information"

  @moduledoc """
  Prints LiveView Native tasks and their information.

      $ mix lvn

  To print the LiveView Native version, pass `-v` or `--version`, for example:

      $ mix lvn --version
  """

  @version Mix.Project.config()[:version]

  @impl true
  @doc false
  def run([version]) when version in ~w(-v --version) do
    Mix.shell().info("LiveView Native v#{@version}")
  end

  def run(args) do
    case args do
      [] -> general()
      _ -> Mix.raise "Invalid arguments, expected: mix phx"
    end
  end

  defp general() do
    Application.ensure_all_started(:live_view_native)
    Mix.shell().info "LiveViewNative v#{Application.spec(:live_view_native, :vsn)}"
    Mix.shell().info "Build with Phoenix for anything with a screen."
    Mix.shell().info "\n## Options\n"
    Mix.shell().info "-v, --version        # Prints LiveView Native version\n"
    Mix.Tasks.Help.run(["--search", "lvn."])
  end
end
