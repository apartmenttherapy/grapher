defmodule Grapher.ExecutorTest do
  use ExUnit.Case

  alias Grapher.{Context, Document, Executor, SchemaContext, State}
  alias Grapher.Document.Store, as: DocumentStore
  alias Grapher.GraphQL.Response
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

  test "run/3 merges headers from the state if it is set" do
    :ok = register_context(:header_test)
    :ok = register_query(:header_test, %Document{document: "header_test"})

    State.update(%Context{headers: ["request-id": "42"]})
    headers = Executor.run(:header_test, :header_test, %{}).data().headers()

    assert %{"request-id": "42"} = headers
  end

  test "run/3 merges in args from the state into the request if set" do
    :ok = register_context(:state_args)
    :ok = register_query(:state_args, %Document{document: "state_args"})

    State.update(%Context{args: %{user: 42}})

    assert %{user: 42} = Executor.run(:state_args, :state_args, %{}).data().vars()
  end

  defp register_context(name) do
    SchemaStore.add_context(name, context())
  end

  defp register_query(name, doc \\ document()) do
    DocumentStore.add_document(name, doc)
  end

  defp context, do: %SchemaContext{url: "web.page.com", headers: []}
  defp document, do: Document.new("query { stuff { id } }")
end
