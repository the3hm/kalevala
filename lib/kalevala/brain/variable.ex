defmodule Kalevala.Brain.Variable do
  @moduledoc """
  Replaces `${variable}` placeholders in a nested map using values from event data.

  Supports:
    - Dot notation for nested keys (e.g., `${character.name}`)
    - Full substitution of strings containing `${...}` fragments
    - Graceful failure if a value is not found
  """

  require Logger

  defstruct [:path, :original, :reference, :value]

  @type t :: %__MODULE__{
          path: [atom()],
          original: String.t(),
          reference: String.t(),
          value: String.t() | nil
        }

  @type data_map :: map()
  @type event_data :: map()

  @doc """
  Replace all variables in the given data using the event_data map.

  Returns `{:ok, updated_data}` or `:error` if any variables could not be resolved.
  """
  @spec replace(data_map(), event_data()) :: {:ok, data_map()} | :error
  def replace(data, event_data) do
    data
    |> detect_variables()
    |> dereference_variables(event_data)
    |> replace_variables(data)
  end

  @doc """
  Detect all `${...}` variables in the data map.
  Returns a list of %Variable{} structs.
  """
  @spec detect_variables(data_map(), [atom()]) :: [t()]
  def detect_variables(data, path \\ []) do
    data
    |> Enum.flat_map(fn {key, value} -> find_variables({key, value}, path) || [] end)
  end

  defp find_variables({key, value}, path) when is_binary(value) do
    variables(value, path ++ [key])
  end

  defp find_variables({key, value}, path) when is_map(value) do
    detect_variables(value, path ++ [key])
  end

  defp find_variables(_, _), do: nil

  @doc """
  Extract variable references from a string like "${character.name}".
  """
  @spec variables(String.t(), [atom()]) :: [t()]
  def variables(value, path) do
    Regex.scan(~r/\$\{([\w\.]+)\}/, value)
    |> Enum.map(fn [original, reference] ->
      %__MODULE__{path: path, original: original, reference: reference}
    end)
  end

  @doc """
  Resolve each variable's reference to a value using event_data.
  """
  @spec dereference_variables([t()], event_data()) :: [t()]
  def dereference_variables(vars, event_data) do
    Enum.map(vars, fn var ->
      ref_path = String.split(var.reference, ".")
      value = dereference(event_data, ref_path)
      %{var | value: value}
    end)
  end

  @doc """
  Replace all detected and dereferenced variables into the original data map.
  """
  @spec replace_variables([t()], data_map()) :: {:ok, data_map()} | :error
  def replace_variables(variables, data) do
    if Enum.any?(variables, &(&1.value == :error)) do
      :error
    else
      {:ok, Enum.reduce(variables, data, &replace_variable/2)}
    end
  end

  defp replace_variable(var, data) do
    current = get_in(data, var.path)
    replaced = String.replace(current, var.original, to_string(var.value))
    put_in(data, var.path, replaced)
  end

  @doc """
  Navigate a map using a string-based variable path.
  e.g., ["character", "name"] => event_data["character"]["name"]
  Returns `:error` if any key is missing.
  """
  @spec dereference(map(), [String.t()]) :: any() | :error
  def dereference(data, path) do
    Enum.reduce_while(path, data, fn key, acc ->
      case maybe_destruct(acc) |> Map.get(key) do
        nil -> {:halt, :error}
        val -> {:cont, val}
      end
    end)
  end

  defp maybe_destruct(%{__struct__: _} = struct), do: Map.from_struct(struct)
  defp maybe_destruct(data), do: data

  @doc """
  Recursively convert all keys in a map or list to strings.
  Useful for output serialization.
  """
  @spec stringify_keys(any()) :: any()
  def stringify_keys(nil), do: nil
  def stringify_keys(value) when is_binary(value), do: value
  def stringify_keys([head | rest]), do: [stringify_keys(head) | stringify_keys(rest)]

  def stringify_keys(map) when is_map(map) do
    Enum.into(map, %{}, fn {k, v} ->
      {to_string(k), stringify_keys(v)}
    end)
  end

  def stringify_keys(value), do: value
end
