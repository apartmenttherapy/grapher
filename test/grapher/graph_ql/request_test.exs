defmodule Grapher.GraphQL.RequestTest do
  use ExUnit.Case

  alias Grapher.GraphQL.Request

  doctest Request, except: [{:as_json, 1}]

  test "as_json/1 converts a request to a JSON string" do
    expected = "{\"variables\":null,\"query\":\"query { stores{ items } }\",\"mutation\":null}"
    request = %Request{query: "query { stores{ items } }"}

    assert ^expected = Request.as_json(request)
  end
end
