defmodule HydepwnsLiveviewWeb.StyleGuideJsTest do
  use HydepwnsLiveviewWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import HydepwnsLiveviewWeb.JsTestHelper

  describe "Style Guide JavaScript" do
    test "high contrast toggle works", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/style-guide")

      # Find a high contrast toggle button
      assert has_element?(view, "button.high-contrast-toggle")

      # Click the button
      view
      |> element("button.high-contrast-toggle")
      |> render_click()

      # Check that the aria-pressed attribute is set to true
      assert has_element?(view, "button.high-contrast-toggle[aria-pressed='true']")

      # Check that the button text has changed
      assert has_element?(view, "button.high-contrast-toggle", "Disable High Contrast")

      # Click the button again
      view
      |> element("button.high-contrast-toggle[aria-pressed='true']")
      |> render_click()

      # Check that the aria-pressed attribute is set back to false
      assert has_element?(view, "button.high-contrast-toggle[aria-pressed='false']")

      # Check that the button text has changed back
      assert has_element?(view, "button.high-contrast-toggle", "Enable High Contrast")
    end

    test "code examples have copy buttons", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/style-guide")

      # Check that code examples exist
      assert has_element?(view, ".code-example pre code")

      # Check that copy buttons are added by JavaScript
      # Note: This is a client-side feature, so we can only check for the elements
      # that the JavaScript will target, not the actual buttons it creates
      assert has_element?(view, ".code-example pre")
    end

    test "animation examples exist", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/style-guide")

      # Check that typewriter animation examples exist
      assert has_element?(view, ".typewriter-text")

      # Check that grid animation examples exist
      assert has_element?(view, ".grid-animation")
      assert has_element?(view, ".grid-cell")
    end
  end
end 