defmodule Grapher.MockHTTP do
  def post(url, body, headers \\ [], options \\ [])
  def post(_url, "{\"query\": \"query { stuff { id } }\"}", _headers, _options) do
    {:ok, %{body: "{\"data\": {\"stuff\": {\"id\": 8}}}", status_code: 200}}
  end
  def post(_url, "{\"query\": \"graph_error\"}", _headers, _options) do
    {:ok, %{body: "{\"data\": null, \"errors\": [{\"path\": [\"store\"], \"message\": \"Invalid ID\"}]}", status_code: 200}}
  end
  def post(_url, "{\"query\": \"http_error\"}", _headers, _options) do
    {:ok, %{body: "Unauthorized", status_code: 403}}
  end
  def post(_url, query, _headers, _options) do
    {:ok, %{body: "{\"data\": {\"thing\": {\"name\": \"Mine\"}}}", status_code: 200}}
  end
end
