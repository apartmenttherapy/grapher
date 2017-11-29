defmodule Grapher.SchemaContext.Store do
  @moduledoc """
  Manages the storage of schema configurations
  """

  use GenServer

  alias Grapher.SchemaContext

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    :ets.new(__MODULE__, [:set, :named_table, :protected])

    {:ok, nil}
  end

  @doc """
  Saves a new schema configuration with the given name.  This function will return `:context_already_configured` if there is already a context registered with the given name.

  ## Parameters

    - name: An atom that will be used to reference this Schema Configuration
    - context: A `__MODULE__.t` struct defining the Schema Configuration

  ## Examples

      iex> Store.add_context(:auth1, %SchemaContext{url: "www.com.com", headers: []})
      :ok

      iex> Store.add_context(:auth2, %SchemaContext{url: "www.com.com"})
      iex> Store.add_context(:auth2, %SchemaContext{url: "www.net.com"})
      :context_already_configured

  """
  @spec add_context(Grapher.name, SchemaContext.t) :: :ok | :context_already_configured
  def add_context(name, context) do
    GenServer.call(__MODULE__, {:add, %{name: name, context: context}})
  end

  @doc """
  Updates the schema definition with the given name.  This function will return `:no_such_context` if there is no context registered with the given name.

  ## Parameters

    - name: An atom representing the name of the schema to be updated
    - context: A `__MODULE__.t` struct defining the Schem Configuration that should replace the current configuration

  ## Examples

      iex> Store.add_context(:update, %SchemaContext{url: "www.org.com"})
      iex> Store.update_context(:update, %SchemaContext{url: "www.com.com"})
      :ok

      iex> Store.update_context(:missing, %SchemaContext{url: "www.org.net"})
      :no_such_context

  """
  @spec update_context(Grapher.name, SchemaContext.t) :: :ok | :no_such_context
  def update_context(name, context) do
    GenServer.call(__MODULE__, {:update, %{name: name, context: context}})
  end

  @doc """
  Retrieves the context registered with the given name.  If there is no context registered this function returns `:no_such_context`

  ## Parameters

    - name: The registered name of the context to retrieve

  ## Examples

      iex> Store.get(:missing)
      :no_such_context

      iex> Store.add_context(:get, %SchemaContext{url: "com.com.com"})
      iex> Store.get(:get)
      %SchemaContext{url: "com.com.com", headers: []}

  """
  @spec get(Grapher.name) :: SchemaContext.t | :no_such_context
  def get(name) do
    __MODULE__
    |> :ets.lookup(name)
    |> case do
         [] ->
           :no_such_context
         [{_key, context}] ->
           context
       end
  end

  def handle_call({:add, %{name: name, context: context}}, _from, state) do
    __MODULE__
    |> :ets.lookup(name)
    |> case do
         [] ->
           :ets.insert(__MODULE__, {name, context})

           {:reply, :ok, state}
         _doc ->
           {:reply, :context_already_configured, state}
       end
  end

  def handle_call({:update, %{name: name, context: context}}, _from, state) do
    __MODULE__
    |> :ets.lookup(name)
    |> case do
         [] ->
           {:reply, :no_such_context, state}
         _old_doc ->
           :ets.insert(__MODULE__, {name, context})
           {:reply, :ok, state}
       end
  end
end
