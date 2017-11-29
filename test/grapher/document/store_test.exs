defmodule Grapher.Document.StoreTest do
  use ExUnit.Case

  alias Grapher.Document.Store

  doctest Store

  describe "Storing a Query" do
    test "add_document/2 returns `:ok` if the query is registered" do
      assert :ok = register_document(:add1)
    end

    test "add_document/2 returns `:document_exists` if the query is already registered" do
      :ok = register_document(:add2)

      assert :document_exists = register_document(:add2)
    end
  end

  describe "Updating a Query" do
    test "update_document/2 returns `:ok` if the query is updated" do
      :ok = register_document(:update1)

      assert :ok = Store.update_document(:update1, document())
    end

    test "update_document/2 returns `:no_such_document` if the queyr is not registered" do
      assert :no_such_document = Store.update_document(:update2, document())
    end
  end

  describe "Fetching a Query" do
    test "get/1 returns a query if the query is registered" do
      :ok = register_document(:fetch1)
      expected = document()

      assert ^expected = Store.get(:fetch1)
    end

    test "get/1 returns `:no_such_document` if the query is not registered" do
      assert :no_such_document = Store.get(:fetch2)
    end
  end

  defp register_document(name) do
    Store.add_document(name, document())
  end

  defp document do
    "query { things { id } }"
  end
end
