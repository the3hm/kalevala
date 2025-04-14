defmodule Kalevala.Brain.Nodes.FirstSelector do
  @moduledoc "Runs each node until one succeeds"
  defstruct [:nodes]

  defimpl Kalevala.Brain.Node do
    alias Kalevala.Brain.Node

    def run(%{nodes: nodes}, conn, event) do
      Enum.find_value(nodes, fn node ->
        case Node.run(node, conn, event) do
          :error -> false
          result -> result
        end
      end) || conn
    end
  end
end
