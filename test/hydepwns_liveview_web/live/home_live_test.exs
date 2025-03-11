defmodule HydepwnsLiveviewWeb.HomeLiveTest do
  use HydepwnsLiveviewWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/")

    assert html =~ "Welcome to Monospace Web"
    assert html =~ "Hydepwns"
    assert html =~ "View Style Guide"
  end

  test "theme toggle is present", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert view |> element(".theme-toggle") |> has_element?()
  end

  test "navigation to style guide works", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    {:error, {:live_redirect, %{to: path}}} =
      view
      |> element("a", "View Style Guide")
      |> render_click()

    assert path == "/style-guide"
  end
end
