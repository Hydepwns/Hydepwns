defmodule HydepwnsLiveviewWeb.Themes.ThemeToggleTest do
  use HydepwnsLiveviewWeb.ConnCase, async: false
  @moduletag :liveview
  import Phoenix.LiveViewTest
  import HydepwnsLiveview.TestThemeSystemFixtures

  alias HydepwnsLiveviewWeb.TestMockHelper

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

      TestMockHelper.setup_mocks()

      TestMockHelper.expect_api_call(:external_api, :fetch_data, fn _id ->
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
  end
end
