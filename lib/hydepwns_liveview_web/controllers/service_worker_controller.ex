defmodule HydepwnsLiveviewWeb.ServiceWorkerController do
  use HydepwnsLiveviewWeb, :controller

  def index(conn, _params) do
    conn
    |> put_resp_content_type("application/javascript")
    |> put_resp_header("cache-control", "no-cache")
    |> send_file(
      200,
      Application.app_dir(:hydepwns_liveview, "priv/static/assets/service-worker.js")
    )
  end
end
