defmodule Kalevala.Brain.Nodes.RandomSelector do
  @moduledoc "Chooses one node at random"
  defstruct [:nodes]

  defimpl Kalevala.Brain.Node do
    alias Kalevala.Brain.Node

    def run(%{nodes: nodes}, conn, event) do
      node = Enum.random(nodes)
      Node.run(node, conn, event)
    end
  end
end
