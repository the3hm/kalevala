defmodule Kalevala.Character.Presence do
  @moduledoc """
  Track the presence of online characters and monitor their associated processes.
  """

  use GenServer

  alias Kalevala.Character
  alias Kalevala.Character.Presence.Implementation

  @callback online(Character.t()) :: :ok
  @callback offline(Character.t()) :: :ok

  defstruct [:callback_module, :ets_key]

  # ----------------------------------------------------------------------------
  # Usage Macros
  # ----------------------------------------------------------------------------

  defmacro __using__(_opts) do
    quote do
      @behaviour Kalevala.Character.Presence

      def characters, do: Kalevala.Character.Presence.characters(__MODULE__)
      def track(character), do: Kalevala.Character.Presence.track(__MODULE__, character)

      def child_spec(_opts),
        do: Kalevala.Character.Presence.child_spec(callback_module: __MODULE__, name: __MODULE__)

      @doc false
      def start_link(_opts),
        do: Kalevala.Character.Presence.start_link(callback_module: __MODULE__, name: __MODULE__)

      @impl true
      def online(_character), do: :ok

      @impl true
      def offline(_character), do: :ok

      defoverridable online: 1, offline: 1
    end
  end

  # ----------------------------------------------------------------------------
  # Public API
  # ----------------------------------------------------------------------------

  @spec track(pid(), Character.t()) :: :ok
  def track(pid, character) do
    GenServer.call(pid, {:track, character})
  end

  @spec characters(atom()) :: [Character.t()]
  def characters(ets_key) do
    ets_key
    |> Implementation.keys()
    |> Enum.map(&lookup(ets_key, &1))
    |> Enum.reject(&match?(:error, &1))
    |> Enum.map(fn {:ok, character} -> character end)
  end

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts) do
    opts = Enum.into(opts, %{})
    GenServer.start_link(__MODULE__, opts, name: opts[:name])
  end

  # ----------------------------------------------------------------------------
  # GenServer Callbacks
  # ----------------------------------------------------------------------------

  @impl true
  def init(config) do
    state = %__MODULE__{
      ets_key: config.name,
      callback_module: config.callback_module
    }

    :ets.new(state.ets_key, [:set, :protected, :named_table])
    {:ok, state}
  end

  @impl true
  def handle_call({:track, character}, _from, state) do
    state.callback_module.online(character)
    :ets.insert(state.ets_key, {character.pid, character})
    Process.monitor(character.pid)
    {:reply, :ok, state}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    with {:ok, character} <- lookup(state.ets_key, pid) do
      state.callback_module.offline(character)
    end

    :ets.delete(state.ets_key, pid)
    {:noreply, state}
  end

  # ----------------------------------------------------------------------------
  # Internal
  # ----------------------------------------------------------------------------

  @spec lookup(atom(), pid()) :: {:ok, Character.t()} | :error
  defp lookup(ets_key, pid) do
    case :ets.lookup(ets_key, pid) do
      [{^pid, character}] -> {:ok, character}
      _ -> :error
    end
  end

  # ----------------------------------------------------------------------------
  # Implementation Helper Module
  # ----------------------------------------------------------------------------

  defmodule Implementation do
    @moduledoc false

    @spec keys(atom()) :: [pid()]
    def keys(ets_key) do
      key = :ets.first(ets_key)
      keys(ets_key, key, [])
    end

    defp keys(_ets_key, :"$end_of_table", acc), do: Enum.reverse(acc)

    defp keys(ets_key, key, acc) do
      next_key = :ets.next(ets_key, key)
      keys(ets_key, next_key, [key | acc])
    end
  end
end
