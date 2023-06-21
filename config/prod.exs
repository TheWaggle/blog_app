import Config

config :blog_app, BlogApp.Repo,
  username: "postgres",
  password: "postgres",
  database: "blog_app_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

if Mix.target() == :ios do
  config :blog_app, BlogApp.Repo, hostname: "127.0.0.1"
end

if Mix.target() == :android do
  config :blog_app, BlogApp.Repo, hostname: "10.0.2.2"
end

config :blog_app, BlogAppWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 0],
  live_view: [signing_salt: "HMPMHcTJ"],
  secret_key_base: :crypto.strong_rand_bytes(32),
  server: true,
  cache_static_manifest: "priv/static/cache_manifest.json"

# Configures Swoosh API Client
config :swoosh, api_client: Swoosh.ApiClient.Finch, finch_name: BlogApp.Finch

# Do not print debug messages in production
config :logger, level: :info

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.
