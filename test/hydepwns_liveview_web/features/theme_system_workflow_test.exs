defmodule HydepwnsLiveviewWeb.Features.ThemeSystemWorkflowTest do
  import Wallaby.Browser

  use HydepwnsLiveviewWeb.WallabyCase, async: false

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

  import Wallaby.Query
  alias HydepwnsLiveview.TestSupport.ThemeFixtures

  setup %{session: session} do
    # Create test theme
    theme =
      ThemeFixtures.create_test_theme(%{
        name: "Test Theme",
        type: "light",
        primary_color: "#4A90E2",
        secondary_color: "#50E3C2",
        font_family: "monospace",
        font_size: "14px"
      })

    # Start session and visit the theme dashboard
    {:ok, session: visit_and_wait(session, "/themes"), theme: theme}
  end

  describe "theme management and application" do
    test "theme can be created and applied", %{session: session, theme: theme} do
      import Wallaby.Browser
      import Wallaby.Query
      # Navigate to theme creation
      session
      |> click(link("Create Theme"))

      # Create new theme
      session
      |> fill_in(text_field("theme[name]"), with: "Custom Theme")
      |> fill_in(text_field("theme[primary_color]"), with: "#FF5733")
      |> fill_in(text_field("theme[secondary_color]"), with: "#33FF57")
      |> click(Query.select("theme[type]"))
      |> click(Query.option("dark"))
      |> click(button("Create Theme"))

      # Verify theme creation
      assert_has(session, css(".alert-success", text: "Theme created successfully"))

      # Apply the theme
      session
      |> click(button("Apply Theme"))

      # Verify theme application
      assert_has(session, css(".theme-applied", text: "Custom Theme"))
      assert_has(session, css(".theme-type", text: "dark"))
    end

    test "theme can be edited and updated", %{session: session, theme: theme} do
      # Navigate to theme
      session
      |> click(link(theme.name))
      |> click(link("Edit"))

      # Update theme
      session
      |> fill_in(text_field("theme[primary_color]"), with: "#FF0000")
      |> fill_in(text_field("theme[secondary_color]"), with: "#00FF00")
      |> click(button("Update Theme"))

      # Verify theme update
      assert_has(session, css(".alert-success", text: "Theme updated successfully"))
      assert_has(session, css(".theme-color", style: "background-color: #FF0000"))
      assert_has(session, css(".theme-color", style: "background-color: #00FF00"))
    end

    test "theme can be deleted", %{session: session, theme: theme} do
      # Navigate to theme
      session
      |> click(link(theme.name))
      |> click(button("Delete Theme"))
      |> click(button("Confirm Delete"))

      # Verify theme deletion
      assert_has(session, css(".alert-success", text: "Theme deleted successfully"))
      refute_has(session, css(".theme-item", text: theme.name))
    end
  end

  describe "theme customization" do
    test "theme colors can be customized", %{session: session, theme: theme} do
      # Navigate to theme customization
      session
      |> click(link(theme.name))
      |> click(link("Customize"))

      # Customize colors
      session
      |> fill_in(text_field("theme[primary_color]"), with: "#FF5733")
      |> fill_in(text_field("theme[secondary_color]"), with: "#33FF57")
      |> fill_in(text_field("theme[accent_color]"), with: "#3357FF")
      |> click(button("Save Colors"))

      # Verify color customization
      assert_has(session, css(".color-preview", style: "background-color: #FF5733"))
      assert_has(session, css(".color-preview", style: "background-color: #33FF57"))
      assert_has(session, css(".color-preview", style: "background-color: #3357FF"))
    end

    test "theme typography can be customized", %{session: session, theme: theme} do
      # Navigate to theme customization
      session
      |> click(link(theme.name))
      |> click(link("Customize"))

      # Customize typography
      session
      |> fill_in(text_field("theme[font_family]"), with: "Helvetica")
      |> fill_in(text_field("theme[font_size]"), with: "16px")
      |> fill_in(text_field("theme[line_height]"), with: "1.5")
      |> click(button("Save Typography"))

      # Verify typography customization
      assert_has(session, css(".typography-preview", style: "font-family: Helvetica"))
      assert_has(session, css(".typography-preview", style: "font-size: 16px"))
      assert_has(session, css(".typography-preview", style: "line-height: 1.5"))
    end

    test "theme spacing can be customized", %{session: session, theme: theme} do
      # Navigate to theme customization
      session
      |> click(link(theme.name))
      |> click(link("Customize"))

      # Customize spacing
      session
      |> fill_in(text_field("theme[spacing_unit]"), with: "8px")
      |> fill_in(text_field("theme[container_padding]"), with: "24px")
      |> fill_in(text_field("theme[section_margin]"), with: "32px")
      |> click(button("Save Spacing"))

      # Verify spacing customization
      assert_has(session, css(".spacing-preview", style: "padding: 8px"))
      assert_has(session, css(".container-preview", style: "padding: 24px"))
      assert_has(session, css(".section-preview", style: "margin: 32px"))
    end
  end

  describe "theme persistence and synchronization" do
    test "theme preferences are persisted", %{session: session, theme: theme} do
      # Apply theme
      session
      |> click(link(theme.name))
      |> click(button("Apply Theme"))

      # Reload page
      session
      |> visit("/")

      # Verify theme persistence
      assert_has(session, css(".theme-applied", text: theme.name))
      assert_has(session, css(".theme-type", text: theme.type))
    end

    test "theme changes sync across components", %{session: session, theme: theme} do
      # Apply theme
      session
      |> click(link(theme.name))
      |> click(button("Apply Theme"))

      # Navigate to different components
      components = ["Terminal", "Editor", "Dashboard"]

      for component <- components do
        session
        |> click(link(component))
        |> assert_has(css(".theme-applied", text: theme.name))
      end
    end

    test "theme changes persist across sessions", %{
      session: session,
      theme: theme,
      metadata: metadata
    } do
      # Apply theme
      session
      |> click(link(theme.name))
      |> click(button("Apply Theme"))

      # Start new session
      new_session = new_session(metadata)

      new_session
      |> visit("/")

      # Verify theme persistence
      assert_has(new_session, css(".theme-applied", text: theme.name))
    end
  end

  describe "theme performance" do
    test "theme changes are applied efficiently", %{session: session, theme: theme} do
      # Start performance measurement
      session
      |> click(link(theme.name))
      |> click(button("Apply Theme"))

      # Verify quick theme application
      assert_has(session, css(".theme-applied", text: theme.name))
      assert_has(session, css(".performance-metric", text: "Theme applied in < 100ms"))
    end

    test "theme switching is smooth", %{session: session, theme: theme} do
      # Create second theme
      session
      |> click(link("Create Theme"))
      |> fill_in(text_field("theme[name]"), with: "Second Theme")
      |> click(button("Create Theme"))

      # Switch between themes rapidly
      for _ <- 1..5 do
        session
        |> click(link(theme.name))
        |> click(button("Apply Theme"))
        |> click(link("Second Theme"))
        |> click(button("Apply Theme"))
      end

      # Verify smooth transitions
      assert_has(session, css(".theme-transition", text: "smooth"))
      assert_has(session, css(".performance-metric", text: "No flickering"))
    end
  end

  describe "theme accessibility" do
    test "theme maintains accessibility standards", %{session: session, theme: theme} do
      # Navigate to theme customization
      session
      |> click(link(theme.name))
      |> click(link("Customize"))

      # Apply high contrast theme
      session
      |> fill_in(text_field("theme[primary_color]"), with: "#000000")
      |> fill_in(text_field("theme[secondary_color]"), with: "#FFFFFF")
      |> click(button("Save Colors"))

      # Verify contrast ratios
      assert_has(session, css(".contrast-ratio", text: "4.5:1"))
      assert_has(session, css(".accessibility-status", text: "WCAG 2.1 AA compliant"))
    end

    test "theme supports reduced motion", %{session: session, theme: theme} do
      import Wallaby.Browser
      import Wallaby.Query
      # Enable reduced motion
      session
      |> click(link(theme.name))
      |> click(button("Accessibility Settings"))
      |> click(Query.checkbox("reduced_motion"))
      |> click(button("Apply"))

      # Verify reduced motion
      assert_has(session, css(".motion-reduced"))
      assert_has(session, css(".transition-disabled"))
    end
  end

  # Helper to create a new Wallaby session with the same metadata as the test context
  # Usage: new_session = new_session(metadata)
  defp new_session(metadata) do
    {:ok, session} = Wallaby.start_session(metadata: metadata)
    session
  end
end
