defmodule Kalevala.Brain.Conditions.MessageMatch do
  @moduledoc \"\"\"
  Condition that matches message topic and runs a regex on the message text.
  \"\"\"

  @behaviour Kalevala.Brain.Condition

  alias Kalevala.Event
  alias Kalevala.Event.Message
  alias Kalevala.Character.Conn

  @impl true
  def match?(%Event{topic: %Message{}, data: %{text: text}} = event, conn, data) do
    data.interested?.(event) and
      self_check(event, conn, data) and
      Regex.match?(data.text, text)
  end

  def match?(_, _, _), do: false

  defp self_check(%Event{acting_character: acting}, conn, %{self_trigger: self_trigger}) do
    acting.id == Conn.character(conn).id and self_trigger
  end

  defp self_check(_, _, _), do: true
end
