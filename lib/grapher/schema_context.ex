defmodule Grapher.SchemaContext do
  @moduledoc """
  Defines a GraphQL Schema context
  """

  defstruct [url: "", headers: []]
  @type t :: %__MODULE__{url: String.t, headers: Keyword.t}

  @doc """
  Creates a new Schema Context for the given URL.  Currently the only configuration available beyond the url are HTTP headers.

  ## Parameters

    - url: The `URL` to which queries and mutations should be sent for this Schema
    - headers: Optional HTTP Headers to be included with each request, this will default to `[]` if nothing is given

  ## Examples

      iex> SchemaContext.new("http://www.example.xyz/api")
      %SchemaContext{url: "http://www.example.xyz/api", headers: []}

      iex> SchemaContext.new("http://www.example.com/api", ["Authentication": "My Token"])
      %SchemaContext{url: "http://www.example.com/api", headers: ["Authentication": "My Token"]}

  """
  @spec new(String.t, Keyword.t) :: __MODULE__.t
  def new(url, headers \\ []) do
    %__MODULE__{url: url, headers: headers}
  end
end
