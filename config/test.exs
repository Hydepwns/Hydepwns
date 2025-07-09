import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :hydepwns_liveview, HydepwnsLiveview.Repo,
  username: System.get_env("TEST_DB_USERNAME") || "postgres",
  password: System.get_env("TEST_DB_PASSWORD") || "",
  hostname: System.get_env("TEST_DB_HOST") || "localhost",
  socket_dir: System.get_env("TEST_DB_SOCKET_DIR") || nil,
  database:
    System.get_env("TEST_DB_NAME") ||
      "hydepwns_liveview_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :hydepwns_liveview, HydepwnsLiveviewWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: System.get_env("TEST_SECRET_KEY_BASE") || String.duplicate("a", 64),
  server: false

# In test we don't send emails
config :hydepwns_liveview, HydepwnsLiveview.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :debug

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

# Configure Mox
config :hydepwns_liveview, :http_client, HydepwnsLiveview.MockHTTPClient
config :hydepwns_liveview, :external_api, HydepwnsLiveview.MockExternalAPI
config :hydepwns_liveview, :repo, HydepwnsLiveview.RepoMock
# Set Mox to global mode to allow stubs to be used from concurrent tests
config :mox, :global_stubs_only, true

# Configure Wallaby
config :wallaby,
  driver: Wallaby.Chrome,
  screenshot_dir: "test/screenshots",
  screenshot_on_failure: true,
  chrome: [
    headless: true,
    capabilities: %{
      chromeOptions: %{
        args: [
          "no-sandbox",
          "disable-dev-shm-usage",
          "--enable-javascript",
          "--disable-web-security=false"
        ]
      }
    }
  ],
  chromedriver: [
    path: "chromedriver",
    binary: "/nix/store/543z3c6jdqf4j9zkfy58il7vracyn28g-google-chrome-137.0.7151.103/share/google/chrome/chrome"
  ],
  base_url: "http://localhost:4002"

# Configure your application to work with Wallaby
config :hydepwns_liveview, HydepwnsLiveviewWeb.Endpoint,
  server: true,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  debug_errors: true,
  secret_key_base: String.duplicate("a", 64)

# Enable SQL sandbox for the application
config :hydepwns_liveview, :sql_sandbox, true

# Set testing flag for relationship resolver
config :hydepwns_liveview, :testing, true

# Enable the :sql_sandbox flag for the test environment
config :hydepwns_liveview, :sql_sandbox, true

# Disable code reloader and live reloader for tests to avoid potential side effects
config :hydepwns_liveview, HydepwnsLiveviewWeb.Endpoint, code_reloader: false

config :phoenix, :live_reload, enable: false

# Configure mock reminder services for testing
config :hydepwns_liveview, :reminder_services,
  email: %{
    provider: "mock",
    from_email: "test@example.com",
    from_name: "Test App",
    api_key: "mock_api_key"
  },
  sms: %{
    provider: "mock",
    api_key: "mock_sms_key",
    from_number: "+1234567890"
  },
  push: %{
    provider: "mock",
    api_key: "mock_push_key"
  }

# Configure mock crypto service for testing
config :hydepwns_liveview, :crypto_service, HydepwnsLiveview.Events.MockCryptoService

# Configure EventStore to use MockEventStore in tests
config :hydepwns_liveview, :event_store, HydepwnsLiveview.TestSupport.MockEventStore
