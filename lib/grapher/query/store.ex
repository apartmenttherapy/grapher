defmodule Grapher.Query.Store do
  @moduledoc """
  A smal GenServer for managing the saving and updating of query documents.
  """

  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    :ets.new(__MODULE__, [:set, :named_table, :protected])

    :ok
  end

  @doc """
  Adds a new query document to the store under the given name.  If a document already exists with that name then `:document_exists` is returned and nothing changes in the store.

  ## Parameters

    - name: An atom that should be used to refer to the given document
    - document: The actual query document

  ## Examples

      iex> QueryStore.add_document(:test, "query testQuery($id: ID!) { testQuery(id: $id) { id }}")
      :ok

      iex> QueryStore.add_document(:test, "query {}")
      :document_exists

  """
  @spec add_document(atom(), String.t) :: :ok | :document_exists
  def add_document(name, document) do
    GenServer.call(__MODULE__, {:add, %{name: name, document: documment}})
  end

  @doc """
  Updates an existing query document in the Store.  If the given name is not associated with a document this function returns `:no_such_document`

  ## Parameters

    - name: An atom refering to the document to be updated
    - document: The new document that should be stored under `name`

  ## Examples

      iex> QueryStore.update_document(:test, "query {}")
      :no_such_document

      iex> QueryStore.add_document(:existing, "query {}")
      iex> QueryStore.update_document(:existing, "query { query() {}}")
      :ok

  """
  @spec update_document(atom(), String.t) :: :ok | :no_such_document
  def update_document(name, document) do
    GenServer.call(__MODULE__, {:update, %{name: name, document: document}})
  end

  @doc """
  Retrieves a document from the Store by name, if there is no document with that name then `:no_such_document` will be returned.

  ## Parameters

    - name: the name of the query which should be returned

  ## Examples

      iex> QueryStore.get(:missing)
      :no_such_document

      iex> QueryStore.add_document(:test, "query {}")
      iex> QueryStore.get(:test)
      "query {}"

  """
  @spec get(atom) :: String.t | :no_such_document
  def get(name) do
    __MODULE__
    |> :ets.lookup(name)
    |> case do
         nil ->
           :no_such_document
         document ->
           document
       end
  end

  def handle_call({:add, %{name: name, document: document}}, _from, state) do
    __MODULE__
    |> :ets.lookup(name)
    |> case do
         nil ->
           __MODULE__
           |> :ets.insert({name, document})

           {:ok, :ok, state}
         _doc ->
           {:ok, :document_exists, state}
       end
  end

  def handle_call({:update, %{name: name, document: document}}, _from, state) do
    __MODULE__
    |> :ets.lookup(name)
    |> case do
         nil ->
           {:ok, :no_such_document, state}
         _old_doc ->
           __MODULE__
           |> :ets.insert({name, document})

           {:ok, :ok, state}
       end
  end
end
