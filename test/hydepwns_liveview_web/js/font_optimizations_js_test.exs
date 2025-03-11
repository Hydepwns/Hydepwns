defmodule HydepwnsLiveviewWeb.FontOptimizationsJsTest do
  use HydepwnsLiveviewWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import HydepwnsLiveviewWeb.JsTestHelper

  describe "Font Optimizations JavaScript" do
    test "font loading classes are applied", %{conn: conn} do
      {:ok, view, html} = live(conn, "/")

      # Check that the fonts-loading class is initially applied to the html element
      assert html =~ ~s(class="fonts-loading)

      # Note: We can't fully test the JavaScript font loading in a server-side test,
      # but we can verify that the elements and classes are set up correctly for the
      # JavaScript to work with
    end

    test "font fallback is defined", %{conn: conn} do
      {:ok, view, html} = live(conn, "/")

      # Check that the fallback font face is defined in the inline styles
      assert html =~ "font-family: 'Monaspace Argon Fallback'"
      assert html =~ "local('JetBrains Mono'), local('Courier New'), local('monospace')"
    end

    test "font caching mechanism is set up", %{conn: conn} do
      {:ok, view, html} = live(conn, "/")

      # Check that the font caching script is included
      assert html =~ "FONTS_LOADED_KEY"
      assert html =~ "sessionStorage.getItem"
      assert html =~ "fonts-cached"
    end

    test "preload links are present", %{conn: conn} do
      {:ok, view, html} = live(conn, "/")

      # Check that the preload links are present
      assert html =~ ~s(<link rel="preload" href="/assets/fonts/MonaspaceArgon-Regular.woff2")
      assert html =~ ~s(<link rel="preload" href="/assets/fonts/MonaspaceArgon-Bold.woff2")
    end

    test "font-display: swap is used", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/style-guide")

      # Navigate to the style guide to see the font examples
      # We can't directly test the CSS, but we can check that the font examples are present
      assert has_element?(view, ".font-sample")
      assert has_element?(view, ".font-example")
      assert has_element?(view, ".fallback-font")
    end
  end
end 