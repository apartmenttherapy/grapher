defmodule Grapher.Document do
  @moduedoc """
  Definition for a GraphQL Document, a document can represent one of two "actions".  It is either a Query or a Mutation.  The `Document.t` struct provides a simple "container" for the actual document and a tag indicating which `type` it represents.
  """

  alias __MODULE__
  alias Grapher.GraphQL.Request

  @type query_type :: :query | :mutation
  @type transport_formatter :: (... -> Request.t)

  defstruct [document: "", transport_formatter: &Request.query/2]
  @type t :: %__MODULE__{document: String.t, transport_formatter: transport_formatter()}

  @doc """
  creates a new document struct from the given document string and type, if a type is not given the document defaults to a `query` type to prevent any unplesant surprises.

  ## Parameters

    - document: The full query document, it is recommended that variables not be included directly in the document.
    - type: The document type, can be one of `:query` or `:mutation`

  ## Examples

      iex> Document.new("query { thing { id } }", :query)
      %Document{document: "query { thing { id } }", type: :query}

  """
  @spec new(String.t, query_type()) :: __MODULE__.t
  def new(document, :query) do
    struct(__MODULE__, document: document, transport_formatter: &Request.query/2)
  end
  def new(document, :mutation) do
    struct(__MODULE__, document: document, transport_formatter: &Request.mutation/2)
  end
end
