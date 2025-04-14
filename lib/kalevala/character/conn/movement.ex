defmodule Kalevala.Character.Conn.Movement do
  @moduledoc false

  alias Kalevala.Character.Conn.Private

  def request_movement(conn, exit_name) do
    character = Private.character(conn)

    event = %Kalevala.Event{
      acting_character: character,
      from_pid: self(),
      topic: Kalevala.Event.Movement.Request,
      data: %Kalevala.Event.Movement.Request{
        character: character,
        exit_name: exit_name
      }
    }

    %{conn | events: conn.events ++ [Kalevala.Event.set_start_time(event)]}
  end

  def move(conn, direction, room_id, view, template, assigns) do
    character = Private.character(conn)
    assigns = merge_assigns(conn, assigns)
    reason = view.render(template, assigns)

    event = %Kalevala.Event{
      acting_character: character,
      from_pid: self(),
      topic: Kalevala.Event.Movement,
      data: %Kalevala.Event.Movement{
        character: character,
        direction: direction,
        reason: reason,
        room_id: room_id
      }
    }

    %{conn | events: conn.events ++ [event]}
  end

  defp merge_assigns(conn, assigns) do
    conn.session
    |> Map.put(:character, Private.character(conn))
    |> Map.merge(conn.assigns)
    |> Map.merge(conn.flash)
    |> Map.merge(assigns)
  end
end
