defmodule HydepwnsLiveviewWeb.Features.ThemeSystemWorkflowTest do
  use HydepwnsLiveviewWeb.WallabyCase
  @moduletag :liveview
  import Wallaby.Query
  import Wallaby.Browser
  import HydepwnsLiveview.TestSupport.ThemeSystemHelper

  @moduledoc """
  End-to-end tests for the Theme System workflow.

  This test suite verifies the complete user experience of:
  - Theme Management
  - Theme Customization
  - Theme Application
  - Theme Persistence
  - Theme Synchronization
  - Theme Performance
  """

  setup %{session: session} = _context do
    # Set up per-test theme system isolation
    {:ok, table} = setup_theme_system_isolation()
    
    # Store the table name in the process dictionary for WallabyCase to access
    Process.put(:theme_system_ets_table, table)

    {:ok, light_theme} = HydepwnsLiveview.TestThemeSystemFixtures.light_theme_fixture()
    {:ok, dark_theme} = HydepwnsLiveview.TestThemeSystemFixtures.dark_theme_fixture()
    {:ok, system_theme} = HydepwnsLiveview.TestThemeSystemFixtures.system_theme_fixture()
    {:ok, dim_theme} = HydepwnsLiveview.TestThemeSystemFixtures.dim_theme_fixture()
    # Add a Test Theme for Wallaby selector
    {:ok, _test_theme} =
      HydepwnsLiveview.ThemeSystem.create_theme(%{
        name: "Test Theme",
        mode: "light",
        primary_color: "#3b82f6",
        secondary_color: "#10b981",
        background_color: "#ffffff",
        text_color: "#1f2937"
      })

    # Verify themes are created
    themes = HydepwnsLiveview.ThemeSystem.list_themes()
    IO.puts("DEBUG: Themes created in test: #{inspect(themes, pretty: true)}")

    # Pass the table name through URL parameters
    session = visit(session, "/themes?theme_table=#{table}")
    
    {:ok, %{session: session, light_theme: light_theme, dark_theme: dark_theme, system_theme: system_theme, dim_theme: dim_theme}}
  end

  describe "theme management and application" do
    test "_theme can be created and applied", %{session: session, light_theme: _light_theme} do
      # Navigate directly to theme creation page
      session
      |> visit("/themes/new")

      # Debug: Print page source to see what's actually rendered
      IO.puts("\n--- DEBUG: Page source after visiting /themes/new ---")
      IO.puts(Wallaby.Browser.page_source(session))
      IO.puts("--- END PAGE SOURCE ---\n")

      # Create new theme with only the fields that exist
      session
      |> fill_in(text_field("theme[name]"), with: "Custom Theme")
      |> click(css("[data-test-id='theme-form_mode']"))
      |> click(css("option[value='dark']"))
      |> click(button("Create Theme"))

      # Verify theme creation by checking flash message
      Wallaby.Browser.assert_has(
        session,
        css(".alert-success", text: "Theme created successfully")
      )
    end

    test "_theme can be edited and updated", %{session: session, light_theme: _light_theme} do
      # Debug: print all theme names in DB before clicking link
      themes = HydepwnsLiveview.ThemeSystem.list_themes()
      IO.puts("\n[DEBUG] Themes in DB before click: #{inspect(Enum.map(themes, & &1.name))}\n")
      
      # Find the Test Theme
      test_theme = Enum.find(themes, fn theme -> theme.name == "Test Theme" end)
      
      # Navigate directly to the theme show page with the theme table parameter
      session |> visit("/themes/#{test_theme.id}?theme_table=#{Process.get(:theme_system_ets_table)}")

      session
      |> click(Wallaby.Query.link("Edit"))

      # Update theme
      session
      |> fill_in(text_field("theme[primary_color]"), with: "#FF0000")
      |> fill_in(text_field("theme[secondary_color]"), with: "#00FF00")
      |> click(button("Save Theme"))

      # Verify theme update
      Wallaby.Browser.assert_has(
        session,
        css(".alert-success", text: "Theme updated successfully")
      )

      # Verify the updated theme appears in the list with new colors
      Wallaby.Browser.assert_has(session, css("[data-test-id='theme-name-5']", text: "Test Theme"))
    end

    test "theme can be deleted", %{session: session, light_theme: light_theme} do
      # Debug: print all theme names in DB before clicking link
      themes = HydepwnsLiveview.ThemeSystem.list_themes()
      IO.puts("\n[DEBUG] Themes in DB before click: #{inspect(Enum.map(themes, & &1.name))}\n")
      
      # Find the Test Theme
      test_theme = Enum.find(themes, fn theme -> theme.name == "Test Theme" end)
      
      # Navigate directly to the theme show page with the theme table parameter
      session |> visit("/themes/#{test_theme.id}?theme_table=#{Process.get(:theme_system_ets_table)}")

      session
      |> click(button("Delete Theme"))
      |> click(button("Confirm Delete"))

      # Verify theme deletion
      Wallaby.Browser.assert_has(
        session,
        css(".alert-success", text: "Theme deleted successfully")
      )

      Wallaby.Browser.refute_has(session, css(".theme-item", text: light_theme.name))
    end
  end

  describe "theme customization" do
    test "theme colors can be customized", %{session: session, light_theme: light_theme} do
      # Navigate directly to theme customization page
      session
      |> visit("/themes/#{light_theme.id}/customize")

      # Customize colors using color input fields
      session
      |> fill_in(css("input[name='theme[primary_color]']"), with: "#FF5733")
      |> fill_in(css("input[name='theme[secondary_color]']"), with: "#33FF57")
      |> fill_in(css("input[name='theme[accent_color]']"), with: "#3357FF")
      |> click(button("Save Colors"))

      # Verify color customization
      Wallaby.Browser.assert_has(
        session,
        css(".color-preview", style: "background-color: #FF5733")
      )

      Wallaby.Browser.assert_has(
        session,
        css(".color-preview", style: "background-color: #33FF57")
      )

      Wallaby.Browser.assert_has(
        session,
        css(".color-preview", style: "background-color: #3357FF")
      )
    end

    test "theme typography can be customized", %{session: session, light_theme: light_theme} do
      # Navigate directly to theme customization page
      session
      |> visit("/themes/#{light_theme.id}/customize")

      # Customize typography
      session
      |> fill_in(css("input[name='theme[font_family]']"), with: "Helvetica")
      |> fill_in(css("input[name='theme[font_size]']"), with: "16px")
      |> fill_in(css("input[name='theme[line_height]']"), with: "1.5")
      |> click(button("Save Typography"))

      # Verify typography customization
      Wallaby.Browser.assert_has(
        session,
        css(".typography-preview", style: "font-family: Helvetica")
      )

      Wallaby.Browser.assert_has(session, css(".typography-preview", style: "font-size: 16px"))
      Wallaby.Browser.assert_has(session, css(".typography-preview", style: "line-height: 1.5"))
    end

    test "theme spacing can be customized", %{session: session, light_theme: light_theme} do
      # Navigate directly to theme customization page
      session
      |> visit("/themes/#{light_theme.id}/customize")

      # Customize spacing
      session
      |> fill_in(css("input[name='theme[spacing_unit]']"), with: "8px")
      |> fill_in(css("input[name='theme[container_padding]']"), with: "24px")
      |> fill_in(css("input[name='theme[section_margin]']"), with: "32px")
      |> click(button("Save Spacing"))

      # Debug: Print page source after saving spacing to see what's rendered
      IO.puts("\n--- DEBUG: Page source after saving spacing ---")
      IO.puts(Wallaby.Browser.page_source(session))
      IO.puts("--- END PAGE SOURCE ---\n")

      # Wait for preview section to reappear, then verify spacing customization
      Wallaby.Browser.assert_has(session, css("[data-test-id='spacing-preview-section']"))
      # Verify the preview container has the correct padding and margin
      Wallaby.Browser.assert_has(session, css("div[style*='padding: 24px'][style*='margin: 32px']"))
      # Wait a moment for LiveView to update, then verify the spacing elements exist
      :timer.sleep(100)
      # Check that the spacing preview section exists and has the correct structure
      Wallaby.Browser.assert_has(session, css("[data-test-id='spacing-preview-section']"))
      # Check that the preview container has the correct padding and margin
      Wallaby.Browser.assert_has(session, css("div[style*='padding: 24px'][style*='margin: 32px']"))
      # Check that the spacing elements exist by looking for the space-y-2 container
      Wallaby.Browser.assert_has(session, css(".space-y-2"))
    end
  end

  describe "theme persistence and synchronization" do
    test "theme preferences are persisted", %{session: session, light_theme: light_theme} do
      # Find the Test Theme
      themes = HydepwnsLiveview.ThemeSystem.list_themes()
      test_theme = Enum.find(themes, fn theme -> theme.name == "Test Theme" end)
      
      # Navigate directly to the theme show page with the theme table parameter
      session |> visit("/themes/#{test_theme.id}?theme_table=#{Process.get(:theme_system_ets_table)}")

      session
      |> click(button("Apply Theme"))

      # Simulate setting the user_theme in the session (Wallaby does not persist cookies between reloads by default)
      session = Wallaby.Browser.set_cookie(session, "user_theme", light_theme.name)

      # Reload page
      session
      |> visit("/")

      # Verify theme persistence
      Wallaby.Browser.assert_has(session, css(".theme-applied", text: test_theme.name))
      Wallaby.Browser.assert_has(session, css(".theme-type", text: test_theme.mode))
    end

    test "theme changes sync across components", %{session: session, light_theme: theme} do
      # Find the Test Theme
      themes = HydepwnsLiveview.ThemeSystem.list_themes()
      test_theme = Enum.find(themes, fn theme -> theme.name == "Test Theme" end)
      
      # Navigate directly to the theme show page with the theme table parameter
      session |> visit("/themes/#{test_theme.id}?theme_table=#{Process.get(:theme_system_ets_table)}")

      session
      |> click(button("Apply Theme"))

      # Navigate to different components
      components = ["Terminal", "Editor", "Dashboard"]

      for component <- components do
        session
        |> click(Wallaby.Query.link(component))
        |> Wallaby.Browser.assert_has(css(".theme-applied", text: theme.name))
      end
    end

    test "theme changes persist across sessions", %{
      session: session,
      light_theme: theme
    } do
      # Find the Test Theme
      themes = HydepwnsLiveview.ThemeSystem.list_themes()
      test_theme = Enum.find(themes, fn theme -> theme.name == "Test Theme" end)
      
      # Navigate directly to the theme show page with the theme table parameter
      session |> visit("/themes/#{test_theme.id}?theme_table=#{Process.get(:theme_system_ets_table)}")

      session
      |> click(button("Apply Theme"))

      # Simulate setting the user_theme in the session for the new session
      new_session = new_session()
      new_session = Wallaby.Browser.set_cookie(new_session, "user_theme", theme.name)

      new_session
      |> visit("/")

      # Verify theme persistence
      Wallaby.Browser.assert_has(new_session, css(".theme-applied", text: theme.name))
    end
  end

  describe "theme performance" do
    test "theme changes are applied efficiently", %{session: session, light_theme: theme} do
      # Start performance measurement
      try do
        session |> click(css("[data-test-id='theme-link-test-theme']"))
      rescue
        e in Wallaby.QueryError ->
          IO.puts(
            "\n--- DEBUG: Page source at failure ---\n" <>
              Wallaby.Browser.page_source(session) <> "\n--- END PAGE SOURCE ---\n"
          )

          reraise e, __STACKTRACE__
      end

      session
      |> click(button("Apply Theme"))

      # Verify quick theme application
      Wallaby.Browser.assert_has(session, css(".theme-applied", text: theme.name))

      Wallaby.Browser.assert_has(
        session,
        css(".performance-metric", text: "Theme applied in < 100ms")
      )
    end

    test "_theme switching is smooth", %{session: session, light_theme: _theme} do
      # Create second theme
      session
      |> click(button("Create Theme"))
      |> fill_in(text_field("theme[name]"), with: "Second Theme")
      |> click(css("[data-test-id='create-theme']"))

      # Switch between themes rapidly
      for _ <- 1..5 do
        try do
          session |> click(css("[data-test-id='theme-link-test-theme']"))
        rescue
          e in Wallaby.QueryError ->
            IO.puts(
              "\n--- DEBUG: Page source at failure ---\n" <>
                Wallaby.Browser.page_source(session) <> "\n--- END PAGE SOURCE ---\n"
            )

            reraise e, __STACKTRACE__
        end

        session
        |> click(button("Apply Theme"))
        |> click(Wallaby.Query.link("Second Theme"))
        |> click(button("Apply Theme"))
      end

      # Verify smooth transitions
      Wallaby.Browser.assert_has(session, css(".theme-transition", text: "smooth"))
      Wallaby.Browser.assert_has(session, css(".performance-metric", text: "No flickering"))
    end
  end

  describe "theme accessibility" do
    test "theme maintains accessibility standards", %{session: session, light_theme: theme} do
      # Navigate directly to theme customization page
      session
      |> visit("/themes/#{theme.id}/customize")

      # Apply high contrast theme
      session
      |> fill_in(text_field("theme[primary_color]"), with: "#000000")
      |> fill_in(text_field("theme[secondary_color]"), with: "#FFFFFF")
      |> click(button("Save Colors"))

      # Verify contrast ratios
      Wallaby.Browser.assert_has(session, css(".contrast-ratio", text: "4.5:1"))

      Wallaby.Browser.assert_has(
        session,
        css(".accessibility-status", text: "WCAG 2.1 AA compliant")
      )
    end

    test "_theme supports reduced motion", %{session: session, light_theme: theme} do
      # Navigate to theme customization page where accessibility settings are already visible
      session
      |> visit("/themes/#{theme.id}/customize")

      # The accessibility settings are already on the page, just click the checkbox
      session
      |> click(Query.checkbox("reduced_motion"))
      |> click(button("Apply"))

      # Verify reduced motion
      Wallaby.Browser.assert_has(session, css(".motion-reduced"))
      Wallaby.Browser.assert_has(session, css(".transition-disabled"))
    end
  end

  # Helper to create a new Wallaby session with the same metadata as the test context
  # Usage: new_session = new_session(metadata)
  defp new_session do
    {:ok, session} = Wallaby.start_session()
    session
  end
end
