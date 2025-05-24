defmodule HydepwnsLiveviewWeb.Router do
  use HydepwnsLiveviewWeb, :router

  # Standard browser pipeline
  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {HydepwnsLiveviewWeb.Components.Layout.Layouts, :root}
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

    live "/", HomeLive, :index
    live "/about", AboutLive, :index
    live "/projects", ProjectsLive, :index
    live "/style-guide", StyleGuideLive, :index
    live "/screen-reader-test", ScreenReaderTestLive, :index
    live "/api-docs", ApiDocsLive, :index
    live "/grid-playground", GridPlaygroundLive, :index
    live "/gallery", GalleryLive, :index
    live "/themes", Themes.ThemeManagerLive, :index
    live "/themes/:id", Themes.ThemeDetailLive

    # Resource Management
    live "/resources", ResourceDashboardLive, :index
    live "/resources/new", ResourceFormLive, :new
    live "/resources/:id", ResourceShowLive, :show
    # Reuse form for editing
    live "/resources/:id/edit", ResourceFormLive, :edit
    live "/resources/:id/manage-subscriptions", ResourceSubscriptionLive, :manage_subscriptions

    # Theme system routes
    resources "/themes", ThemeController

    # Playground routes
    scope "/playground", Live.Playground, as: :playground do
      # Terminal demo route removed
    end

    # Examples routes
    scope "/examples", Examples, as: :examples do
      live "/type-validation", TypeValidationExample, :index
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

    # Add a test route for validation testing
    live "/test", TestErrorLive

    # Admin routes
    scope "/admin", Admin, as: :admin do
      live "/event-dashboard", EventDashboardLive, :index
      live "/resources", ResourceDashboardLive, :index
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
