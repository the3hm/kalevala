defmodule Kalevala.Brain.Nodes.Condition do
  @moduledoc "Node that checks a condition"
  defstruct [:type, :data]

  defimpl Kalevala.Brain.Node do
    def run(%{type: mod, data: data}, conn, event) do
      if mod.match?(event, conn, data), do: conn, else: :error
    end
  end
end
