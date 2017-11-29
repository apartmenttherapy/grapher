defmodule Grapher.Document do
  @moduledoc """
  Definition for a GraphQL Document, a document can represent one of two "actions", it is either a Query or a Mutation.

  As far as Grapher is concerned a Document is really two pieces of data:

    1. The raw Document
    2. A Reference to something that knows how to prepare it for transport

  A quick note on the structure of your raw documents.  Grapher does not care if you prefer to write several focused/smaller documents or fewer larger/generic documents.

  If you are only using a few different arguments in your requests it might make more sense to write more focused documents:

  ```
  query {
    config(app: "CMS") {
      id
      hooks {
        url
      }
    }
  }
  ```

  A Document like the above could easily be tucked away behind a nice friendly name and no one has to worry about passing arguments.

  If you are needing to be more dynamic in your requests it might make more sense to write more generic documents and specify your values when you call `Grapher.Executor.run/3`.

  ```
  query user($userId: ID!, $email: String, $name: String) {
    user(userId: $userId, email: $email, name: $name) {
      userId
      email
      name
      picture
      urls
    }
  }
  ```
  """

  alias __MODULE__
  alias Grapher.GraphQL.Request

  @type doc_type :: :query | :mutation
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
      %Document{document: "query { thing { id } }", transport_formatter: &Grapher.GraphQL.Request.query/2}

      iex> Document.new("mutation thing($id: ID, $name: String){ thing(id: $id, name: $name) { name } }", :mutation)
      %Document{document: "mutation thing($id: ID, $name: String){ thing(id: $id, name: $name) { name } }", transport_formatter: &Grapher.GraphQL.Request.mutation/2}


  """
  @spec new(String.t, doc_type()) :: __MODULE__.t
  def new(document, :query) do
    struct(__MODULE__, document: document, transport_formatter: &Request.query/2)
  end
  def new(document, :mutation) do
    struct(__MODULE__, document: document, transport_formatter: &Request.mutation/2)
  end
end
