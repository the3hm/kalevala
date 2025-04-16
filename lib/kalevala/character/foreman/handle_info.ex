defmodule Kalevala.Character.Foreman.HandleInfo do
  @moduledoc false

  alias Kalevala.Character.Foreman.ConnHelpers
  alias Kalevala.Event

  require Logger

  def dispatch({:recv, :text, data}, state) do
    ConnHelpers.new_conn(state)
    |> state.controller.recv(data)
    |> ConnHelpers.handle_conn(state)
  end

  def dispatch({:recv, :event, event}, state) do
    ConnHelpers.new_conn(state)
    |> state.controller.recv_event(event)
    |> ConnHelpers.handle_conn(state)
  end

  def dispatch(%Event{} = event, state) do
    ConnHelpers.new_conn(state)
    |> state.controller.event(event)
    |> ConnHelpers.handle_conn(state)
  end

  def dispatch({:route, %Event{} = event}, state) do
    ConnHelpers.new_conn(state)
    |> Map.put(:events, [event])
    |> ConnHelpers.handle_conn(state)
  end

  def dispatch(%Event.Delayed{} = event, state) do
    event = Event.Delayed.to_event(event)

    ConnHelpers.new_conn(state)
    |> Map.put(:events, [event])
    |> ConnHelpers.handle_conn(state)
  end

  def dispatch(%Event.Display{} = event, state) do
    ConnHelpers.new_conn(state)
    |> state.controller.display(event)
    |> ConnHelpers.handle_conn(state)
  end

  def dispatch({:process_action, action}, state) do
    if state.processing_action == action do
      Logger.info(
        "Processing #{inspect(action.type)}, #{Enum.count(state.action_queue)} left in queue.",
        request_id: action.request_id
      )

      state = %{state | processing_action: nil}

      ConnHelpers.new_conn(state)
      |> action.type.run(action.params)
      |> ConnHelpers.handle_conn(state)
    else
      Logger.warning("Character tried processing an action that was not next", type: :foreman)
      {:noreply, state}
    end
  end

  def dispatch(:terminate, state) do
    state.callback_module.terminating(state)
    DynamicSupervisor.terminate_child(state.supervisor_name, self())
    {:noreply, state}
  end
end
