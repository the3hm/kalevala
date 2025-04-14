defmodule Kalevala.Brain.State do
  @moduledoc "A key/value store with optional expiration"

  alias Kalevala.Brain.StateValue

  @type t :: %__MODULE__{values: [StateValue.t()]}

  defstruct values: []

  def get(state, key, compare_time) do
    case Enum.find(state.values, &(&1.key == key)) do
      nil -> nil
      value -> if expired?(value, compare_time), do: nil, else: value.value
    end
  end

  def put(state, key, value, expires_at) do
    values = Enum.reject(state.values, &(&1.key == key))
    value = %StateValue{key: key, value: value, expires_at: expires_at}
    %{state | values: [value | values]}
  end

  def clean(state, compare_time \\ Time.utc_now()) do
    values = Enum.reject(state.values, &expired?(&1, compare_time))
    %{state | values: values}
  end

  defp expired?(%{expires_at: nil}, _), do: false
  defp expired?(%{expires_at: dt}, compare_time), do: DateTime.compare(dt, compare_time) != :gt
  defp expired?(nil, _), do: true
end
