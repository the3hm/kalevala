defmodule Kalevala.Brain.Nodes.Sequence do
  @moduledoc "Runs all nodes in order"
  defstruct [:nodes]

  defimpl Kalevala.Brain.Node do
    alias Kalevala.Brain.Node

    def run(%{nodes: nodes}, conn, event) do
      Enum.reduce(nodes, conn, fn node, conn ->
        case Node.run(node, conn, event) do
          :error -> conn
          result -> result
        end
      end)
    end
  end
end
