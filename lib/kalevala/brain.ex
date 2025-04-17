defmodule Kalevala.Brain do
  @moduledoc """
  The top-level struct and runtime for processing a character's behavior tree.

  This module provides:
    - A wrapper around the root behavior tree node
    - Runtime state storage via `Kalevala.Brain.State`
    - Integration with the character connection (`Kalevala.Character.Conn`)
  """

  alias Kalevala.Brain.{Node, State}
  alias Kalevala.Character.Conn
  alias Kalevala.Event

  @type t :: %__MODULE__{
          root: Node.t(),
          state: State.t()
        }

  defstruct [:root, state: %State{}]

  @doc """
  Get a value from the brain's internal state store.
  """
  @spec get(t(), any(), Time.t()) :: any()
  def get(%__MODULE__{state: state}, key, compare_time \\ Time.utc_now()) do
    State.get(state, key, compare_time)
  end

  @doc """
  Put a key/value into the brain's state, optionally with expiration.
  """
  @spec put(t(), any(), any(), Time.t() | nil) :: t()
  def put(%__MODULE__{state: state} = brain, key, value, expires_at \\ nil) do
    updated_state = State.put(state, key, value, expires_at)
    %{brain | state: updated_state}
  end

  @doc """
  Run the behavior tree root node using the provided character connection and event.

  Also cleans expired state values from the character's brain state.
  """
  @spec run(t(), Conn.t(), Event.t()) :: Conn.t()
  def run(%__MODULE__{root: root}, conn, event) do
    root
    |> Node.run(conn, event)
    |> clean_state()
  end

  defp clean_state(conn) do
    character = Conn.character(conn)
    cleaned_state = State.clean(character.brain.state)
    updated_brain = %{character.brain | state: cleaned_state}
    Conn.put_character(conn, %{character | brain: updated_brain})
  end

  @doc """
  Runs a list of child nodes until one returns a modified connection.

  This is used by `ConditionalSelector`, `FirstSelector`, etc.
  """
  @spec run_until_success([Node.t()], Conn.t(), Event.t()) :: Conn.t()
  def run_until_success([], conn, _event), do: conn

  def run_until_success([node | rest], conn, event) do
    conn = Node.run(node, conn, event)

    # If the connection was modified (e.g., halted or changed), we assume it succeeded
    if conn != conn.original_conn do
      conn
    else
      run_until_success(rest, conn, event)
    end
  end
end
