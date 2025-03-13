import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :hydepwns_liveview, HydepwnsLiveview.Repo,
  username: "droo",
  password: "",
  hostname: "localhost",
  database: "hydepwns_liveview_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :hydepwns_liveview, HydepwnsLiveviewWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "Yx+Yd+Yx+Yd+Yx+Yd+Yx+Yd+Yx+Yd+Yx+Yd+Yx+Yd+Yx+Yd+Yx+Yd+Yx+Yd+Yx+Yd+Yx+Yd+",
  server: false

# In test we don't send emails
config :hydepwns_liveview, HydepwnsLiveview.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

# Configure Mox
config :hydepwns_liveview, :http_client, HydepwnsLiveview.MockHTTPClient
config :hydepwns_liveview, :external_api, HydepwnsLiveview.MockExternalAPI
# Set Mox to global mode to allow stubs to be used from concurrent tests
config :mox, :global_stubs_only, true

# Configure Wallaby
config :wallaby,
  driver: Wallaby.Chrome,
  screenshot_dir: "test/screenshots",
  screenshot_on_failure: true,
  chromedriver: [
    headless: true
  ]

# Configure your application to work with Wallaby
config :hydepwns_liveview, HydepwnsLiveviewWeb.Endpoint,
  server: true,
  http: [port: 4002],
  debug_errors: true

# Set testing flag for relationship resolver
config :hydepwns_liveview, :testing, true
