defmodule Kalevala.Character.Conn.Action do
  @moduledoc false

  alias Kalevala.Meta
  alias Kalevala.Character.Conn.Private
  alias Kalevala.Character.Conn

  @doc """
  Add an action (must be a Kalevala.Character.Action struct).
  """
  def put_action(conn, %Kalevala.Character.Action{} = action) do
    action = %{action | request_id: conn.private.request_id}
    put_private(conn, :actions, conn.private.actions ++ [action])
  end

  @doc """
  Put a new meta key on the character.
  """
  def put_meta(conn, key, value) do
    character = Private.character(conn)
    meta = Meta.put(character.meta, key, value)
    put_character(conn, %{character | meta: meta})
  end

  @doc """
  Put a new character into the connection.
  """
  def put_character(conn, character),
    do: put_private(conn, :update_character, character)

  defp put_private(conn, key, value),
    do: %{conn | private: Map.put(conn.private, key, value)}
end
