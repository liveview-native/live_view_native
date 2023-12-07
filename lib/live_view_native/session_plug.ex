defmodule LiveViewNative.SessionPlug do
  def init(default), do: default

  def call(
        %Plug.Conn{
          params: %{"_lvn" => %{"format" => lvn_platform}},
          private: %{
            :phoenix_format => "html",
            :phoenix_root_layout => %{"html" => {root_layout_mod, root_layout_func}}
          }
        } = conn,
        _default
      ) do
    root_layout_func = String.to_existing_atom("#{root_layout_func}_#{lvn_platform}")
    root_layout = {root_layout_mod, root_layout_func}

    conn
    |> Phoenix.Controller.put_format(lvn_platform)
    |> Phoenix.Controller.put_root_layout(html: root_layout)
  end

  def call(conn, _default), do: conn
end
