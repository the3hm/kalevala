defmodule Kalevala.Brain.Nodes.StateSet do
  @moduledoc "Sets values on the character's brain"
  defstruct [:data]

  defimpl Kalevala.Brain.Node do
    alias Kalevala.Brain.{Variable, State}
    alias Kalevala.Character.Conn

    def run(%{data: raw_data}, conn, event) do
      character = Conn.character(conn)
      event_data = Map.merge(Map.from_struct(character), event.data)

      case Variable.replace(raw_data, event_data) do
        {:ok, data} ->
          new_brain = State.put(character.brain, data.key, data.value, expiration(data))
          Conn.put_character(conn, %{character | brain: new_brain})

        :error -> conn
      end
    end

    defp expiration(%{ttl: ttl}) when is_integer(ttl), do: Time.add(Time.utc_now(), ttl, :second)
    defp expiration(_), do: nil
  end
end
