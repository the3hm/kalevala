defmodule Kalevala.Brain.Nodes.ConditionalSelector do
  @moduledoc """
  A brain node that runs child nodes based on matching conditions.

  It evaluates each child node in order until one of them succeeds.
  """

  defstruct [:nodes]

  defimpl Kalevala.Brain.Node do
    @doc """
    Runs each child node until one succeeds.
    """
    def run(%{nodes: nodes}, conn, event) do
      Kalevala.Brain.run_until_success(nodes, conn, event)
    end
  end
end
