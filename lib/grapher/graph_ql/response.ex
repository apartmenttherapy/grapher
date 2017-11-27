defmodule Grapher.GraphQL.Response do
  @moduledoc """
  Conveniences for structuring the response form the server.
  """

  alias HTTPoison.Response, as: HTTPResponse
  alias Poison.Parser

  @type data :: :empty | map()
  @type errors :: :empty | map()
  @type status_code :: :empty | integer()
  @type transport_error :: :empty | String.t

  defstruct [data: :empty, errors: :empty, status_code: :empty, transport_error: :empty]
  @type t :: %__MODULE__{data: data,
                         errors: errors,
                         status_code: status_code,
                         transport_error: transport_error}

  @doc """
  Creates a `__MODULE__.t` struct from an `HTTPoison.Response.t` struct.

  ## Parameters

    - response: An HTTPoison response

  """
  @spec build(HTTPResponse.t()) :: __MODULE__.t
  def build(%{body: body, status_code: status}) do
    body
    |> parse()
    |> struct(status_code: status)
  end

  defp parse(body) do
    body
    |> Parser.parse(keys: :atoms)
    |> case do
         {:ok, %{data: data, errors: errors}} ->
           struct(__MODULE__, data: data, errors: errors)
         {:ok, %{data: data}} ->
           struct(__MODULE__, data: data)
         {:ok, %{errors: errors}} ->
           struct(__MODULE__, errors: errors)
         {:error, _} ->
           struct(__MODULE__, transport_error: body)
       end
  end
end
