defmodule Kalevala.Brain.Nodes.Action do
  @moduledoc "Triggers a character action"

  defstruct [:type, :data, delay: 0]

  defimpl Kalevala.Brain.Node do
    alias Kalevala.Brain.Variable
    alias Kalevala.Character.{Conn, Action}

    def run(%{data: raw_data, type: type, delay: delay}, conn, event) do
      character = Conn.character(conn, trim: true)
      event_data = Map.merge(Map.from_struct(character), event.data)

      case Variable.replace(raw_data, event_data) do
        {:ok, data} ->
          Conn.put_action(conn, %Action{type: type, params: Variable.stringify_keys(data), delay: delay})

        :error ->
          conn
      end
    end
  end
end
