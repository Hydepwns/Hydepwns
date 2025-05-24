defmodule HydepwnsLiveviewWeb.ThemeControllerTest do
  @endpoint HydepwnsLiveviewWeb.Endpoint
  @router HydepwnsLiveviewWeb.Router
  import Phoenix.VerifiedRoutes
  use HydepwnsLiveviewWeb.ConnCase, async: true
  import Phoenix.Component

  alias HydepwnsLiveview.ThemeSystem

  @create_attrs %{
    name: "some name",
    type: "light",
    primary_color: "#4A90E2",
    secondary_color: "#50E3C2",
    font_family: "monospace",
    font_size: "14px"
  }
  @update_attrs %{
    name: "some updated name",
    type: "dark",
    primary_color: "#000000",
    secondary_color: "#FFFFFF",
    font_family: "sans-serif",
    font_size: "16px"
  }
  @invalid_attrs %{name: nil, type: nil}

  def fixture(:theme) do
    {:ok, theme} = ThemeSystem.create_theme(@create_attrs)
    theme
  end

  describe "index" do
    test "lists all themes", %{conn: conn} do
      conn = get(conn, ~p"/themes")
      assert html_response(conn, 200) =~ "Themes"
    end
  end

  describe "new theme" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/themes/new")
      assert html_response(conn, 200) =~ "New Theme"
    end
  end

  describe "create theme" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/themes", theme: @create_attrs)

      assert id = Map.get(redirected_params(conn), :id) || Map.get(redirected_params(conn), "id")
      assert redirected_to(conn) == ~p"/themes/#{id}"

      conn = get(conn, ~p"/themes/#{id}")
      assert html_response(conn, 200) =~ "Theme #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/themes", theme: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Theme"
    end
  end

  describe "edit theme" do
    setup [:create_theme]

    test "renders form for editing chosen theme", %{conn: conn, theme: theme} do
      conn = get(conn, ~p"/themes/#{theme}/edit")
      assert html_response(conn, 200) =~ "Edit Theme"
    end
  end

  describe "update theme" do
    setup [:create_theme]

    test "redirects when data is valid", %{conn: conn, theme: theme} do
      conn = put(conn, ~p"/themes/#{theme}", theme: @update_attrs)
      assert redirected_to(conn) == ~p"/themes/#{theme}"

      conn = get(conn, ~p"/themes/#{theme}")
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, theme: theme} do
      conn = put(conn, ~p"/themes/#{theme}", theme: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Theme"
    end
  end

  describe "delete theme" do
    setup [:create_theme]

    test "deletes chosen theme", %{conn: conn, theme: theme} do
      conn = delete(conn, ~p"/themes/#{theme}")
      assert redirected_to(conn) == ~p"/themes"

      assert_error_sent 404, fn ->
        get(conn, ~p"/themes/#{theme}")
      end
    end
  end

  defp create_theme(_) do
    theme = fixture(:theme)
    %{theme: theme}
  end
end
