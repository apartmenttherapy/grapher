defmodule Grapher.GraphQL.ResponseTest do
  use ExUnit.Case

  alias Grapher.GraphQL.Response

  doctest Response

  @data "\"data\": {\"store\": {\"owner\": \"Bob\", \"id\": 3383}}"
  @error "\"errors\": {\"email_address\": \"Missing\"}"

  describe "HTTP Success" do
    test "correctly processes the data attribute" do
      expected_data = %{store: %{owner: "Bob", id: 3383}}

      assert %{data: ^expected_data} = Response.build(%{body: "{#{@data}}", status_code: 200})
    end

    test "correctly processes the errors attribute" do
      expected_error = %{email_address: "Missing"}

      assert %{errors: ^expected_error} = Response.build(%{body: "{#{@error}}", status_code: 200})
    end

    test "correctly processes both data and errors" do
      expected_error = %{email_address: "Missing"}
      expected_data = %{store: %{owner: "Bob", id: 3383}}

      assert %{data: ^expected_data, errors: ^expected_error} = Response.build(%{body: "{#{@data},#{@error}}", status_code: 200})
    end
  end

  describe "HTTP Failure" do
    test "returns the status code" do
      assert %{status_code: 401} = Response.build(%{body: "Fuck Off!", status_code: 401})
    end

    test "returns the error message from the body" do
      assert %{transport_error: "Unauthorized"} = Response.build(%{status_code: 401, body: "Unauthorized"})
    end
  end
end
