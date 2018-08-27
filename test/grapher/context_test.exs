defmodule Grapher.ContextTest do
  use ExUnit.Case

  alias Grapher.Context
  doctest Context

  test "new/1 ignores unknown parameters" do
    assert %Context{} == Context.new(bacon: %{taste: "great", smell: "amazing"})
  end

  test "update/2 ignores unknown parameters" do
    assert %Context{} == Context.update(%Context{}, bacon: %{taste: "great", smell: "amazing"})
  end

  def existing do
    %Context{headers: ["request-id": "33"]}
  end
end
