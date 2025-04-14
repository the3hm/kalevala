defmodule Kalevala.Character.Conn.Render do
  @moduledoc false

  alias Kalevala.Character.Conn.{Text, Event, EventText, Private}

  @doc """
  Render text using the given view and template, pushing it to the conn output queue.
  """
  def render(conn, view, template, assigns) do
    assigns = merge_assigns(conn, assigns)
    data = view.render(template, assigns)
    push(conn, data, false)
  end

  @doc """
  Render a prompt with newline enabled.
  """
  def prompt(conn, view, template, assigns) do
    assigns = merge_assigns(conn, assigns)
    data = view.render(template, assigns)
    push(conn, data, true)
  end

  defp merge_assigns(conn, assigns) do
    conn.session
    |> Map.put(:character, Private.character(conn))
    |> Map.merge(conn.assigns)
    |> Map.merge(conn.flash)
    |> Map.merge(assigns)
  end

  defp push(conn, %Event{} = event, _newline),
    do: %{conn | output: conn.output ++ [event]}

  defp push(conn, %EventText{} = event, newline) do
    text = %Text{data: event.text, newline: newline}
    %{conn | output: conn.output ++ [%{event | text: text}]}
  end

  defp push(conn, text_data, newline) do
    text = %Text{data: text_data, newline: newline}
    %{conn | output: conn.output ++ [text]}
  end
end
