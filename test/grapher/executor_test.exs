defmodule Grapher.ExecutorTest do
  use ExUnit.Case

  alias Grapher.Document
  alias Grapher.Document.Store, as: DocumentStore
  alias Grapher.Executor
  alias Grapher.GraphQL.{Response, Request}
  alias Grapher.SchemaContext
  alias Grapher.SchemaContext.Store, as: SchemaStore

  describe "Passthrough" do
    test "run/3 returns `:no_query` if there is no query with the given name" do
      :ok = register_context(:existing_schema)

      assert :no_query = Executor.run(:query, :existing_schema, %{})
    end

    test "run/3 returns `:no_schema` if there is no schema context with the given name" do
      assert :no_schema = Executor.run(:query, :schema, %{})
    end
  end

  describe "Query Success" do
    test "run/3 returns a Grapher.GraphQL.Response.t when the request succeeds" do
      :ok = register_context(:success1)
      :ok = register_query(:success1)

      assert %Response{} = Executor.run(:success1, :success1, %{})
    end
  end

  describe "HTTP Error" do
    test "run/3 returns a Grapher.GraphQL.Response.t when the HTTP request fails" do
      :ok = register_context(:error1)
      :ok = register_query(:error1, %Document{document: "http_error"})

      assert %Response{} = Executor.run(:error1, :error1, %{})
    end
  end

  defp register_context(name) do
    SchemaStore.add_context(name, context())
  end

  defp register_query(name, doc \\ document()) do
    DocumentStore.add_document(name, doc)
  end

  defp context, do: %SchemaContext{url: "web.page.com", headers: []}
  defp document, do: Document.new("query { stuff { id } }", :query)
end
