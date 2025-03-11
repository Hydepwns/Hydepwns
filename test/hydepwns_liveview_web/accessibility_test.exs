defmodule HydepwnsLiveviewWeb.AccessibilityTest do
  use HydepwnsLiveviewWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  describe "Accessibility features" do
    test "skip to content link is present", %{conn: conn} do
      {:ok, view, html} = live(conn, "/")

      # Check that the skip to content link is present
      assert html =~ "Skip to content"
      assert html =~ "skip-to-content"
      assert html =~ "href=\"#main-content\""
    end

    test "proper heading hierarchy in style guide", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/style-guide")

      # Check that there is an h1
      assert has_element?(view, "h1", "Hydepwns Monospace Style Guide")

      # Check that h2 elements are used for section headings
      assert has_element?(view, "h2", "Typography")
      assert has_element?(view, "h2", "Color Palette")
      assert has_element?(view, "h2", "Grid System")
      assert has_element?(view, "h2", "Components")
      assert has_element?(view, "h2", "Animations")
      assert has_element?(view, "h2", "Accessibility")

      # Check that h3 elements are used for subsection headings
      assert has_element?(view, "h3", "Font Family")
      assert has_element?(view, "h3", "Text Styles")
      assert has_element?(view, "h3", "Light Theme")
      assert has_element?(view, "h3", "Dark Theme")
      assert has_element?(view, "h3", "MonoGrid Component")
      assert has_element?(view, "h3", "Terminal Component")
      assert has_element?(view, "h3", "ASCII Art Generator")
      assert has_element?(view, "h3", "Diagram Editor")
      assert has_element?(view, "h3", "Theme Toggle")
      assert has_element?(view, "h3", "Typewriter Animation")
      assert has_element?(view, "h3", "Grid Animation")
      assert has_element?(view, "h3", "Keyboard Navigation")
      assert has_element?(view, "h3", "Reduced Motion")
      assert has_element?(view, "h3", "High Contrast Mode")

      # Check that h4 elements are used for example headings
      assert has_element?(view, "h4", "Basic Usage")
    end

    test "proper ARIA attributes in style guide", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/style-guide")

      # Check that the high contrast toggle has proper ARIA attributes
      assert has_element?(view, "button.high-contrast-toggle[aria-pressed]")

      # Check that links have proper ARIA labels
      assert has_element?(view, "a[aria-label='Example link']")
    end

    test "reduced motion media query is used in CSS", %{conn: conn} do
      # We can't directly test the CSS, but we can check that the style guide
      # mentions the reduced motion media query
      {:ok, view, html} = live(conn, "/style-guide")

      assert html =~ "@media (prefers-reduced-motion: reduce)"
      assert html =~ "animation: none !important"
    end

    test "keyboard navigation is supported", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/style-guide")

      # Check that interactive elements have proper tabindex
      assert has_element?(view, "button[tabindex='0']")
    end
  end
end 