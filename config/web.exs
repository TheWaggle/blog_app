import Config

if config_env() == :dev do
  config :blog_app, BlogAppWeb.Endpoint,
    http: [ip: {127, 0, 0, 1}, port: 4000]
end
