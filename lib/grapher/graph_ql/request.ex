defmodule Grapher.GraphQL.Request do
  @moduledoc """
  Defines a simple request struct for Grapher
  """

  @type mutation_string :: nil | String.t
  @type query_string :: nil | String.t
  @type var_data :: nil | map()

  defstruct [mutation: nil, query: nil, variables: nil]
  @type t :: %__MODULE__{mutation: mutation_string,
                         query: query_string,
                         variables: var_data()}

  @doc """
  Builds a GraphQL Request struct for a query, this is used for the request payload.

  ## Parameters

    - query: The GraphQL Query document as a `String.t`
    - vars: A map of variables for the query

  ## Examples

      iex> Request.query("query {}", %{var: "value"})
      %Request{mutation: nil, query: "query {}", variables: %{var: "value"}}

  """
  @spec query(String.t, nil | map()) :: map()
  def query(query, vars \\ nil) do
    struct(__MODULE__, query: query, variables: vars)
  end

  @doc """
  Builds a GraphQL Request struct for a mutation, this is used for the request payload.

  ## Parameters

    - mutation: The GraphQL Mutation document as a `String.t`
    - vars: A map of variables for the query

  ## Examples

      iex> Request.mutation("mutation { thing(name: $name) { id } }", %{name: "bob"})
      %Request{query: nil, mutation: "mutation { thing(name: $name) { id } }", variables: %{name: "bob"}}

  """
  @spec mutation(String.t, nil | map()) :: map()
  def mutation(mutation, vars \\ nil) do
    struct(__MODULE__, mutation: mutation, variables: vars)
  end

  @doc """
  Converts a `__MODULE__.t` record to `JSON` format.

  ## Parameters

    - request: The request struct to be converted

  ## Examples

      iex> request = %Request{query: "query { stores{ items } }", variables: nil}
      iex> Request.as_json(request)
      "{\"variables\":null,\"query\":\"query { stores{ items } }\",\"mutation\":null}"

  """
  @spec as_json(__MODULE__.t) :: String.t
  def as_json(request) do
    {:ok, body} = Poison.encode(request)

    body
  end
end
