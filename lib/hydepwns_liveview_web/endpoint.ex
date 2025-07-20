defmodule HydepwnsLiveviewWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :hydepwns_liveview

  @session_options [
    store: :cookie,
    key: "_hydepwns_liveview_key",
    signing_salt: "RtEu4ufu",
    same_site: "Lax"
  ]

  socket "/live", HydepwnsLiveviewWeb.Socket,
    websocket: [connect_info: [session: @session_options, cookies: :all]],
    longpoll: [connect_info: [session: @session_options, cookies: :all]]

  plug Plug.Static,
    at: "/",
    from: :hydepwns_liveview,
    gzip: false,
    only: HydepwnsLiveviewWeb.static_paths()

  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :hydepwns_liveview
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options

  plug HydepwnsLiveviewWeb.Plugs.CustomSecurityHeaders

  if Application.compile_env(:hydepwns_liveview, :sql_sandbox, false) do
    plug Phoenix.Ecto.SQL.Sandbox
    plug HydepwnsLiveviewWeb.Plugs.SandboxSession
  end

  plug HydepwnsLiveviewWeb.Router
end
