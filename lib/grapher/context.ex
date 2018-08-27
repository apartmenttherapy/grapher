defmodule Grapher.Context do
  @moduledoc """
  A Query Execution Context, this module handles managing any shared data that should be included across multiple Grapher queries.

  When executing a query Grapher expects to find any existing context in the `Grapher.State` server.  A Context remains valid for the duration of a process.
  """

  alias Grapher.GraphQL.Request

  defstruct headers: %{}, args: %{}
  @type t :: %__MODULE__{
               headers: header_data,
               args: Request.var_data
              }
  @type header_data :: %{optional(String.t) => String.t}
  @type data :: [
                       {:headers, header_data},
                       {:args, Request.var_data}
                     ]

  @doc """
  Creates a new empty context

  ## Examples

      iex> Context.new()
      %Context{}

  """
  @spec new() :: __MODULE__.t
  def new(), do: %__MODULE__{}

  @doc """
  Creates a new context

  ## Parameters

    - `data`: A `Keyword.t` of initialization data (`t:Grapher.Context.data/0`), this parameter is optional and if omitted you will simply get back and empty `t:Grapher.Context.t/0` struct.

  ## Examples

      iex> Context.new(headers: %{"request-id" => "33"})
      %Context{headers: %{"request-id" => "33"}}

      iex> Context.new(args: %{user_id: "33"})
      %Context{args: %{user_id: "33"}}

      iex> Context.new(headers: %{"request-id" => "33"}, args: %{user_id: "33"})
      %Context{headers: %{"request-id" => "33"}, args: %{user_id: "33"}}

  """
  @spec new(data) :: __MODULE__.t
  def new(inits) do
    Enum.reduce(inits, %__MODULE__{}, &add_arg/2)
  end

  defp add_arg({:headers, values}, record) do
    struct(record, headers: values)
  end
  defp add_arg({:args, values}, record) do
    struct(record, args: values)
  end
  defp add_arg(_, record), do: record


  @doc """
  Updates the given struct by merging the given parameters.

  ## Parameters

    - `updates`: A `Keyword.t` of data to be updated (`t:Grapher.Context.data/0`), the values of the given keys are merged *into* any existing data.

  ## Examples

      iex> Context.update(existing, headers: %{"request-ip" => "2.3.4.5"})
      %Context{headers: %{"request-id" => "33", "request-ip" => "2.3.4.5"}}

      iex> Context.update(existing, headers: %{"request-id" => "42"})
      %Context{headers: %{"request-id" => "42"}}

      iex> Context.update(%Context{}, headers: %{"request-ip" => "2.3.4.5"})
      %Context{headers: %{"request-ip" => "2.3.4.5"}}

  """
  @spec update(__MODULE__.t, data) :: __MODULE__.t
  def update(existing, updates) do
    Enum.reduce(updates, existing, &merge_arg/2)
  end

  defp merge_arg({:headers, values}, record) do
    updated = Map.merge(record.headers(), values)

    struct(record, headers: updated)
  end
  defp merge_arg({:args, values}, record) do
    updated = Map.merge(record.args(), values)

    struct(record, args: updated)
  end
  defp merge_arg(_, record), do: record
end
