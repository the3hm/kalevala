defmodule Kalevala.Character.Conn.Text do
  @moduledoc """
  Struct for printable text in the output queue.

  Used to determine newline behavior and telnet formatting.
  """

  defstruct [:data, newline: false, go_ahead: false]
end
