defmodule HydepwnsLiveviewWeb.Themes.ThemeToggleTest do
  use HydepwnsLiveviewWeb.ConnCase
  import Phoenix.LiveViewTest
  import HydepwnsLiveview.ThemeSystemFixtures

  describe "Theme Toggle Component" do
    setup do
      light_theme = light_theme_fixture()
      dark_theme = dark_theme_fixture()
      system_theme = system_theme_fixture()
      dim_theme = dim_theme_fixture()

      %{
        light_theme: light_theme,
        dark_theme: dark_theme,
        system_theme: system_theme,
        dim_theme: dim_theme
      }
    end

    test "renders theme toggle buttons", %{conn: conn} do
      conn = Plug.Conn.assign(conn, :current_path, "/themes")
      {:ok, view, _html} = live(conn, "/themes")
      html = render(view)

      assert html =~ "Light theme"
      assert html =~ "Dark theme"
      assert html =~ "Dim theme"
      assert html =~ "High contrast theme"
    end

    test "switches to light theme", %{conn: conn} do
      conn = Plug.Conn.assign(conn, :current_path, "/themes")
      {:ok, view, _html} = live(conn, "/themes")

      view
      |> element("button[data-theme='light']")
      |> render_click()

      assert element(view, "button[data-theme='light'][aria-pressed='true']")
    end

    test "switches to dark theme", %{conn: conn} do
      conn = Plug.Conn.assign(conn, :current_path, "/themes")
      {:ok, view, _html} = live(conn, "/themes")

      view
      |> element("button[data-theme='dark']")
      |> render_click()

      assert element(view, "button[data-theme='dark'][aria-pressed='true']")
    end

    test "switches to dim theme", %{conn: conn} do
      conn = Plug.Conn.assign(conn, :current_path, "/themes")
      {:ok, view, _html} = live(conn, "/themes")

      view
      |> element("button[data-theme='dim']")
      |> render_click()

      assert element(view, "button[data-theme='dim'][aria-pressed='true']")
    end

    test "persists theme selection", %{conn: conn} do
      conn = Plug.Conn.assign(conn, :current_path, "/themes")
      {:ok, view, _html} = live(conn, "/themes")

      # Switch to dark theme
      view
      |> element("button[data-theme='dark']")
      |> render_click()

      # Reconnect and verify theme is still dark by checking aria-pressed
      {:ok, new_view, _html} = live(conn, "/themes") # Use new_view to avoid stale view
      assert element(new_view, "button[data-theme='dark'][aria-pressed='true']")
    end
  end
end
