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
  alias HydepwnsLiveviewWeb.TestMockHelper

  setup %{conn: conn} do
    # Optionally clear themes table for a clean slate
    HydepwnsLiveview.ThemeSystem.list_themes()
    |> Enum.each(&HydepwnsLiveview.ThemeSystem.delete_theme/1)

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

    MockHelper.setup_mocks()

    MockHelper.expect_api_call(:external_api, :fetch_data, fn _id ->
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
    assert html =~ "Current Themes"
    assert html =~ "Add New Theme"
  end

  test "displays list of themes", %{
    conn: conn,
    light_theme: light_theme,
    dark_theme: dark_theme
  } do
    ensure_theme_exists()
    {:ok, _view, html} = live(conn, "/themes")
    # Only check Current Themes section
    current_themes_html = html |> Floki.find(".mb-8 .grid") |> Floki.raw_html()
    assert current_themes_html =~ light_theme.name
    assert current_themes_html =~ dark_theme.name
  end

  test "creates a new theme", %{conn: conn} do
    ensure_theme_exists()
    {:ok, view, _html} = live(conn, "/themes")

    attrs = %{
      "theme" => %{
        "name" => "custom-theme",
        "mode" => "light",
        "primary_color" => "#ff0000",
        "secondary_color" => "#00ff00",
        "background_color" => "#ffffff",
        "text_color" => "#000000",
        "settings" => %{
          "font_size" => "medium",
          "line_height" => "normal",
          "contrast" => "normal",
          "animations" => true
        }
      }
    }

    assert view
           |> form("#theme-form", attrs)
           |> render_submit()

    # Verify the new theme appears in the list
    html = render(view)
    assert html =~ "custom-theme"
  end

  test "sets a theme as default", %{
    conn: conn,
    light_theme: light_theme,
    dark_theme: dark_theme
  } do
    ensure_theme_exists()
    {:ok, view, _html} = live(conn, "/themes")

    # Initially light theme should be default
    html = render(view)
    assert html =~ ~s{data-default="true"}
    assert html =~ light_theme.name

    # Set dark theme as default
    view
    |> element("button[data-action='set-default'][data-id='#{dark_theme.id}']")
    |> render_click()

    # Verify dark theme is now default
    html = render(view)
    assert html =~ ~s{data-default="true"}
    assert html =~ dark_theme.name
  end

  test "deletes a theme", %{conn: conn, dark_theme: dark_theme} do
    ensure_theme_exists()
    {:ok, view, html} = live(conn, "/themes")
    # Only check Current Themes section
    current_themes_html = html |> Floki.find(".mb-8 .grid") |> Floki.raw_html()
    # Assert the theme link for the dark theme is present
    assert Floki.find(current_themes_html, ~s{a[data-test-id="theme-link-#{dark_theme.id}"]}) !=
             []

    # Delete the theme
    view
    |> element("button[data-action='delete'][data-id='#{dark_theme.id}']")
    |> render_click()

    # Verify theme link is removed from Current Themes
    html = render(view)
    current_themes_html = html |> Floki.find(".mb-8 .grid") |> Floki.raw_html()

    refute Floki.find(current_themes_html, ~s{a[data-test-id="theme-link-#{dark_theme.id}"]}) !=
             []
  end

  test "validates theme creation", %{conn: conn} do
    ensure_theme_exists()
    {:ok, view, _html} = live(conn, "/themes")

    # Try to create a theme with invalid data (blank name)
    attrs = %{
      "theme" => %{
        "name" => "",
        # valid mode, but name is blank
        "mode" => "light",
        "primary_color" => "#ff0000",
        "secondary_color" => "#00ff00",
        "background_color" => "#ffffff",
        "text_color" => "#000000"
      }
    }

    html =
      view
      |> form("#theme-form", attrs)
      |> render_submit()

    # Verify error messages (HTML-escaped)
    assert html =~ "can&#39;t be blank"
  end

  test "updates an existing theme", %{conn: conn, light_theme: light_theme} do
    ensure_theme_exists()
    {:ok, view, _html} = live(conn, "/themes")

    # Edit the theme
    attrs = %{
      "theme" => %{
        "name" => "updated-light",
        "mode" => "light",
        "primary_color" => "#ff0000",
        "secondary_color" => "#00ff00",
        "background_color" => "#ffffff",
        "text_color" => "#000000",
        "settings" => %{
          "font_size" => "medium",
          "line_height" => "normal",
          "contrast" => "normal",
          "animations" => true
        }
      }
    }

    view
    |> element("button[data-action='edit'][data-id='#{light_theme.id}']")
    |> render_click()

    view
    |> form("#theme-form", attrs)
    |> render_submit()

    # Verify the theme was updated
    html = render(view)
    assert html =~ "updated-light"
    assert html =~ "#ff0000"
  end

  test "handles theme mode changes", %{conn: conn, light_theme: light_theme} do
    ensure_theme_exists()
    {:ok, view, _html} = live(conn, "/themes")

    # Change theme mode to dark
    attrs = %{
      "theme" => %{
        "name" => light_theme.name,
        "mode" => "dark",
        "primary_color" => light_theme.primary_color,
        "secondary_color" => light_theme.secondary_color,
        "background_color" => light_theme.background_color,
        "text_color" => light_theme.text_color,
        "settings" => light_theme.settings
      }
    }

    view
    |> element("button[data-action='edit'][data-id='#{light_theme.id}']")
    |> render_click()

    view
    |> form("#edit-theme-form", attrs)
    |> render_submit()

    # Verify the theme mode was updated by checking the data-mode attribute on the main container
    html = render(view)
    [mode_div | _] = Floki.find(html, ~s([data-mode]))
    mode_value = Floki.attribute(mode_div, "data-mode")
    assert mode_value == ["dark"]
  end

  defp ensure_theme_exists do
    themes = HydepwnsLiveview.ThemeSystem.list_themes()
    assert length(themes) > 0
  end
end
