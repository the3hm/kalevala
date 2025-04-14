defmodule Kalevala.Character.Conn.Events do
  @moduledoc false

  alias Kalevala.Character.Conn.Private

  def event(conn, topic, data \\ %{}) do
    event = %Kalevala.Event{
      acting_character: Private.character(conn),
      from_pid: self(),
      topic: topic,
      data: data
    }

    %{conn | events: conn.events ++ [event]}
  end

  def delay_event(conn, delay, topic, data \\ %{}) do
    event = %Kalevala.Event.Delayed{
      delay: delay,
      acting_character: Private.character(conn),
      from_pid: self(),
      topic: topic,
      data: data
    }

    %{conn | events: conn.events ++ [event]}
  end
end
