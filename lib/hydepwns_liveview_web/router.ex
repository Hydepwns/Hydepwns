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
    live "/theme-manager", Themes.ThemeManagerLive

    # Theme system routes
    resources "/themes", ThemeController

    # Playground routes
    scope "/playground", Live.Playground, as: :playground do
      live "/terminal", TerminalDemoLive, :index
    end

    # Examples routes
    scope "/examples", Examples, as: :examples do
      live "/type-validation", TypeValidationExample, :index
      live "/resource-assigns", UserResourceLive, :index
      live "/user-resource", UserResourceExampleLive, :index
      live "/ecto-resource", EctoResourceExampleLive, :index
    end

    # Offline fallback page
    get "/offline", OfflineController, :index

    # Service worker
    get "/service-worker.js", ServiceWorkerController, :index

    # Add a test route for validation testing
    live "/test", EnhancedErrorReportingTest.TestErrorLive
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
