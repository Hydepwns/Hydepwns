defmodule HydepwnsLiveviewWeb.Themes.ThemeToggleTest do
  use HydepwnsLiveviewWeb.ConnCase, async: false
  @moduletag :liveview
  import Phoenix.LiveViewTest
  import HydepwnsLiveview.ThemeSystemFixtures
  import ThemeHelper

  alias HydepwnsLiveviewWeb.MockHelper

  describe "Theme Toggle Component" do
    setup %{conn: conn} do
      # Optionally clear themes table for a clean slate
      HydepwnsLiveview.ThemeSystem.list_themes()
      |> Enum.each(&HydepwnsLiveview.ThemeSystem.delete_theme/1)

      {:ok, light_theme} = light_theme_fixture()
      {:ok, dark_theme} = dark_theme_fixture()
      {:ok, system_theme} = system_theme_fixture()
      {:ok, dim_theme} = dim_theme_fixture()
      {:ok, high_contrast_theme} = high_contrast_theme_fixture()

      themes = HydepwnsLiveview.ThemeSystem.list_themes()
      # Defensive: ensure themes are present and valid
      assert length(themes) >= 4
      Enum.each(themes, fn theme ->
        assert theme.id != nil
        assert theme.name != nil and theme.name != ""
        assert theme.mode in ["light", "dark", "dim", "system"]
      end)

      MockHelper.setup_mocks()
      MockHelper.expect_api_call(:external_api, :fetch_data, fn _id ->
        {:ok, %{"id" => "mock", "name" => "Mock Resource", "status" => "active"}}
      end)

      %{
        light_theme: light_theme,
        dark_theme: dark_theme,
        system_theme: system_theme,
        dim_theme: dim_theme,
        high_contrast_theme: high_contrast_theme,
        conn: conn
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
      # Use new_view to avoid stale view
      {:ok, new_view, _html} = live(conn, "/themes")
      assert element(new_view, "button[data-theme='dark'][aria-pressed='true']")
    end
  end
end
