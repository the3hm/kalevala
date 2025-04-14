defmodule Kalevala.Brain.Nodes.ActionTest do
  use ExUnit.Case

  alias Kalevala.Brain.Nodes.Action
  alias Kalevala.Character.Conn

  defmodule MockConn do
    def character(conn, _opts \\ []), do: conn.character
    def put_action(conn, action), do: Map.put(conn, :action, action)
  end

  test "replaces variables and creates action" do
    node = %Action{
      type: "yell",
      delay: 300,
      data: %{
        text: "Greetings, ${character.name}"
      }
    }

    conn = %{
      character: %{name: "Zorax"},
      event: %{data: %{}}
    }

    conn = Action.run(node, conn, %{data: %{}})

    assert conn.action.type == "yell"
    assert conn.action.params["text"] == "Greetings, Zorax"
    assert conn.action.delay == 300
  end
end
