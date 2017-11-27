defmodule Grapher do
  @moduledoc """
  Documentation for Grapher.
  """

  use Application

  alias __MODULE__
  alias Grapher.SchemaContext.Store, as: SchemaStore
  alias Grapher.Document.Store, as: DocumentStore

  def start(_, _) do
    import Supervisor.Spec

    children = [
      worker(SchemaStore, []),
      worker(DocumentStore, [])
    ]

    opts = [strategy: :one_for_one, name: Grapher]
    Supervisor.start_link(children, opts)
  end
end
