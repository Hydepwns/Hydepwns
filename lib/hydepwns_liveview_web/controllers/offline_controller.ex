defmodule HydepwnsLiveviewWeb.OfflineController do
  use HydepwnsLiveviewWeb, :controller

  def index(conn, _params) do
    render(conn, :render, layout: false)
  end
end
