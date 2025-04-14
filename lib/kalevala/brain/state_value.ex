defmodule Kalevala.Brain.StateValue do
  @moduledoc false

  @type t :: %__MODULE__{
          key: any(),
          expires_at: DateTime.t() | nil,
          value: any()
        }

  defstruct [:key, :expires_at, :value]
end
