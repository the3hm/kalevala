defmodule Kalevala.Character.Conn.Channels do
  @moduledoc false

  alias Kalevala.Character.Conn.Private

  def subscribe(conn, channel_name, options, error_fun) do
    options = Keyword.merge([character: Private.character(conn)], options)

    changes = [
      {:subscribe, channel_name, options, error_fun} | conn.private.channel_changes
    ]

    put_private(conn, :channel_changes, changes)
  end

  def unsubscribe(conn, channel_name, options, error_fun) do
    options = Keyword.merge([character: Private.character(conn)], options)

    changes = [
      {:unsubscribe, channel_name, options, error_fun} | conn.private.channel_changes
    ]

    put_private(conn, :channel_changes, changes)
  end

  def publish_message(conn, channel_name, text, options, error_fun) do
    character = Private.character(conn)

    event = %Kalevala.Event{
      acting_character: character,
      from_pid: self(),
      topic: Kalevala.Event.Message,
      data: %Kalevala.Event.Message{
        id: Kalevala.Event.Message.generate_id(),
        character: character,
        channel_name: channel_name,
        text: text,
        meta: Keyword.get(options, :meta, %{}),
        type: Keyword.get(options, :type, "speech")
      }
    }

    publish_channel_message(conn, channel_name, event, options, error_fun)
  end

  defp publish_channel_message(conn, channel_name, event, options, error_fun) do
    options = Keyword.merge([character: Private.character(conn)], options)

    changes = [
      {:publish, channel_name, event, options, error_fun} | conn.private.channel_changes
    ]

    put_private(conn, :channel_changes, changes)
  end

  defp put_private(conn, key, value) do
    %{conn | private: Map.put(conn.private, key, value)}
  end
end
