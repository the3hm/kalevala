defmodule Kalevala.Character.Conn.Telnet do
  @moduledoc false

  alias Kalevala.Character.Conn.Option

  @doc """
  Send a telnet option (e.g., GMCP enable/disable).
  """
  def send_option(conn, name, value) when is_boolean(value) do
    option = %Option{name: name, value: value}
    %{conn | options: conn.options ++ [option]}
  end
end
