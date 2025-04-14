defmodule Kalevala.Character.Foreman.Action do
  @moduledoc false

  require Logger

  def handle_actions(%{processing_action: nil, action_queue: [action | rest]} = state) do
    Logger.info(
      "Delaying #{inspect(action.type)} for #{action.delay}ms with #{inspect(action.params)}",
      request_id: action.request_id
    )

    Process.send_after(self(), {:process_action, action}, action.delay)

    state
    |> Map.put(:processing_action, action)
    |> Map.put(:action_queue, rest)
  end

  def handle_actions(state), do: state
end
