defmodule HydepwnsLiveviewWeb.StyleGuideLiveTest do
  use HydepwnsLiveviewWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  describe "StyleGuideLive" do
    test "renders the style guide page", %{conn: conn} do
      {:ok, view, html} = live(conn, "/style-guide")

      # Test that the page title is correct
      assert html =~ "Style Guide"
      
      # Test that the style guide component is rendered
      assert html =~ "Hydepwns Monospace Style Guide"
      assert html =~ "Welcome to the comprehensive style guide"
      
      # Test that the style guide sections are present
      assert html =~ "Typography"
      assert html =~ "Color Palette"
      assert html =~ "Grid System"
      assert html =~ "Components"
      assert html =~ "Animations"
      assert html =~ "Accessibility"
    end

    test "can change theme", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/style-guide")

      # Test that the theme can be changed
      view
      |> element("button", "Light")
      |> render_click()

      # Verify that the theme class has been updated
      assert has_element?(view, "[data-theme='light-theme']")
    end
  end
end 