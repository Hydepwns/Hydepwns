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
end
