defmodule HydepwnsLiveviewWeb.PageControllerTest do
  use HydepwnsLiveviewWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Hydepwns Monospace Interface"
  end
end
