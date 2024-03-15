import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :hangman_live, Hangman.LiveWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base:
    "cbh2SCWSanTPW52tB3yEwxgPdJuu+uyhgO9jpry3mT9Xhu4NJmK0/pCbTrFvlXns",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
