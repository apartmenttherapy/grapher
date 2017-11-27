defmodule Grapher.Executor do
  @moduledoc """
  Functions for runing queries against a Schema
  """

  alias Grapher.Document
  alias Grapher.Document.Store, as: DocumentStore
  alias Grapher.GraphQL.{Response, Request}
  alias Grapher.SchemaContext
  alias Grapher.SchemaContext.Store, as: ContextStore
  alias HTTPoison.Error

  @doc """
  Run the specified query against the specified schema with the given arguments.  If the specified schema is not found then the function returns `:no_schema` if the specified query is not found then this function will return `:no_query`.

  ## Parameters

    - query: The name of the query to be run, if there is no query registered under this name then `:no_query` will be returned.
    - schema: The name of the schema to run the query against, if there is no schema registered under this name then `:no_schema` will be returned.
    - vars: A map of variables for the query.

  ## Examples

      iex> Executor.run(:query, :schema, %{arg: "value"})
      %{val: "response"}

  """
  @spec run(atom(), atom(), Request.var_data()) :: Response.t | Error.t | :no_schema | :no_query
  def run(query, schema \\ :default, vars \\ nil) do
    with %SchemaContext{} = context <- ContextStore.get(schema),
         %Document{} = document <- DocumentStore.get(query)
    do
      body =
        document.document()
        |> document.transport_formatter.(vars)
        |> Request.as_json()

      post(context, body)
    else
      :no_such_context ->
        :no_schema
      :no_such_document ->
        :no_query
    end
  end

  defp post(%{url: url, headers: headers}, body) do
    url
    |> transport.post(body, merge_headers(headers))
    |> case do
         {:ok, response} ->
           Response.build(response)
         {:error, error} ->
           error
       end
  end

  defp transport, do: Application.get_env(:grapher, :transport)

  defp merge_headers(headers) do
    Keyword.merge([accept: "application/json", "content-type": "application/json"], headers)
  end
end
