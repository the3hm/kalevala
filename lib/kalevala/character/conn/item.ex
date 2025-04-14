defmodule Kalevala.Character.Conn.Item do
  @moduledoc false

  alias Kalevala.Character.Conn.Private

  def request_item_drop(conn, item_instance) do
    event = %Kalevala.Event{
      acting_character: Private.character(conn),
      from_pid: self(),
      topic: Kalevala.Event.ItemDrop.Request,
      data: %Kalevala.Event.ItemDrop.Request{
        item_instance: item_instance
      }
    }

    %{conn | events: conn.events ++ [event]}
  end

  def request_item_pickup(conn, item_name) do
    event = %Kalevala.Event{
      acting_character: Private.character(conn),
      from_pid: self(),
      topic: Kalevala.Event.ItemPickUp.Request,
      data: %Kalevala.Event.ItemPickUp.Request{
        item_name: item_name
      }
    }

    %{conn | events: conn.events ++ [event]}
  end
end
