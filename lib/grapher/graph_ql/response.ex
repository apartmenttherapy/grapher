defmodule Grapher.GraphQL.Response do
  @moduledoc """
  Conveniences for structuring the response form the server.
  """

  alias HTTPoison.Response, as: HTTPResponse
  alias Grapher.GraphQL.Formatter
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
  Creates a `Grapher.GraphQL.Response.t` struct from an `HTTPoison.Response.t` struct.

  ## Parameters

    - `response`: An HTTPoison response

  ## Examples

      iex> Response.build(mixed_response())
      %Response{data: %{store: %{id: 3383, owner: "Bob"}}, errors: %{email_address: "Missing"}, status_code: 200}

      iex> Response.build(error_response())
      %Response{data: :empty, errors: %{email_address: "Missing"}, status_code: 200}

      iex> Response.build(success_response())
      %Response{data: %{store: %{id: 3383, owner: "Bob"}}, errors: :empty, status_code: 200}

      iex> Response.build(transport_error())
      %Response{transport_error: "Not Authorized", status_code: 400}

  """
  @spec build(HTTPResponse.t()) :: __MODULE__.t
  def build(%{body: body, status_code: status}) do
    body
    |> parse()
    |> struct(status_code: status)
  end

  defp parse(body) do
    body
    |> Parser.parse()
    |> case do
         {:ok, %{"data" => data, "errors" => errors}} ->
           struct(__MODULE__, data: convert(data), errors: convert(errors))
         {:ok, %{"data" => data}} ->
           struct(__MODULE__, data: convert(data))
         {:ok, %{"errors" => errors}} ->
           struct(__MODULE__, errors: convert(errors))
         {:error, _} ->
           struct(__MODULE__, transport_error: body)
       end
  end

  defp convert(data), do: Formatter.to_elixir(data)
end
