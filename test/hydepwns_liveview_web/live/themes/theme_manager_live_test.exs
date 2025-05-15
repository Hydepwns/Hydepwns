defmodule HydepwnsLiveviewWeb.Themes.ThemeManagerLiveTest do
  use HydepwnsLiveviewWeb.ConnCase
  import Phoenix.LiveViewTest
  import HydepwnsLiveview.ThemeSystemFixtures

  describe "Theme Manager Live View" do
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

    test "renders theme manager page", %{conn: conn} do
      {:ok, view, html} = live(conn, "/themes")
      assert html =~ "Theme Manager"
      assert html =~ "Current Themes"
      assert html =~ "Add New Theme"
    end

    test "displays list of themes", %{
      conn: conn,
      light_theme: light_theme,
      dark_theme: dark_theme
    } do
      {:ok, view, html} = live(conn, "/themes")
      assert html =~ light_theme.name
      assert html =~ dark_theme.name
    end

    test "creates a new theme", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/themes")

      attrs = %{
        "theme" => %{
          "name" => "custom-theme",
          "mode" => "light",
          "colors" => %{
            "primary" => "#ff0000",
            "secondary" => "#00ff00",
            "accent" => "#0000ff",
            "background" => "#ffffff",
            "text" => "#000000"
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
      {:ok, view, _html} = live(conn, "/themes")

      # Initially light theme should be default
      html = render(view)
      assert html =~ "data-default='true'"
      assert html =~ light_theme.name

      # Set dark theme as default
      view
      |> element("button[data-action='set-default'][data-id='#{dark_theme.id}']")
      |> render_click()

      # Verify dark theme is now default
      html = render(view)
      assert html =~ "data-default='true'"
      assert html =~ dark_theme.name
    end

    test "deletes a theme", %{conn: conn, light_theme: light_theme} do
      {:ok, view, _html} = live(conn, "/themes")

      # Verify theme exists
      html = render(view)
      assert html =~ light_theme.name

      # Delete the theme
      view
      |> element("button[data-action='delete'][data-id='#{light_theme.id}']")
      |> render_click()

      # Verify theme is removed
      html = render(view)
      refute html =~ light_theme.name
    end

    test "validates theme creation", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/themes")

      # Try to create a theme with invalid data
      attrs = %{
        "theme" => %{
          # Invalid: empty name
          "name" => "",
          # Invalid: not a valid mode
          "mode" => "invalid_mode"
        }
      }

      html =
        view
        |> form("#theme-form", attrs)
        |> render_submit()

      # Verify error messages
      assert html =~ "can't be blank"
      assert html =~ "is invalid"
    end

    test "updates an existing theme", %{conn: conn, light_theme: light_theme} do
      {:ok, view, _html} = live(conn, "/themes")

      # Edit the theme
      attrs = %{
        "theme" => %{
          "name" => "updated-light",
          "mode" => "light",
          "colors" => %{
            "primary" => "#ff0000",
            "secondary" => "#00ff00",
            "accent" => "#0000ff",
            "background" => "#ffffff",
            "text" => "#000000"
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
      {:ok, view, _html} = live(conn, "/themes")

      # Change theme mode to dark
      attrs = %{
        "theme" => %{
          "name" => light_theme.name,
          "mode" => "dark",
          "colors" => light_theme.colors
        }
      }

      view
      |> element("button[data-action='edit'][data-id='#{light_theme.id}']")
      |> render_click()

      view
      |> form("#theme-form", attrs)
      |> render_submit()

      # Verify the theme mode was updated
      html = render(view)
      assert html =~ "data-mode='dark'"
    end
  end
end
