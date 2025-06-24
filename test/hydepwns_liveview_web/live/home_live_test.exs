defmodule HydepwnsLiveviewWeb.HomeLiveTest do
  @router HydepwnsLiveviewWeb.Router
  use HydepwnsLiveviewWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import Phoenix.VerifiedRoutes
  alias HydepwnsLiveviewWeb.TestMockHelper

  setup context do
    MockHelper.setup_mocks()

    MockHelper.expect_api_call(:external_api, :fetch_data, fn _id ->
      {:ok, %{"id" => "mock", "name" => "Mock Resource", "status" => "active"}}
    end)

    context
  end

  test "disconnected and connected render", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/")

    assert html =~ "Hydepwns"
    assert html =~ "Style Guide"
  end

  test "theme toggle is present", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert view |> element(".theme-toggle") |> has_element?()
  end

  test "navigation to style guide works", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    {:error, {:redirect, %{to: path}}} =
      view
      |> element("a", "Style Guide")
      |> render_click()

    assert path == "/style-guide"
  end
end
