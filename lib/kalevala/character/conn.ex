defmodule Kalevala.Character.Conn do
  @moduledoc """
  The public API for working with a character's connection state.

  This module provides struct definition and delegates functionality to submodules:
    - `Assigns`: session, flash, assign helpers
    - `Render`: rendering and text output
    - `Controller`: controller switching and halting
    - `Events`: general and delayed events
    - `Movement`: room transitions
    - `Item`: item pickup and drop
    - `Telnet`: telnet option pushing
    - `Channels`: publish/subscribe events
    - `Action`: action queueing and character/meta manipulation
  """

  @type t :: %__MODULE__{}

  alias Kalevala.Character.Conn.Private

  defstruct [
    :character,
    :params,
    assigns: %{},
    events: [],
    output: [],
    options: [],
    private: %Private{},
    session: %{},
    flash: %{}
  ]

  # ----------------------------------------------------------------------------
  # Character and router
  # ----------------------------------------------------------------------------

  @doc false
  def event_router(%{private: %{event_router: nil}} = conn),
    do: Private.default_event_router(conn)

  def event_router(%{private: %{event_router: router}}), do: router

  @doc """
  Get the current character (optionally trimmed).
  """
  def character(conn, opts \\ [])
  def character(conn, trim: true), do: Private.character(conn)
  def character(conn, _), do: conn.private.update_character || conn.character

  # ----------------------------------------------------------------------------
  # Delegated Modules
  # ----------------------------------------------------------------------------

  defdelegate assign(conn, key, value), to: Kalevala.Character.Conn.Assigns
  defdelegate put_session(conn, key, value), to: Kalevala.Character.Conn.Assigns
  defdelegate get_session(conn, key), to: Kalevala.Character.Conn.Assigns
  defdelegate put_flash(conn, key, value), to: Kalevala.Character.Conn.Assigns
  defdelegate get_flash(conn, key), to: Kalevala.Character.Conn.Assigns

  defdelegate render(conn, view, template, assigns \\ %{}),
    to: Kalevala.Character.Conn.Render

  defdelegate prompt(conn, view, template, assigns \\ %{}),
    to: Kalevala.Character.Conn.Render

  defdelegate put_controller(conn, controller, flash \\ %{}),
    to: Kalevala.Character.Conn.Controller

  defdelegate halt(conn), to: Kalevala.Character.Conn.Controller

  defdelegate event(conn, topic, data \\ %{}), to: Kalevala.Character.Conn.Events
  defdelegate delay_event(conn, delay, topic, data \\ %{}), to: Kalevala.Character.Conn.Events

  defdelegate request_movement(conn, exit_name), to: Kalevala.Character.Conn.Movement
  defdelegate move(conn, direction, room_id, view, template, assigns),
    to: Kalevala.Character.Conn.Movement

  defdelegate request_item_drop(conn, item_instance), to: Kalevala.Character.Conn.Item
  defdelegate request_item_pickup(conn, item_name), to: Kalevala.Character.Conn.Item

  defdelegate send_option(conn, name, value), to: Kalevala.Character.Conn.Telnet

  defdelegate publish_message(conn, channel_name, text, options, error_fun),
    to: Kalevala.Character.Conn.Channels

  defdelegate subscribe(conn, channel_name, options, error_fun),
    to: Kalevala.Character.Conn.Channels

  defdelegate unsubscribe(conn, channel_name, options, error_fun),
    to: Kalevala.Character.Conn.Channels

  defdelegate put_action(conn, action), to: Kalevala.Character.Conn.Action
  defdelegate put_meta(conn, key, value), to: Kalevala.Character.Conn.Action
  defdelegate put_character(conn, character), to: Kalevala.Character.Conn.Action
end
