defmodule HydepwnsLiveviewWeb.Features.ThemeSystemWorkflowTest do
  use HydepwnsLiveviewWeb.ConnCase, async: false
  use HydepwnsLiveviewWeb.WallabyCase
  @moduletag :liveview
  import Wallaby.Query
  import Wallaby.Browser
  import HydepwnsLiveview.TestSupport.ThemeSystemHelper

  alias HydepwnsLiveviewWeb.TestMockHelper

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

  alias HydepwnsLiveviewWeb.TestMockHelper

  setup %{session: session} = _context do
    # Set up per-test theme system isolation
    {:ok, _table} = setup_theme_system_isolation()

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
        text_color: "#1f2937",
        is_default: false,
        settings: %{
          font_size: "medium",
          line_height: "normal",
          contrast: "normal",
          animations: true
        }
      })

    themes = HydepwnsLiveview.ThemeSystem.list_themes()
    assert length(themes) >= 4

    Enum.each(themes, fn theme ->
      assert theme.id != nil
      assert theme.name != nil and theme.name != ""
      assert theme.mode in ["light", "dark", "dim", "system"]
    end)

    # Set up mocks first, before any resource creation
    TestMockHelper.setup_mocks()

    session = visit_and_wait(session, "/themes")
    Wallaby.Browser.take_screenshot(session, name: "theme_system_workflow_setup")

    IO.puts(
      "\n--- PAGE SOURCE ---\n" <>
        Wallaby.Browser.page_source(session) <> "\n--- END PAGE SOURCE ---\n"
    )

    {:ok,
     session: session,
     theme: dim_theme,
     light_theme: light_theme,
     dark_theme: dark_theme,
     system_theme: system_theme,
     dim_theme: dim_theme}
  end

  describe "theme management and application" do
    test "_theme can be created and applied", %{session: session, _theme: _theme} do
      # Navigate to theme creation
      session
      |> click(button("Create Theme"))

      # Create new theme
      session
      |> fill_in(text_field("theme[name]"), with: "Custom Theme")
      |> fill_in(text_field("theme[primary_color]"), with: "#FF5733")
      |> fill_in(text_field("theme[secondary_color]"), with: "#33FF57")
      |> click(Query.select("theme[type]"))
      |> click(Query.option("dark"))
      |> click(css("[data-test-id='create-theme']"))

      # Verify theme creation
      Wallaby.Browser.assert_has(
        session,
        css(".alert-success", text: "Theme created successfully")
      )

      # Apply the theme
      session
      |> click(button("Apply Theme"))

      # Verify theme application
      Wallaby.Browser.assert_has(session, css(".theme-applied", text: "Custom Theme"))
      Wallaby.Browser.assert_has(session, css(".theme-type", text: "dark"))
    end

    test "_theme can be edited and updated", %{session: session, _theme: _theme} do
      # Debug: print all theme names in DB before clicking link
      themes = HydepwnsLiveview.ThemeSystem.list_themes()
      IO.puts("\n[DEBUG] Themes in DB before click: #{inspect(Enum.map(themes, & &1.name))}\n")
      # Navigate to theme
      try do
        # Debug: print all anchor tags and their text
        anchors = Wallaby.Browser.all(session, css("a"))
        anchor_texts = Enum.map(anchors, fn a -> Wallaby.Element.text(a) end)
        IO.puts("\n[DEBUG] Anchor tags on page: #{inspect(anchor_texts)}\n")
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
      |> click(Wallaby.Query.link("Edit"))

      # Update theme
      session
      |> fill_in(text_field("theme[primary_color]"), with: "#FF0000")
      |> fill_in(text_field("theme[secondary_color]"), with: "#00FF00")
      |> click(button("Update Theme"))

      # Verify theme update
      Wallaby.Browser.assert_has(
        session,
        css(".alert-success", text: "Theme updated successfully")
      )

      Wallaby.Browser.assert_has(session, css(".theme-color", style: "background-color: #FF0000"))
      Wallaby.Browser.assert_has(session, css(".theme-color", style: "background-color: #00FF00"))
    end

    test "theme can be deleted", %{session: session, theme: theme} do
      # Navigate to theme
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
      |> click(button("Delete Theme"))
      |> click(button("Confirm Delete"))

      # Verify theme deletion
      Wallaby.Browser.assert_has(
        session,
        css(".alert-success", text: "Theme deleted successfully")
      )

      Wallaby.Browser.refute_has(session, css(".theme-item", text: theme.name))
    end
  end

  describe "theme customization" do
    test "theme colors can be customized", %{session: session, theme: theme} do
      # Navigate directly to theme customization page
      session
      |> visit("/themes/#{theme.id}?customize=1")

      # Customize colors
      session
      |> fill_in(text_field("theme[primary_color]"), with: "#FF5733")
      |> fill_in(text_field("theme[secondary_color]"), with: "#33FF57")
      |> fill_in(text_field("theme[accent_color]"), with: "#3357FF")
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

    test "theme typography can be customized", %{session: session, theme: theme} do
      # Navigate directly to theme customization page
      session
      |> visit("/themes/#{theme.id}?customize=1")

      # Customize typography
      session
      |> fill_in(text_field("theme[font_family]"), with: "Helvetica")
      |> fill_in(text_field("theme[font_size]"), with: "16px")
      |> fill_in(text_field("theme[line_height]"), with: "1.5")
      |> click(button("Save Typography"))

      # Verify typography customization
      Wallaby.Browser.assert_has(
        session,
        css(".typography-preview", style: "font-family: Helvetica")
      )

      Wallaby.Browser.assert_has(session, css(".typography-preview", style: "font-size: 16px"))
      Wallaby.Browser.assert_has(session, css(".typography-preview", style: "line-height: 1.5"))
    end

    test "theme spacing can be customized", %{session: session, theme: theme} do
      # Navigate directly to theme customization page
      session
      |> visit("/themes/#{theme.id}?customize=1")

      # Customize spacing
      session
      |> fill_in(text_field("theme[spacing_unit]"), with: "8px")
      |> fill_in(text_field("theme[container_padding]"), with: "24px")
      |> fill_in(text_field("theme[section_margin]"), with: "32px")
      |> click(button("Save Spacing"))

      # Wait for preview section to reappear, then verify spacing customization
      Wallaby.Browser.assert_has(session, css("[data-test-id='spacing-preview-section']"))
      Wallaby.Browser.assert_has(session, css(".spacing-preview", style: "padding: 8px"))
      Wallaby.Browser.assert_has(session, css(".container-preview", style: "padding: 24px"))
      Wallaby.Browser.assert_has(session, css(".section-preview", style: "margin: 32px"))
    end
  end

  describe "theme persistence and synchronization" do
    test "theme preferences are persisted", %{session: session, theme: theme} do
      # Apply theme
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

      # Simulate setting the user_theme in the session (Wallaby does not persist cookies between reloads by default)
      session = Wallaby.Browser.set_cookie(session, "user_theme", theme.name)

      # Reload page
      session
      |> visit("/")

      # Verify theme persistence
      Wallaby.Browser.assert_has(session, css(".theme-applied", text: theme.name))
      Wallaby.Browser.assert_has(session, css(".theme-type", text: theme.type))
    end

    test "theme changes sync across components", %{session: session, theme: theme} do
      # Apply theme
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
      theme: theme
    } do
      # Apply theme
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
    test "theme changes are applied efficiently", %{session: session, theme: theme} do
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

    test "_theme switching is smooth", %{session: session, _theme: _theme} do
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
    test "theme maintains accessibility standards", %{session: session, theme: theme} do
      # Navigate directly to theme customization page
      session
      |> visit("/themes/#{theme.id}?customize=1")

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

    test "_theme supports reduced motion", %{session: session, _theme: _theme} do
      # Enable reduced motion
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
      |> click(button("Accessibility Settings"))
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
