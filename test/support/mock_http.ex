defmodule Grapher.MockHTTP do
  def post(url, body, headers \\ [], options \\ [])
  def post(_url, "{\"variables\":{},\"query\": \"query { stuff { id } }\"}", _headers, _options) do
    {:ok, %{body: "{\"data\": {\"stuff\": {\"id\": 8}}}", status_code: 200}}
  end
  def post(_url, "{\"variables\":{},\"query\": \"graph_error\"}", _headers, _options) do
    {:ok, %{body: "{\"data\": null, \"errors\": [{\"path\": [\"store\"], \"message\": \"Invalid ID\"}]}", status_code: 200}}
  end
  def post(_url, "{\"variables\":{},\"query\": \"http_error\"}", _headers, _options) do
    {:ok, %{body: "Unauthorized", status_code: 403}}
  end
  def post(_url, "{\"variables\":{},\"query\":\"header_test\"}", headers, _options) do
    {:ok, %{body: "{\"data\": {\"headers\": #{jsonify(headers)}}}", status_code: 200}}
  end
  def post(_url, "{\"variables\":{\"user\":42},\"query\":\"state_args\"}", _headers, _options) do
    {:ok, %{body: "{\"data\": {\"vars\":{\"user\": 42}}}", status_code: 200}}
  end
  def post(_url, _query, _headers, _options) do
    {:ok, %{body: "{\"data\": {\"thing\": {\"name\": \"Mine\"}}}", status_code: 200}}
  end

  defp jsonify(data) do
    {:ok, data} =
      Enum.reduce(data, %{}, fn {header, value}, results ->
        Map.put(results, header, value)
      end) |> Poison.encode()

    data
  end
end
