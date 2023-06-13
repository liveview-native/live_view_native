defmodule LiveViewNative.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  use Application

  def start(_type, _args) do
    Supervisor.start_link(supervisor_children(), strategy: :one_for_one)
  end

  ###

  defp supervisor_children do
    if Mix.env() == :dev do
      [LiveViewNative.DevServer]
    else
      []
    end
  end
end
