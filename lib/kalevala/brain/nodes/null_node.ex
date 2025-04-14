defmodule Kalevala.Brain.Nodes.NullNode do
  @moduledoc "A no-op node"
  defstruct []

  defimpl Kalevala.Brain.Node do
    def run(_node, conn, _event), do: conn
  end
end
