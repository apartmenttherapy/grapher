defmodule Grapher.Document.Store do
  @moduledoc """
  Manages Saving, Updating and Lookup of GraphQL Documents.  The Document Store uses an `:ets` table to store all documents.  From the perspective of the Store a Document is a combination of a `name` and a `Grapher.Document.t` struct.  The name is typically either an `atom` or a `String.t`.
  """

  use GenServer

  alias Grapher.Document

  @doc false
  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc false
  def init(:ok) do
    :ets.new(__MODULE__, [:set, :named_table, :protected])

    {:ok, nil}
  end

  @doc """
  Adds a new query document to the store under the given name.  If a document already exists with that name then `:document_exists` is returned and nothing changes in the store.

  ## Parameters

    - name: An atom that should be used to refer to the given document
    - document: The actual query document

  ## Examples

      iex> Store.add_document(:add_test, "query testQuery($id: ID!) { testQuery(id: $id) { id }}")
      :ok

      iex> Store.add_document(:add_test2, "query {}")
      iex> Store.add_document(:add_test2, "query {}")
      :document_exists

  """
  @spec add_document(Grapher.name, Document.t) :: :ok | :document_exists
  def add_document(name, document) do
    GenServer.call(__MODULE__, {:add, %{name: name, document: document}})
  end

  @doc """
  Updates an existing query document in the Store.  If the given name is not associated with a document this function returns `:no_such_document`

  ## Parameters

    - name: An atom refering to the document to be updated
    - document: The new document that should be stored under `name`

  ## Examples

      iex> Store.update_document(:missing, "query {}")
      :no_such_document

      iex> Store.add_document(:update, "query {}")
      iex> Store.update_document(:update, "query { query() {}}")
      :ok

  """
  @spec update_document(Grapher.name, Document.t) :: :ok | :no_such_document
  def update_document(name, document) do
    GenServer.call(__MODULE__, {:update, %{name: name, document: document}})
  end

  @doc """
  Retrieves a document from the Store by name, if there is no document with that name then `:no_such_document` will be returned.

  ## Parameters

    - name: the name of the query which should be returned

  ## Examples

      iex> Store.get(:missing)
      :no_such_document

      iex> Store.add_document(:get, "query {}")
      iex> Store.get(:get)
      "query {}"

  """
  @spec get(Grapher.name) :: Document.t | :no_such_document
  def get(name) do
    __MODULE__
    |> :ets.lookup(name)
    |> case do
         [] ->
           :no_such_document
         [{_key, document}] ->
           document
       end
  end

  def handle_call({:add, %{name: name, document: document}}, _from, state) do
    __MODULE__
    |> :ets.lookup(name)
    |> case do
         [] ->
           __MODULE__
           |> :ets.insert({name, document})

           {:reply, :ok, state}
         _doc ->
           {:reply, :document_exists, state}
       end
  end

  def handle_call({:update, %{name: name, document: document}}, _from, state) do
    __MODULE__
    |> :ets.lookup(name)
    |> case do
         [] ->
           {:reply, :no_such_document, state}
         _old_doc ->
           __MODULE__
           |> :ets.insert({name, document})

           {:reply, :ok, state}
       end
  end
end
