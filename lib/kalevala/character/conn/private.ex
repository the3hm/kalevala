defmodule Kalevala.Character.Conn.Private do
  @moduledoc false

  alias Kalevala.World.Room

  defstruct [
    :event_router,
    :next_controller,
    :next_controller_flash,
    :request_id,
    :update_character,
    actions: [],
    channel_changes: [],
    halt?: false
  ]

  def generate_request_id do
    :crypto.strong_rand_bytes(16)
    |> Base.encode16(case: :lower)
  end

  def character(conn) do
    character = conn.private.update_character || conn.character

    if is_nil(character) do
      nil
    else
      meta = Kalevala.Meta.trim(character.meta)
      %{character | brain: :trimmed, inventory: :trimmed, meta: meta}
    end
  end

  def default_event_router(conn) do
    case character(conn) do
      nil -> nil
      character ->
        {:global, name} = Room.global_name(character.room_id)
        :global.whereis_name(name)
    end
  end
end
