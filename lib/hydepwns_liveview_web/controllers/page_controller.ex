defmodule HydepwnsLiveviewWeb.PageController do
  use HydepwnsLiveviewWeb, :controller

  @doc """
  Renders the home page.
  Phoenix controller action: renders the home page without the default app layout.
  """
  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def favicon(conn, _params) do
    conn
    |> put_resp_content_type("image/x-icon")
    |> send_file(200, "priv/static/favicon.ico")
  end
end
