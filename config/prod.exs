use Mix.Config

config :slack_coder, SlackCoder.Endpoint,
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  http: [port: {:system, "PORT"}],
  url: [host: "slack-coder.nanoapp.io", port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json"

config :logger,
  # Do not print debug messages in production
  level: :info,
  # compile_time_purge_level: :info,
  truncate: :infinity

config :slack_coder, SlackCoder.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DATA_DB_USER"),
  password: System.get_env("DATA_DB_PASS"),
  hostname: System.get_env("DATA_DB_HOST"),
  database: "gonano",
  size: 20

config :slack_coder,
  slack_api_token: System.get_env("SLACK_API_TOKEN"),
  personal: true,
  timezone: "America/New_York",
  pr_backoff_start: 4,
  caretaker: :matt,
  # Used for internal API access
  travis_token: System.get_env("TRAVIS_API_TOKEN"),
  # Returned in `RandomFailure` file links and so is a potentially publicly accessible token
  travis_public_token: System.get_env("TRAVIS_PUBLIC_API_TOKEN"),
  circle_ci_token: System.get_env("CIRCLE_CI_API_TOKEN")

config :slack,
  api_token: System.get_env("SLACK_API_TOKEN")

config :slack_coder, :github,
  pat: System.get_env("GITHUB_PAT"),
  user: System.get_env("GITHUB_USER")

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: System.get_env("GITHUB_CLIENT_ID"),
  client_secret: System.get_env("GITHUB_CLIENT_SECRET")

config :slack_coder, SlackCoder.Guardian,
  secret_key: System.get_env("GUARDIAN_SECRET")

config :slack_coder, :notifications,
  min_hour: 8,
  max_hour: 17,
  always_allow: false,
  days: [1,2,3,4,5]
