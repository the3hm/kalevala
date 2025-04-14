defmodule Kalevala.Brain.Conditions.StateMatchTest do
  use ExUnit.Case

  alias Kalevala.Brain.Conditions.StateMatch
  alias Kalevala.Brain

  test "matches equality when value exists" do
    brain = Brain.put(%Brain{}, :mood, "happy")
    conn = %{character: %{brain: brain}}
    event = %{data: %{}}

    result = StateMatch.match?(event, conn, %{match: "equality", key: "mood", value: "happy"})
    assert result == true
  end

  test "fails when variable can't be resolved" do
    brain = %Brain{}
    conn = %{character: %{brain: brain}}
    event = %{data: %{}}

    result = StateMatch.match?(event, conn, %{match: "equality", key: "unknown", value: "happy"})
    assert result == false
  end
end
