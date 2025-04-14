defmodule Kalevala.Character.Conn.Event do
  @moduledoc """
  Out-of-band event to be pushed to the client.
  """

  @derive Jason.Encoder
  defstruct [:topic, :data]
end
