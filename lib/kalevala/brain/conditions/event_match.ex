defmodule Kalevala.Brain.Conditions.EventMatch do
  @moduledoc """
  Condition that matches event topic and data content.
  Optionally includes `self_trigger` control.
  """

  @behaviour Kalevala.Brain.Condition

  alias Kalevala.Character.Conn
  alias Kalevala.Event

  @impl true
  def match?(%Event{} = event, conn, data) do
    self_check(event, conn, data) and
      data.topic == event.topic and
      Enum.all?(data.data, fn {key, value} ->
        Map.get(event.data, key) == value
      end)
  end

  defp self_check(%Event{acting_character: acting} = _event, conn, %{self_trigger: self_trigger}) do
    Conn.character(conn).id == Map.get(acting, :id) and self_trigger
  end

  defp self_check(_, _, _), do: true
end
