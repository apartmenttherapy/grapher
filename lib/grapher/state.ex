defmodule Grapher.State do
  @moduledoc """
  A place for storing any data you may want to be available to all calls from a given process or for subsequent calls from the same process.

  For example at ApartmentTherapy we use this to maintain the initial `RequestID` when calling other services primarily for tracing in our logs.
  """

  use GenServer

  alias Grapher.Context

  @lifespan Application.get_env(:grapher, :state_lifetime)

  @spec start_link() :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @spec init(:ok) :: {:ok, nil}
  def init(:ok) do
    :ets.new(__MODULE__, [:set, :named_table, :protected])

    Process.send_after(__MODULE__, :purge, @lifespan)

    {:ok, nil}
  end

  @doc """
  Returns the state for the given PID if it has one

  ## Examples

      iex> State.update(%Context{headers: %{"request-id" => "42"}})
      iex> State.for(self())
      %Context{headers: %{"request-id" => "42"}}

  """
  @spec for(pid) :: Context.t | nil
  def for(pid) do
    case :ets.lookup(__MODULE__, pid) do
      [{^pid, context, _}] ->
        context
      [] ->
        nil
    end
  end

  @doc """
  Updates the state for the calling process, this completely replaces any current state struct.  The actual state struct should be fetched and updated directly if there is a need to modify it before saving.

  ## Parameters

    - `context`: The new context (`t:Grapher.Context.t/0`) that should be saved.

  ## Examples

      iex> State.update(%Context{})
      :ok

  """
  @spec update(Context.t) :: :ok
  def update(context) do
    GenServer.call(__MODULE__, {:update, context})
  end

  def handle_call({:update, context}, {sender, _}, _state) do
    :ets.insert(__MODULE__, {sender, context, :erlang.system_time(:seconds)})

    {:reply, :ok, nil}
  end

  def handle_info(:purge, _) do
    :ets.select_delete(__MODULE__, expiration_query())

    Process.send_after(__MODULE__, :purge, @lifespan)

    {:noreply, nil}
  end

  @spec expiration_query() :: :ets.match_spec
  def expiration_query do
    [
      {
        {:"$1", :"$2", :"$3"},
        [{:"<", :"$3", {:const, stale_after(@lifespan)}}],
        [true]
      }
    ]
  end

  @spec stale_after(String.t | integer) :: integer
  def stale_after(span) when is_integer(span) do
    :erlang.system_time(:seconds) - span
  end
  def stale_after(span) when is_binary(span) do
    :erlang.system_time(:seconds) - String.to_integer(span)
  end
end
