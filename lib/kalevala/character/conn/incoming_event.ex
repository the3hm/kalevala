defmodule Kalevala.Character.Conn.IncomingEvent do
  @moduledoc """
  Incoming out-of-band event sent via GMCP or WebSocket.
  """

  @derive Jason.Encoder
  defstruct [:topic, :data]
end
