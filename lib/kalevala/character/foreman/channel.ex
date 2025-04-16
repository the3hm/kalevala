defmodule Kalevala.Character.Foreman.Channel do
  @moduledoc """
  Helpers for processing channel changes from a character connection.

  Handles subscriptions, unsubscriptions, and publish events via the
  communication module. Logs actions and guards against invalid state.
  """

  require Logger

  @doc """
  Processes all pending channel changes from the connection.

  Logs and safely skips if `conn.private.channel_changes` is missing or invalid.
  """
  def handle_channels(%{private: %{channel_changes: channel_changes}} = conn, state)
      when is_list(channel_changes) do
    Enum.reduce(Enum.reverse(channel_changes), conn, fn channel_change, conn_acc ->
      handle_channel_change(channel_change, conn_acc, state)
    end)
  end

  def handle_channels(conn, _state) do
    message =
      case conn do
        %{character: %{id: id}} ->
          "[foreman.channel] No valid channel changes found for character #{id}, skipping."

        _ ->
          "[foreman.channel] No valid channel changes and character info is malformed. Conn: #{inspect(conn, pretty: true, limit: :infinity)}"
      end

    Logger.warning(message)
    conn
  end

  defp handle_channel_change({:subscribe, channel_name, options, error_fun}, conn, state) do
    case state.communication_module.subscribe(channel_name, options) do
      :ok ->
        Logger.debug("[foreman.channel] Subscribed #{conn.character.id} to #{channel_name}")
        conn

      {:error, reason} ->
        Logger.error(
          "[foreman.channel] Subscription failed for #{conn.character.id} to #{channel_name}: #{inspect(reason)}"
        )

        error_fun.(conn, {:error, reason})
    end
  end

  defp handle_channel_change({:unsubscribe, channel_name, options, error_fun}, conn, state) do
    case state.communication_module.unsubscribe(channel_name, options) do
      :ok ->
        Logger.debug("[foreman.channel] Unsubscribed #{conn.character.id} from #{channel_name}")
        conn

      {:error, reason} ->
        Logger.error(
          "[foreman.channel] Unsubscription failed for #{conn.character.id} from #{channel_name}: #{inspect(reason)}"
        )

        error_fun.(conn, {:error, reason})
    end
  end

  defp handle_channel_change({:publish, channel_name, event, options, error_fun}, conn, state) do
    case state.communication_module.publish(channel_name, event, options) do
      :ok ->
        Logger.debug("[foreman.channel] Published to #{channel_name} by #{conn.character.id}")
        conn

      {:error, reason} ->
        Logger.error(
          "[foreman.channel] Publish failed to #{channel_name} by #{conn.character.id}: #{inspect(reason)}"
        )

        error_fun.(conn, {:error, reason})
    end
  end
end
