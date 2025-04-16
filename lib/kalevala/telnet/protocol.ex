defmodule Kalevala.Telnet.Protocol do
  @moduledoc """
  Ranch protocol for handling Telnet connections.
  Responsible for spawning a Foreman process and managing socket I/O.
  """

  @behaviour :ranch_protocol

  require Logger

  alias Kalevala.Character.Conn.{Event, EventText, IncomingEvent, Text, Option}
  alias Kalevala.Character.Foreman
  alias Kalevala.Output
  alias Telnet.Options

  @doc """
  Required by `:ranch_protocol`. Starts a Telnet session handler.
  """
  @impl true
  def start_link(ref, socket, transport) do
    start_link(ref, socket, transport, [])
  end

  # Extended start_link with options; NOT part of behaviour
  def start_link(ref, _socket, transport, opts) do
    pid = :proc_lib.spawn_link(__MODULE__, :init, [ref, transport, opts])
    {:ok, pid}
  end

  @doc false
  def init(ref, transport, opts) do
    {:ok, socket} = :ranch.handshake(ref)
    :ok = transport.setopts(socket, active: true)
    send(self(), :init)

    protocol_opts = Enum.into(opts[:protocol] || [], %{})

    state = %{
      socket: socket,
      transport: transport,
      output_processors: protocol_opts.output_processors || [],
      buffer: <<>>,
      foreman_pid: nil,
      foreman_options: opts[:foreman],
      options: %{newline: false}
    }

    :gen_server.enter_loop(__MODULE__, [], state)
  end

  # ------------------------------------------------------------------------
  # Message Handling
  # ------------------------------------------------------------------------

  def handle_info(:init, state) do
    {:ok, pid} = Foreman.start_player(self(), state.foreman_options)
    {:noreply, %{state | foreman_pid: pid}, {:continue, :initial_iacs}}
  end

  def handle_info({:tcp, _socket, data}, state), do: process_data(state, data)
  def handle_info({:ssl, _socket, data}, state), do: process_data(state, data)

  def handle_info({:tcp_closed, _socket}, state), do: handle_info(:terminate, state)
  def handle_info({:ssl_closed, _socket}, state), do: handle_info(:terminate, state)

  def handle_info(:terminate, state) do
    Logger.info("Telnet session terminating")
    send(state.foreman_pid, :terminate)
    {:stop, :normal, state}
  end

  def handle_info({:send, data}, state) do
    state =
      Enum.reduce(List.wrap(data), state, fn item, acc ->
        push(acc, item)
      end)

    {:noreply, state}
  end

  def handle_continue(:initial_iacs, state) do
    # Send Telnet control sequences
    state.transport.send(state.socket, <<255, 251, 201>>) # WILL GMCP
    state.transport.send(state.socket, <<255, 253, 165>>) # DO OAuth
    state.transport.send(state.socket, <<255, 253, 39>>)  # DO NEW-ENVIRON
    {:noreply, state}
  end

  # ------------------------------------------------------------------------
  # Output Push Helpers
  # ------------------------------------------------------------------------

  defp push(state, %Event{} = event) do
    data =
      <<255, 250, 201>> <>
        event.topic <> " " <>
        Jason.encode!(event.data) <>
        <<255, 240>>

    state.transport.send(state.socket, data)
    state
  end

  defp push(state, %EventText{} = output) do
    event = %Event{topic: output.topic, data: output.data}

    state
    |> push(output.text)
    |> push(event)
  end

  defp push(state, %Text{} = output) do
    push_text(state, output.data)

    if output.go_ahead, do: state.transport.send(state.socket, <<255, 249>>)

    update_newline(state, output.newline)
  end

  defp push(state, %Option{name: :echo, value: true}) do
    state.transport.send(state.socket, <<255, 251, 1>>)
    state
  end

  defp push(state, %Option{name: :echo, value: false}) do
    state.transport.send(state.socket, <<255, 252, 1>>)
    state
  end

  defp push_text(state, text) do
    processed =
      Enum.reduce(state.output_processors, text, fn processor, acc ->
        Output.process(acc, processor)
      end)

    if state.options.newline do
      state.transport.send(state.socket, ["\n", processed])
    else
      state.transport.send(state.socket, processed)
    end
  end

  # ------------------------------------------------------------------------
  # Input Parsing
  # ------------------------------------------------------------------------

  defp process_data(state, data) do
    {options, string, buffer} = Options.parse(state.buffer <> data)
    state = %{state | buffer: buffer}

    Enum.each(options, fn option -> process_option(state, option) end)

    send(state.foreman_pid, {:recv, :text, string})
    {:noreply, update_newline(state, String.length(string) == 0)}
  end

  defp process_option(state, {:gmcp, topic, data}) do
    send(state.foreman_pid, {:recv, :event, %IncomingEvent{topic: topic, data: data}})
  end

  defp process_option(_state, _), do: :ok

  defp update_newline(state, status),
    do: %{state | options: %{state.options | newline: status}}
end
