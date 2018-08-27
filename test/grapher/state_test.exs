defmodule Grapher.StateTest do
  use ExUnit.Case

  alias Grapher.Context
  alias Grapher.State
  doctest State

  test "Contexts are persisted" do
    State.update(%Context{})

    assert [{_, %Context{}, _}] = :ets.lookup(State, self())
  end

  test "An existing context can be overwritten" do
    State.update(%Context{})
    State.update(%Context{headers: %{"request-id" => "4"}})

    assert [{_, %Context{headers: %{"request-id" => "4"}}, _}] = :ets.lookup(State, self())
  end

  test "Contexts are purged after the configured interval" do
    State.update(%Context{})

    Process.sleep(sleep_interval())

    assert [] = :ets.lookup(State, self())
  end

  defp sleep_interval do
    Application.get_env(:grapher, :state_lifetime) * 2000
  end
end
