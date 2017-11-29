# Grapher

[![Coverage Status](https://coveralls.io/repos/github/apartmenttherapy/grapher/badge.svg?branch=master)](https://coveralls.io/github/apartmenttherapy/grapher?branch=master)

Grapher is a GraphQL Client for Elixir.  It allows you to manage multiple "schemas" as well as providing for a simple Document storage.

Grapher is probably better suited for use in an application that needs to consume one or more GraphQL APIs than it is for quick discovery/exploration of an API.  Although nothing prevents you from using it to run queries from an `iex` session.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `grapher` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:grapher, "~> 0.1.0"}
  ]
end
```

## Usage

There are three main steps to executing a Query or Mutation with Grapher:

1. Registering a Context for the requests
2. Registering one or more Documents to use in requests
3. Executing a Document against a Schema

### Context Registration

Grapher uses what it calls a `SchemaContext` to identify where a Schema lives and any headers that should be used in requests.  There is nothing preventing the definition of multiple contexts for the same schema, you just need to give each context a unique name.

```elixir
iex> context = SchemaContext.new("http://www.example.com/graphql", ["Authentication": "bearer 88"])
iex> Grapher.SchemaContext.Store.add_context(:example, context)
:ok
```

Once a Context has been registered it can be retireved and/or updated

```elixir
iex> Grapher.SchemaContext.Store.get(:example)
%SchemaContext{url: "http://www.example.com/graphql", headers: ["Authentication": "bearer 88"]}

iex> new_context = SchemaContext.new("http://axiom.atmedia.xyz/graphql")
iex> Grapher.SchemaContext.Store.update_context(:example, new_context)
:ok
```

### Document Registration

A Document in Grapher is nothing more than the literal query document and a function to be used to translate it to an acceptable payload.  Currently the only supported transport layer is HTTP.

```elixir
iex> doc = Document.new("query { allListings { id } }", :query)
%Document{document: "query { allListings { id } }", transport_formatter: &Request.query/2}
```

In order to use a document you currently need to put it into the store first.

```elixir
iex> Grapher.Document.Store.add_document(:listings, doc)
:ok
```

Once you have stored a query you can always update it

```elixir
iex> Grapher.Document.Store.update_document(:listings, doc)
:ok
```

### Document Execution

Once you have one or more contexts and one or more documents you can start executing documents in a given context.

```elixir
iex> Grapher.Executor.run(:listings, :example)
%Grapher.GraphQL.Response{data: %{allListings: [%{id: 8}, %{id: 9}]}, errors: :empty, status_code: 200, transport_error: :empty}
```

If your document allows for variables you can always add them when you run it

```elixir
iex> doc = Document.new("query user($userId: ID!){ user(userId: $userID) { name } }", :query)
iex> Grapher.Document.Store.add_document(:flexible, doc)
iex> Grapher.Executor.run(:flexible, :example, %{userId: "bob"})
%Grapher.GraphQL.Response{data: %{user: %{name: "Bob Jones"}}, errors: :empty, status_code: 200, transport_error: :empty}
```
