defmodule Kalevala.Brain.Condition do
  @moduledoc "Behaviour for custom condition checks"

  @callback match?(Kalevala.Event.t(), Kalevala.Character.Conn.t(), map()) :: boolean()
end
