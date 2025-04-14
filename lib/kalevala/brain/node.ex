defprotocol Kalevala.Brain.Node do
  @moduledoc "Protocol to implement behavior tree node logic."

  @spec run(t(), Kalevala.Character.Conn.t(), Kalevala.Event.t()) ::
          Kalevala.Character.Conn.t() | :error
  def run(node, conn, event)
end
