defmodule Kalevala.Character.Foreman do
  @moduledoc """
  The Foreman is the session manager for a character.

  It receives messages from the protocol, wraps them in a `Conn`, and delegates to the appropriate controller.
  """

  use GenServer
  require Logger

  alias Kalevala.Character.Foreman.{ConnHelpers, HandleInfo, Events}

  @type t :: %__MODULE__{}

  defstruct [
    :callback_module,
    :character,
    :communication_module,
    :controller,
    :supervisor_name,
    processing_action: nil,
    action_queue: [],
    private: %{},
    session: %{},
    flash: %{}
  ]

  # ----------------------------------------------------------------------------
  # Startup
  # ----------------------------------------------------------------------------

  @doc """
  Start a new foreman for a connecting player.
  """
  def start_player(protocol_pid, options) do
    options =
      Keyword.merge(options,
        callback_module: Kalevala.Character.Foreman.Player,
        protocol: protocol_pid
      )

    DynamicSupervisor.start_child(options[:supervisor_name], {__MODULE__, options})
  end

  @doc """
  Start a new foreman for a non-player (NPC).
  """
  def start_non_player(options) do
    options =
      Keyword.merge(options,
        callback_module: Kalevala.Character.Foreman.NonPlayer
      )

    DynamicSupervisor.start_child(options[:supervisor_name], {__MODULE__, options})
  end

  @doc false
  def start_link(opts),
    do: GenServer.start_link(__MODULE__, opts, [])

  @impl true
  def init(opts) do
    opts = Enum.into(opts, %{})

    state = %__MODULE__{
      callback_module: opts.callback_module,
      communication_module: opts.communication_module,
      controller: opts.initial_controller,
      supervisor_name: opts.supervisor_name
    }

    state = opts.callback_module.init(state, opts)

    {:ok, state, {:continue, :init_controller}}
  end

  @impl true
  def handle_continue(:init_controller, state) do
    state
    |> ConnHelpers.new_conn()
    |> state.controller.init()
    |> ConnHelpers.handle_conn(state)
  end

  # ----------------------------------------------------------------------------
  # Message Routing
  # ----------------------------------------------------------------------------

  @impl true
  def handle_info(msg, state),
    do: HandleInfo.dispatch(msg, state)

  # ----------------------------------------------------------------------------
  # Public Helper API
  # ----------------------------------------------------------------------------

  @doc false
  def new_conn(state),
    do: ConnHelpers.new_conn(state)

  @doc false
  def send_events(conn),
    do: Events.send_events(conn)
end
