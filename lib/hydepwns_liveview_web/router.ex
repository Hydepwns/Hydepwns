defmodule HydepwnsLiveviewWeb.Router do
  use HydepwnsLiveviewWeb, :router

  # Standard browser pipeline
  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {HydepwnsLiveviewWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  # API pipeline for future use
  pipeline :api do
    plug :accepts, ["json"]
  end

  # Main application routes
  scope "/", HydepwnsLiveviewWeb do
    pipe_through :browser

    # get "/", PageController, :home
    # get "/favicon.ico", PageController, :favicon

    live "/", HomeLive, :index
    live "/about", AboutLive, :index
    live "/projects", ProjectsLive, :index
    live "/style-guide", StyleGuideLive, :index
    live "/screen-reader-test", ScreenReaderTestLive, :index
    live "/api-docs", ApiDocsLive, :index
    live "/grid-playground", GridPlaygroundLive, :index
    live "/gallery", GalleryLive, :index
    live "/themes", Themes.ThemeManagerLive, :index

    # User routes
    live "/users", UserLive, :index
    live "/users/log_in", UserSessionLive, :new
    live "/users/register", UserRegistrationLive, :new
    live "/users/settings", UserSettingsLive, :edit
    live "/users/profile", UserProfileLive, :edit
    live "/users/:id", UserShowLive, :show
    live "/users/:id/edit", UserShowLive, :edit

    # Bridge routes
    live "/bridges/new", BridgeFormLive, :new
    live "/bridges/:id", BridgeShowLive, :show
    live "/bridges/:id/edit", BridgeFormLive, :edit

    # Resource Management
    live "/resources", ResourceDashboardLive, :index
    live "/resources/new", ResourceFormLive, :new
    live "/resources/:id", ResourceShowLive, :show
    # Reuse form for editing
    live "/resources/:id/edit", ResourceFormLive, :load_for_editing
    live "/resources/:id/manage-subscriptions", ResourceSubscriptionLive, :manage_subscriptions
    live "/resources/:id/events", ResourceEventSystemLive, :index
    live "/resources/:id/subscriptions", ResourceSubscriptionLive, :index
    live "/terminal", TerminalLive
    live "/events", ResourceEventSystemLive, :index

    # Theme system routes
    resources "/themes", ThemeController

    # Playground routes
    scope "/playground", Live.Playground, as: :playground do
      # Terminal demo route removed
    end

    # Examples routes
    scope "/examples", Examples, as: :examples do
#      live "/type-validation", TypeValidationExample, :index
      live "/resource-assigns", UserResourceLive, :index
      live "/user-resource", UserResourceExampleLive, :index
      live "/ecto-resource", EctoResourceExampleLive, :index
      live "/change-tracking", ChangeTrackingExampleLive, :index
      live "/nested-validation", NestedValidationExampleLive, :index
      live "/transformation", TransformationExampleLive, :index
      live "/transformation-metrics", TransformationMetricsLive, :index
      live "/context-validation-tracking", ContextValidationTrackingExampleLive, :index
      live "/event-system", EventSystemExampleLive, :index
    end

    # Offline fallback page
    get "/offline", OfflineController, :index

    # Service worker
    get "/service-worker.js", ServiceWorkerController, :index

    # Add a test route for validation testing (temporarily removed)
    live "/test", HydepwnsLiveviewWeb.TestErrorLive, :index, as: :test_error

    # Admin routes
    scope "/admin", Admin, as: :admin do
      live "/event-dashboard", EventDashboardLive, :index
      live "/resources", ResourceDashboardLive, :index
    end

    live "/account", AccountLive, :index
    live "/account/notifications", NotificationSettingsLive, :index

    # Test-only route for type validation tests
    if Mix.env() == :test do
      live_session :test_types, on_mount: [] do
        live "/test-types", TestTypeLive
      end
    end
  end

  # Development-only routes
  if Application.compile_env(:hydepwns_liveview, :dev_routes) do
    # Import LiveDashboard for development
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: HydepwnsLiveviewWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
