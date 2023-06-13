defmodule LiveViewNative.Application do
  use Application

  def start(_type, _args) do
    Supervisor.start_link(supervisor_children(), strategy: :one_for_one)
  end

  def supervisor_children do
    if Mix.env() == :dev do
      [LiveViewNative.DevServer]
    else
      []
    end
  end
end
