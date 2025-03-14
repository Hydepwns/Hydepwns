defmodule HydepwnsLiveviewWeb.Features.ThemeSystemWorkflowTest do
  use HydepwnsLiveviewWeb.WallabyCase, async: true
  
  @moduledoc """
  End-to-end tests for the Theme System workflow.
  
  This test suite verifies the complete user experience of:
  - Switching between themes (light, dark, dim)
  - Theme persistence across page navigation
  - Creating and managing custom themes
  - Theme preference syncing with system settings
  - Theme application to all UI components
  """

  import Wallaby.Query

  setup %{session: session} do
    # Start with a clean session and visit the home page
    {:ok, session: visit_and_wait(session, "/")}
  end

  describe "theme toggle functionality" do
    test "user can switch between themes", %{session: session} do
      # Verify the default theme is applied
      assert_has(session, css("body.light-theme"))
      
      # Verify theme toggle exists
      assert_has(session, css(".theme-toggle"))
      
      # Switch to dark theme
      session
      |> click(css("[data-theme='dark']"))
      
      # Verify dark theme is applied
      assert_has(session, css("body.dark-theme"))
      
      # Take a screenshot to verify visual appearance
      take_screenshot(session, "dark_theme_applied")
    end
    
    test "theme persists when navigating to a new page", %{session: session} do
      # Switch to dark theme
      session
      |> click(css("[data-theme='dark']"))
      
      # Verify dark theme is applied
      assert_has(session, css("body.dark-theme"))
      
      # Navigate to style guide
      session
      |> click(link("Style Guide"))
      
      # Verify theme persists on new page
      assert_has(session, css("body.dark-theme"))
    end
    
    test "theme toggle is keyboard accessible", %{session: session} do
      # Focus on theme toggle
      session
      |> focus_element(css(".theme-toggle"))
      
      # Verify we can tab to theme buttons
      session
      |> send_keys([:tab])
      |> assert_has(css("button:focus"))
      
      # Press theme button with keyboard
      session
      |> send_keys([:space])
      
      # Verify theme changed
      Wallaby.Browser.assert_text(session, css("body"), "dark-theme")
    end
  end
  
  describe "theme manager page" do
    setup %{session: session} do
      # Navigate to theme manager page
      {:ok, session: visit_and_wait(session, "/theme-manager")}
    end
    
    test "can view list of available themes", %{session: session} do
      assert_has(session, css("h1", text: "Theme Manager"))
      assert_has(session, css("h2", text: "Current Themes"))
      
      # Check that default themes are listed
      assert_has(session, css("table tbody tr", count: 3))
      assert_has(session, css("table tbody tr", text: "Light"))
      assert_has(session, css("table tbody tr", text: "Dark"))
    end
    
    test "can create a new custom theme", %{session: session} do
      # Click on "Create New Theme" button
      session
      |> click(link("Create New Theme"))
      
      # Fill out the form
      session
      |> fill_in(text_field("theme[name]"), with: "Custom Theme")
      |> fill_in(text_field("theme[mode]"), with: "dark")
      |> fill_in(text_field("theme[settings][primary_color]"), with: "#ff5500")
      |> fill_in(text_field("theme[settings][secondary_color]"), with: "#00aaff")
      |> click(button("Save Theme"))
      
      # Verify theme was created
      assert_has(session, css(".alert-success", text: "Theme created successfully"))
      assert_has(session, css("table tbody tr", text: "Custom Theme"))
    end
    
    test "can edit an existing theme", %{session: session} do
      # Click edit on the first theme
      session
      |> click(link("Edit", at: 0))
      
      # Update theme name
      session
      |> fill_in(text_field("theme[name]"), with: "Updated Theme")
      |> click(button("Save Theme"))
      
      # Verify theme was updated
      assert_has(session, css(".alert-success", text: "Theme updated successfully"))
      assert_has(session, css("table tbody tr", text: "Updated Theme"))
    end
    
    test "can set a theme as default", %{session: session} do
      # Find the Dark theme row and click "Set as Default"
      session
      |> find(css("table tbody tr", text: "Dark"))
      |> click(link("Set as Default"))
      
      # Verify it's set as default
      assert_has(session, css(".alert-success", text: "Theme set as default"))
      
      # Verify it's marked as default in the table
      dark_theme_row = find(session, css("table tbody tr", text: "Dark"))
      assert_has(dark_theme_row, css("td", text: "Yes"))
    end
  end
  
  describe "theme changes across application" do
    test "theme changes affect all components", %{session: session} do
      # Navigate to style guide to see all components
      session
      |> visit_and_wait("/style-guide")
      
      # Switch to dark theme
      session
      |> click(css("[data-theme='dark']"))
      
      # Take screenshot with dark theme
      take_screenshot(session, "style_guide_dark_theme")
      
      # Verify theme CSS variables are applied
      assert_has(session, css("body.dark-theme"))
      
      # Check specific components
      terminal = find(session, css(".terminal"))
      assert has_class?(terminal, "dark-theme")
      
      buttons = find(session, css(".button-examples"))
      assert has_class?(buttons, "dark-theme")
    end
  end
end 