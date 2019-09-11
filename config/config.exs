# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :scrap_docs, ScrapDocs.Repo,
  database: "scrap_docs_repo",
  username: "user",
  password: "pass",
  hostname: "localhost"

config :scrap_docs, ecto_repos: [ScrapDocs.Repo]

# Configures the endpoint
config :scrap_docs, ScrapDocsWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "br1gFuNXBlufIyKleXi6OOlQHisbMH4M6sEhmBkbOxDWfi9uE9rRxXOf8bKcRYC6",
  render_errors: [view: ScrapDocsWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ScrapDocs.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "/bR23oQaV17P4zr1ODB2qO5u6rl5/jw5"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
