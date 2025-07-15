defmodule HydepwnsLiveviewWeb.Api.ErrorController do
  use HydepwnsLiveviewWeb, :controller

  def not_found(conn, _params) do
    conn
    |> put_status(:not_found)
    |> json(%{error: "API endpoint not found"})
  end
end
