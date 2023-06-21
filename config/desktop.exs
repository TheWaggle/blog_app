import Config

config :blog_app, BlogAppWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  render_errors: [
    formats: [html: BlogAppWeb.ErrorHTML, json: BlogAppWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: BlogApp.PubSub,
  live_view: [signing_salt: "HMPMHcTJ"],
  secret_key_base: :crypto.strong_rand_bytes(32),
  server: true
