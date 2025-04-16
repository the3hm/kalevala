defmodule Kalevala.Character.View do
  @moduledoc """
  View helpers for rendering game output and working with IO data.

  Includes utilities to:
    - trim lines from EEx-generated output
    - join IO data lists
    - import Kalevala sigils (`~E`, `~i`) from `Macro`
  """

  defmacro __using__(_opts) do
    quote do
      import Kalevala.Character.View.Macro
      alias Kalevala.Character.View
    end
  end

  @doc """
  Join a list of IO data with a given separator.

  Similar to `Enum.join/2`, but returns IO data instead of a binary.
  """
  def join([], _separator), do: []
  def join([line], _separator), do: [line]

  def join([line | lines], separator) do
    [line, separator | join(lines, separator)]
  end

  @doc """
  Trims blank lines from IO data for cleaner rendering.

  Useful after rendering templates with EEx that produce excess lines.
  """
  def trim_lines([]), do: []

  def trim_lines(["\n", "", "\n" | segments]), do: ["\n" | trim_lines(segments)]
  def trim_lines(["\n", nil, "\n" | segments]), do: ["\n" | trim_lines(segments)]
  def trim_lines([segment | segments]), do: [segment | trim_lines(segments)]
end
