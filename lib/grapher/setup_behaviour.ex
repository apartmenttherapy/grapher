defmodule Grapher.SetupBehaviour do
  @moduledoc """
  Defines the expected API for a Setup Module.

  A Setup Module is simply a convienient way to load pre-determined contexts and queries into Grapher at application start.  If you wish to use a Setup Module you need to do two things:

  1. Define a module which uses this Behaviour
  2. Add that module to your config `config :grapher, setup_module: <MySetupModule>`
  """

  @callback setup() :: :ok | {:error, term}
end
