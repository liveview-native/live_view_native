defmodule LiveViewNative.Template do
  @doc """
  Return all template engines for registered plugins
  """
  def engines() do
    Application.get_env(:live_view_native, :plugins)
    |> Enum.into(%{html: Phoenix.LiveView.Engine}, fn(plugin) ->
      plugin = struct(plugin)
      {plugin.format, plugin.template_engine}
    end)
  end
end
