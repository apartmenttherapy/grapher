defmodule Grapher.SchemaContext.StoreTest do
  use ExUnit.Case

  alias Grapher.SchemaContext
  alias Grapher.SchemaContext.Store

  doctest Store

  describe "Storing a Context" do
    test "add_schema/2 returns `:ok` if the context is registered" do
      assert :ok = register_context(:test)
    end

    test "add_schema/2 returns `:context_already_configured` if a context is already saved" do
      :ok = register_context(:conflict)

      assert :context_already_configured = Store.add_context(:conflict, context)
    end
  end

  describe "Updating a Context" do
    test "update_schema/2 returns `:ok` if the context is updated" do
      :ok = register_context(:update1)

      assert :ok = Store.update_context(:update1, context())
    end

    test "update_schema/2 returns `:no_such_context` if no context is registered" do
      assert :no_such_context = Store.update_context(:update2, context)
    end
  end

  describe "Fetching a Context" do
    test "get/1 returns the context if one is registered" do
      :ok = register_context(:fetch1)
      expected = context()

      assert ^expected = Store.get(:fetch1)
    end

    test "get/1 returns `:no_such_context` if one is not registered" do
      assert :no_such_context = Store.get(:fetch2)
    end
  end

  defp register_context(name) do
    Store.add_context(name, context())
  end

  defp context do
    %SchemaContext{url: "web.page.com", headers: []}
  end
end
