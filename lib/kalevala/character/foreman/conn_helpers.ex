defmodule Kalevala.Character.Foreman.ConnHelpers do
  @moduledoc false

  alias Kalevala.Character.Conn
  alias Kalevala.Character.Foreman.{Channel, Events, Action}

  require Logger

  def new_conn(state) do
    %Conn{
      character: state.character,
      session: state.session,
      flash: state.flash,
      private: %Conn.Private{
        request_id: Conn.Private.generate_request_id()
      }
    }
  end

  def handle_conn(conn, state) do
    conn
    |> Channel.handle_channels(state)
    |> Events.send_options(state)
    |> Events.send_output(state)
    |> Events.send_events()

    session = Map.merge(state.session, conn.session)
    flash = Map.merge(state.flash, conn.flash)

    state =
      state
      |> Map.put(:session, session)
      |> Map.put(:flash, flash)
      |> Map.put(:action_queue, state.action_queue ++ conn.private.actions)

    case conn.private.halt? do
      true ->
        state.callback_module.terminate(state)
        {:noreply, state}

      false ->
        state
        |> Action.handle_actions()
        |> update_character(conn)
        |> update_controller(conn)
    end
  end

  defp update_character(state, conn) do
    case is_nil(conn.private.update_character) do
      true -> state
      false ->
        state.callback_module.track_presence(state, conn)
        %{state | character: conn.private.update_character}
    end
  end

  defp update_controller(state, conn) do
    case is_nil(conn.private.next_controller) do
      true -> {:noreply, state}
      false ->
        state =
          state
          |> Map.put(:controller, conn.private.next_controller)
          |> Map.put(:flash, conn.private.next_controller_flash)

        {:noreply, state, {:continue, :init_controller}}
    end
  end
end
