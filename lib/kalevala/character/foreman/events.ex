defmodule Kalevala.Character.Foreman.Events do
  @moduledoc false

  alias Kalevala.Character.Conn

  def send_options(conn, state) do
    state.callback_module.send_options(state, conn.options)
    conn
  end

  def send_output(conn, state) do
    state.callback_module.send_output(state, conn.output)
    conn
  end

  def send_events(conn) do
    {events, delayed_events} =
      Enum.split_with(conn.events, fn
        %Kalevala.Event{} -> true
        _ -> false
      end)

    Enum.each(delayed_events, fn delayed_event ->
      Process.send_after(self(), delayed_event, delayed_event.delay)
    end)

    case Conn.event_router(conn) do
      nil -> conn
      router ->
        Enum.each(events, fn event -> send(router, event) end)
        conn
    end
  end
end
