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

    live "/", HomeLive
    live "/style-guide", StyleGuideLive
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
