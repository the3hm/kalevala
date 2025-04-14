defmodule Kalevala.Brain.Conditions.StateMatch do
  @moduledoc \"\"\"
  Match values from character's brain state against the given condition.
  \"\"\"

  @behaviour Kalevala.Brain.Condition

  alias Kalevala.Brain
  alias Kalevala.Brain.Variable
  alias Kalevala.Character.Conn
  alias Kalevala.Event

  @impl true
  def match?(%Event{} = event, conn, %{match: match_type} = data) do
    character = Conn.character(conn)
    event_data = Map.merge(Map.from_struct(character), event.data)

    case Variable.replace(data, event_data) do
      {:ok, resolved_data} ->
        brain_value = Brain.get(character.brain, resolved_data.key)

        case match_type do
          "equality" -> brain_value == resolved_data.value
          "inequality" -> brain_value != resolved_data.value
          "nil" -> is_nil(brain_value)
          _ -> false
        end

      :error ->
        false
    end
  end
end
