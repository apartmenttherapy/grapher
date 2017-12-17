defmodule Grapher.GraphQL.RequestTest do
  use ExUnit.Case

  alias Grapher.GraphQL.Request

  doctest Request

  defp no_vars, do: %{query: "query { stores { items } }", variables: nil}
  defp snake_atoms, do: %{query: "query { stores { items } }", variables: %{user_id: "bob"}}
  defp camel_atoms, do: %{query: "query { stores { items } }", variables: %{userId: "bob"}}
  defp string_keys, do: %{query: "query { stores { items } }", variables: %{"userId": "bob"}}
end
