defmodule Grapher.GraphQL.Request do
  @moduledoc """
  The Grapher Request struct is a collection of all `document` strings along with any `variables`.
  """

  alias Grapher.GraphQL.Formatter

  @type query_string :: String.t
  @type var_data :: nil | map()

  defstruct [query: "", variables: nil]
  @type t :: %__MODULE__{query: query_string,
                         variables: var_data()}

  @doc """
  Builds a GraphQL Request struct for a query, this is used for the request payload.

  ## Parameters

    - `document`: The GraphQL Query document as a `String.t`
    - `vars`: A map of variables for the query

  ## Examples

      iex> Request.new("query {}", %{var: "value"})
      %Request{query: "query {}", variables: %{var: "value"}}

  """
  @spec new(String.t, nil | map()) :: map()
  def new(document, vars \\ nil) do
    struct(__MODULE__, query: document, variables: vars)
  end

  @doc """
  Converts a `Grapher.GraphQL.Request.t` struct to `JSON` format.

  ## Parameters

    - `request`: The request struct to be converted

  ## Examples

      iex> Request.as_json(no_vars())
      "{\\"variables\\":null,\\"query\\":\\"query { stores { items } }\\"}"

      iex> Request.as_json(snake_atoms())
      "{\\"variables\\":{\\"userId\\":\\"bob\\"},\\"query\\":\\"query { stores { items } }\\"}"

      iex> Request.as_json(camel_atoms())
      "{\\"variables\\":{\\"userId\\":\\"bob\\"},\\"query\\":\\"query { stores { items } }\\"}"

      iex> Request.as_json(string_keys())
      "{\\"variables\\":{\\"userId\\":\\"bob\\"},\\"query\\":\\"query { stores { items } }\\"}"

      iex> Request.as_json(camel_strings())
      "{\\"variables\\":{\\"userId\\":\\"bob\\"},\\"query\\":\\"query { stores { items } }\\"}"

  """
  @spec as_json(%{query: String.t, variables: var_data}) :: String.t
  def as_json(%{query: query, variables: vars}) do
    {:ok, body} = Poison.encode(%{query: query, variables: convert(vars)})

    body
  end

  defp convert(data), do: Formatter.to_graph_ql(data)
end
