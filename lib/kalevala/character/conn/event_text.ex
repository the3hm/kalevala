defmodule Kalevala.Character.Conn.EventText do
  @moduledoc """
  Event with additional text output, allowing separation of telnet and web rendering.
  """

  @derive Jason.Encoder
  defstruct [:topic, :data, :text]
end
