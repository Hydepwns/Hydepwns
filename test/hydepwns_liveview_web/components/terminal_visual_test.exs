defmodule HydepwnsLiveviewWeb.Components.TerminalVisualTest do
  use HydepwnsLiveviewWeb.WallabyCase, async: true

  @moduledoc """
  Visual regression tests for the Terminal component.

  These tests capture screenshots of the Terminal component in different states,
  with different themes, and at different viewport sizes to ensure visual consistency.
  """

  @tag :visual_test
  @tag clean_screenshots: true
  test "terminal component visual appearance", %{session: session} do
    # Test the terminal component at different viewport sizes
    session
    |> visit_and_wait("/components/terminal")
    |> wait_for_live_view()
    |> visual_test_suite("terminal", "/components/terminal",
      states: [
        {"default", fn s -> s end},
        {"with_command",
         fn s ->
           s
           |> fill_in(css("[data-test-id='terminal-input']"), with: "help")
           |> send_keys([:enter])
         end},
        {"fullscreen",
         fn s ->
           s
           |> click(css("[data-test-id='terminal-fullscreen-toggle']"))
         end}
      ]
    )
  end

  @tag :visual_test
  test "terminal themes visual appearance", %{session: session} do
    # Focus specifically on testing the terminal with different themes
    themes = [
      {"dark", fn s -> click(s, css("[data-test-id='theme-dark']")) end},
      {"light", fn s -> click(s, css("[data-test-id='theme-light']")) end},
      {"high_contrast", fn s -> click(s, css("[data-test-id='theme-high-contrast']")) end}
    ]

    # Visit the terminal component
    session = visit_and_wait(session, "/components/terminal")

    # Test each theme
    Enum.reduce(themes, session, fn {theme_name, theme_action}, session ->
      session = session |> theme_action.()
      # Wait for theme transition
      Process.sleep(500)
      session |> capture_screenshot(name: "terminal_#{theme_name}_theme")
    end)
  end

  @tag :visual_test
  test "terminal mobile experience", %{session: session} do
    # Focus on testing mobile viewport
    session
    # iPhone 6/7/8 size
    |> resize_window(375, 667)
    |> visit_and_wait("/components/terminal")
    |> wait_for_live_view()
    |> capture_screenshot(name: "terminal_mobile")

    # Test terminal with virtual keyboard
    session = session |> click(css("[data-test-id='terminal-input']"))
    # Wait for virtual keyboard
    Process.sleep(300)
    session = session |> capture_screenshot(name: "terminal_mobile_with_keyboard")

    # Test terminal with executed command
    session = session |> fill_in(css("[data-test-id='terminal-input']"), with: "help")
    session = session |> send_keys([:enter])
    # Wait for command execution
    Process.sleep(300)
    session |> capture_screenshot(name: "terminal_mobile_with_command")
  end

  @tag :visual_test
  test "terminal accessibility features", %{session: session} do
    # Test high contrast mode
    session = session |> visit_and_wait("/components/terminal")
    session = session |> wait_for_live_view()
    session = session |> click(css("[data-test-id='accessibility-high-contrast']"))
    # Wait for theme transition
    Process.sleep(300)
    session = session |> capture_screenshot(name: "terminal_high_contrast")

    # Test increased font size
    session = session |> click(css("[data-test-id='accessibility-increase-font']"))
    # Wait for font size change
    Process.sleep(300)
    session |> capture_screenshot(name: "terminal_increased_font_size")
  end
end
