defmodule Kalevala.Character.Conn.Assigns do
  @moduledoc false

  def assign(conn, key, value) do
    %{conn | assigns: Map.put(conn.assigns, key, value)}
  end

  def put_session(conn, key, value) do
    %{conn | session: Map.put(conn.session, key, value)}
  end

  def get_session(conn, key), do: Map.get(conn.session, key)

  def put_flash(conn, key, value) do
    %{conn | flash: Map.put(conn.flash, key, value)}
  end

  def get_flash(conn, key), do: Map.get(conn.flash, key)
end
