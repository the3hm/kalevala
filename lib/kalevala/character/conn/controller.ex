defmodule Kalevala.Character.Conn.Controller do
  @moduledoc false

  def put_controller(conn, controller, flash \\ %{}) do
    put_private(conn, :next_controller, controller)
    |> put_private(:next_controller_flash, flash)
  end

  def halt(conn), do: put_private(conn, :halt?, true)

  defp put_private(conn, key, value) do
    %{conn | private: Map.put(conn.private, key, value)}
  end
end
