defmodule LiveViewNative.Template do
  def engines() do
    Application.get_env(:live_view_native, :plugins)
    |> Enum.into(%{html: Phoenix.LiveView.Engine}, fn(plugin) ->
      {plugin.format(), plugin.template_engine()}  
    end)
  end
end