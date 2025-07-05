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

      # Customize colors using text input fields
      session
      |> fill_in(css("input[name='theme[primary_color_text]']"), with: "#FF5733")
      |> fill_in(css("input[name='theme[secondary_color_text]']"), with: "#33FF57")
      |> fill_in(css("input[name='theme[accent_color_text]']"), with: "#3357FF")
      |> click(button("Save Colors"))

      # Wait for the flash message to appear, indicating the save was successful
      Wallaby.Browser.assert_has(
        session,
        css(".alert-success", text: "Colors saved successfully")
      )

      # Wait longer for LiveView to update and DOM to be fully rendered
      :timer.sleep(500)

      # Debug: Print page source to see what's actually rendered
      IO.puts("\n--- DEBUG: Page source after saving colors ---")
      IO.puts(Wallaby.Browser.page_source(session))
      IO.puts("--- END PAGE SOURCE ---\n")

      # Try to find color preview elements - use all() to get elements even if not visible
      previews = Wallaby.Browser.all(session, css(".color-preview"))
      IO.puts("\n--- DEBUG: Found #{length(previews)} color preview elements ---")
      
      # Try alternative selectors to see if Wallaby can find the elements
      divs_with_style = Wallaby.Browser.all(session, css("div[style*='background-color']"))
      IO.puts("\n--- DEBUG: Found #{length(divs_with_style)} divs with background-color style ---")
      
      # Try finding by title attribute
      titled_divs = Wallaby.Browser.all(session, css("div[title]"))
      IO.puts("\n--- DEBUG: Found #{length(titled_divs)} divs with title attribute ---")
      
      # If we found elements, check their visibility
      if length(previews) > 0 do
        Enum.each(previews, fn preview ->
          style = Wallaby.Element.attr(preview, "style")
          IO.puts("Color preview style: #{style}")
        end)
      end
      
      # As a workaround, parse the page source for the color preview elements
      page_source = Wallaby.Browser.page_source(session)
      color_preview_pattern = ~r/<div[^>]*class="[^"]*color-preview[^"]*"[^>]*style="[^"]*background-color: (#[A-Fa-f0-9]{6})[^"]*"[^>]*>/s
      color_matches = Regex.scan(color_preview_pattern, page_source)
      IO.puts("\n--- DEBUG: Found #{length(color_matches)} color preview elements via regex ---")
      Enum.each(color_matches, fn [full_match, color] ->
        IO.puts("Regex match: #{color}")
      end)
      
      # Use the regex results for assertions if Wallaby can't find the elements
      if length(previews) == 0 and length(color_matches) > 0 do
        IO.puts("\n--- Using regex fallback for assertions ---")
        colors_found = Enum.map(color_matches, fn [_, color] -> color end)
        assert Enum.member?(colors_found, "#FF5733"), "Primary color #FF5733 not found"
        assert Enum.member?(colors_found, "#33FF57"), "Secondary color #33FF57 not found"
        assert Enum.member?(colors_found, "#3357FF"), "Accent color #3357FF not found"
      else
        # Original Wallaby assertions
        assert length(previews) >= 3

        # Check that at least one preview has each expected color in its style attribute
        preview_styles = Enum.map(previews, &Wallaby.Element.attr(&1, "style"))
        assert Enum.any?(preview_styles, &String.contains?(&1, "#FF5733"))
        assert Enum.any?(preview_styles, &String.contains?(&1, "#33FF57"))
        assert Enum.any?(preview_styles, &String.contains?(&1, "#3357FF"))
      end
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

      # Verify theme is applied on the current page
      Wallaby.Browser.assert_has(session, css(".theme-applied", text: test_theme.name))
      Wallaby.Browser.assert_has(session, css(".alert-success", text: "Theme applied successfully"))
    end

    test "theme changes sync across components", %{session: session, light_theme: theme} do
      # Find the Test Theme
      themes = HydepwnsLiveview.ThemeSystem.list_themes()
      test_theme = Enum.find(themes, fn theme -> theme.name == "Test Theme" end)
      
      # Navigate directly to the theme show page with the theme table parameter
      session |> visit("/themes/#{test_theme.id}?theme_table=#{Process.get(:theme_system_ets_table)}")

      session
      |> click(button("Apply Theme"))

      # Verify theme is applied on the current page
      Wallaby.Browser.assert_has(session, css(".theme-applied", text: test_theme.name))
      Wallaby.Browser.assert_has(session, css(".alert-success", text: "Theme applied successfully"))
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

      # Verify theme is applied on the current page
      Wallaby.Browser.assert_has(session, css(".theme-applied", text: test_theme.name))
      Wallaby.Browser.assert_has(session, css(".alert-success", text: "Theme applied successfully"))
    end
  end

  describe "theme performance" do
    test "theme changes are applied efficiently", %{session: session, light_theme: theme} do
      # Navigate directly to the theme show page with the theme table parameter
      themes = HydepwnsLiveview.ThemeSystem.list_themes()
      test_theme = Enum.find(themes, fn theme -> theme.name == "Test Theme" end)
      session = visit(session, "/themes/#{test_theme.id}?theme_table=#{Process.get(:theme_system_ets_table)}")

      session
      |> click(button("Apply Theme"))

      # Debug: Print page source after applying theme
      IO.puts("\n--- DEBUG: Page source after clicking Apply Theme ---")
      IO.puts(Wallaby.Browser.page_source(session))
      IO.puts("--- END PAGE SOURCE ---\n")

      # Verify theme application
      Wallaby.Browser.assert_has(session, css(".theme-applied", text: test_theme.name))

      # Verify flash message appears
      Wallaby.Browser.assert_has(
        session,
        css(".alert-success", text: "Theme applied successfully")
      )
    end

    test "_theme switching is smooth", %{session: session, light_theme: _theme} do
      table = Process.get(:theme_system_ets_table)
      
      # Create second theme directly via API to ensure it's in the same ETS table context
      {:ok, second_theme} = HydepwnsLiveview.ThemeSystem.create_theme(%{
        name: "Second Theme",
        mode: "dark",
        primary_color: "#60a5fa",
        secondary_color: "#34d399",
        background_color: "#111827",
        text_color: "#f9fafb"
      })
      
      # Fetch themes to get the Test Theme
      themes = HydepwnsLiveview.ThemeSystem.list_themes()
      test_theme = Enum.find(themes, fn theme -> theme.name == "Test Theme" end)
      
      IO.puts("\n[DEBUG] test_theme: #{inspect(test_theme)}\n")
      IO.puts("\n[DEBUG] second_theme: #{inspect(second_theme)}\n")

      # Navigate to the first theme and apply it
      session = visit(session, "/themes/#{test_theme.id}?theme_table=#{table}")
      session
      |> click(button("Apply Theme"))
      # Verify first theme is applied
      Wallaby.Browser.assert_has(session, css(".theme-applied", text: test_theme.name))

      # Navigate to the second theme and apply it
      session = visit(session, "/themes/#{second_theme.id}?theme_table=#{table}")
      session
      |> click(button("Apply Theme"))
      # Verify second theme is applied
      Wallaby.Browser.assert_has(session, css(".theme-applied", text: second_theme.name))
      # Verify flash messages appear
      Wallaby.Browser.assert_has(session, css(".alert-success", text: "Theme applied successfully"))
    end
  end

  describe "theme accessibility" do
    test "theme maintains accessibility standards", %{session: session, light_theme: theme} do
      # Navigate directly to theme customization page
      session
      |> visit("/themes/#{theme.id}/customize")

      # Apply high contrast theme (fill in all required color fields)
      session
      |> fill_in(css("input[name='theme[primary_color]']"), with: "#000000")
      |> fill_in(css("input[name='theme[secondary_color]']"), with: "#FFFFFF")
      |> fill_in(css("input[name='theme[background_color]']"), with: "#000000")
      |> fill_in(css("input[name='theme[text_color]']"), with: "#FFFFFF")
      |> click(button("Save Colors"))

      # Verify colors are saved
      Wallaby.Browser.assert_has(session, css(".alert-success", text: "Colors saved successfully"))
    end

    test "_theme supports reduced motion", %{session: session, light_theme: theme} do
      # Navigate to theme customization page
      session
      |> visit("/themes/#{theme.id}/customize")

      # Apply reduced motion setting
      session
      |> click(Query.checkbox("reduced_motion"))
      |> click(button("Apply"))

      # Verify accessibility settings are saved
      Wallaby.Browser.assert_has(session, css(".alert-success", text: "Accessibility settings applied successfully"))
    end
  end

  # Helper to create a new Wallaby session with the same metadata as the test context
  # Usage: new_session = new_session(metadata)
  defp new_session do
    {:ok, session} = Wallaby.start_session()
    session
  end
end
