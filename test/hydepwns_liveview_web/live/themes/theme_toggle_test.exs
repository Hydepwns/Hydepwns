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
      {:ok, view, _html} = live(conn, "/themes")
      html = render(view)

      assert html =~ "Light"
      assert html =~ "Dark"
      assert html =~ "System"
      assert html =~ "Dim"
    end

    test "switches to light theme", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/themes")

      html =
        view
        |> element("button[data-theme='light']")
        |> render_click()

      assert html =~ "data-theme='light'"
      assert html =~ "aria-pressed='true'"
    end

    test "switches to dark theme", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/themes")

      html =
        view
        |> element("button[data-theme='dark']")
        |> render_click()

      assert html =~ "data-theme='dark'"
      assert html =~ "aria-pressed='true'"
    end

    test "switches to system theme", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/themes")

      html =
        view
        |> element("button[data-theme='system']")
        |> render_click()

      assert html =~ "data-theme='system'"
      assert html =~ "aria-pressed='true'"
    end

    test "switches to dim theme", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/themes")

      html =
        view
        |> element("button[data-theme='dim']")
        |> render_click()

      assert html =~ "data-theme='dim'"
      assert html =~ "aria-pressed='true'"
    end

    test "persists theme selection", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/themes")

      # Switch to dark theme
      view
      |> element("button[data-theme='dark']")
      |> render_click()

      # Reconnect and verify theme is still dark
      {:ok, view, _html} = live(conn, "/themes")
      html = render(view)
      assert html =~ "data-theme='dark'"
      assert html =~ "aria-pressed='true'"
    end

    test "respects system preference when system theme is selected", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/themes")

      # Switch to system theme
      view
      |> element("button[data-theme='system']")
      |> render_click()

      # Verify system theme is applied
      html = render(view)
      assert html =~ "data-theme='system'"
      assert html =~ "aria-pressed='true'"
    end

    test "updates theme when system preference changes", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/themes")

      # Switch to system theme
      view
      |> element("button[data-theme='system']")
      |> render_click()

      # Simulate system preference change to dark
      send(view.pid, {:system_preference_changed, true})
      html = render(view)
      assert html =~ "data-theme='dark'"

      # Simulate system preference change to light
      send(view.pid, {:system_preference_changed, false})
      html = render(view)
      assert html =~ "data-theme='light'"
    end
  end
end
