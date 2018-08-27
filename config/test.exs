use Mix.Config

config :grapher,
  transport: Grapher.MockHTTP,
  state_lifetime: 3
