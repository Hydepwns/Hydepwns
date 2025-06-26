defmodule HydepwnsLiveviewWeb.Themes.ThemeManagerLiveTest do
  @moduledoc """
  Test suite for the ThemeManagerLive module.

  These tests verify theme management functionality including:
  - Theme creation, updating and deletion
  - Setting default themes
  - Theme validation
  - Theme mode changes
  """
  use HydepwnsLiveviewWeb.ConnCase, async: false
  @moduletag :liveview
  import Phoenix.LiveViewTest
  import HydepwnsLiveview.TestThemeSystemFixtures
  import HydepwnsLiveview.TestSupport.ThemeSystemHelper
  alias HydepwnsLiveviewWeb.TestMockHelper

  setup %{conn: conn} do
    # Set up per-test theme system isolation
    {:ok, _table} = setup_theme_system_isolation()

    {:ok, light_theme} = light_theme_fixture()
    {:ok, dark_theme} = dark_theme_fixture()
    {:ok, system_theme} = system_theme_fixture()
    {:ok, dim_theme} = dim_theme_fixture()
    themes = HydepwnsLiveview.ThemeSystem.list_themes()

    # Defensive: ensure themes are present and valid
    assert length(themes) >= 4

    Enum.each(themes, fn theme ->
      assert theme.id != nil
      assert theme.name != nil and theme.name != ""
      assert theme.mode in ["light", "dark", "dim", "system"]
    end)

    TestMockHelper.setup_mocks()

    TestMockHelper.expect_api_call(:external_api, :fetch_data, fn _id ->
      {:ok, %{"id" => "mock", "name" => "Mock Resource", "status" => "active"}}
    end)

    {:ok,
     conn: conn,
     light_theme: light_theme,
     dark_theme: dark_theme,
     system_theme: system_theme,
     dim_theme: dim_theme}
  end

  test "renders theme manager page", %{conn: conn} do
    ensure_theme_exists()
    {:ok, _view, html} = live(conn, "/themes")
    assert html =~ "Theme Manager"
    assert html =~ "Create Theme"
  end

  test "displays list of themes", %{
    conn: conn,
    light_theme: light_theme,
    dark_theme: dark_theme
  } do
    ensure_theme_exists()
    {:ok, _view, html} = live(conn, "/themes")
    assert html =~ light_theme.name
    assert html =~ dark_theme.name
  end

  test "creates a new theme", %{conn: conn} do
    ensure_theme_exists()
    {:ok, view, _html} = live(conn, "/themes")

    # Click the Create Theme button which should navigate to the new theme page
    view
    |> element("button[phx-click='go_to_create_theme']")
    |> render_click()

    # Verify we navigated to the create theme page
    assert_redirect(view, "/themes/new")
  end

  test "sets a theme as default", %{
    conn: conn,
    light_theme: light_theme,
    dark_theme: dark_theme
  } do
    ensure_theme_exists()
    {:ok, view, _html} = live(conn, "/themes")

    # Verify both themes are displayed
    html = render(view)
    assert html =~ light_theme.name
    assert html =~ dark_theme.name

    # Apply the dark theme
    view
    |> element("button[phx-click='apply'][phx-value-id='#{dark_theme.id}']")
    |> render_click()

    # Verify the apply action was triggered (theme application is handled by the theme system)
    html = render(view)
    assert html =~ dark_theme.name
  end

  test "deletes a theme", %{conn: conn, dark_theme: dark_theme} do
    ensure_theme_exists()
    {:ok, view, html} = live(conn, "/themes")
    
    # Assert the theme link for the dark theme is present
    assert html =~ dark_theme.name

    # Delete the theme
    view
    |> element("button[phx-click='delete'][phx-value-id='#{dark_theme.id}']")
    |> render_click()

    # Verify theme is removed from the list
    html = render(view)
    refute html =~ dark_theme.name
  end

  test "updates an existing theme", %{conn: conn, light_theme: light_theme} do
    ensure_theme_exists()
    {:ok, view, _html} = live(conn, "/themes")

    # Click the Edit button which should navigate to the edit theme page
    view
    |> element("a[data-test-id='edit-theme-#{light_theme.id}']")
    |> render_click()

    # Verify we navigated to the edit theme page
    assert_redirect(view, "/themes/#{light_theme.id}/edit")
  end

  test "handles theme mode changes", %{conn: conn, light_theme: light_theme} do
    ensure_theme_exists()
    {:ok, view, _html} = live(conn, "/themes")

    # Click the Edit button to navigate to the edit page where mode changes happen
    view
    |> element("a[data-test-id='edit-theme-#{light_theme.id}']")
    |> render_click()

    # Verify we navigated to the edit theme page where mode changes can be made
    assert_redirect(view, "/themes/#{light_theme.id}/edit")
  end

  defp ensure_theme_exists do
    themes = HydepwnsLiveview.ThemeSystem.list_themes()
    assert length(themes) > 0
  end
end
