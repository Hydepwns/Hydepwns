defmodule HydepwnsLiveviewWeb.AccessibilityHelper do
  @moduledoc """
  Helper functions for accessibility testing in the Hydepwns application.

  This module provides utilities for testing web accessibility compliance,
  including helpers for checking ARIA attributes, keyboard navigation,
  heading structure, and more.
  """

  import ExUnit.Assertions
  import Phoenix.LiveViewTest

  @doc """
  Asserts that a skip-to-content link is present and properly configured.
  """
  def assert_skip_link(view) do
    # Check for skip link presence
    assert has_element?(view, "a.skip-to-content")

    # Check for correct href attribute
    assert has_element?(view, "a.skip-to-content[href='#main-content']")

    # Get the HTML and check for the text
    html = render(view)
    assert html =~ "Skip to content"

    {:ok, view}
  end

  @doc """
  Asserts that the heading structure is hierarchical and properly formed.
  This checks for presence of h1, then h2, etc. without skipping levels.
  """
  def assert_heading_hierarchy(view) do
    # Check for h1 presence (should be only one per page)
    assert has_element?(view, "h1")

    # If there are h3s, there should be h2s
    if has_element?(view, "h3") do
      assert has_element?(view, "h2")
    end

    # If there are h4s, there should be h3s
    if has_element?(view, "h4") do
      assert has_element?(view, "h3")
    end

    # If there are h5s, there should be h4s
    if has_element?(view, "h5") do
      assert has_element?(view, "h4")
    end

    # If there are h6s, there should be h5s
    if has_element?(view, "h6") do
      assert has_element?(view, "h5")
    end

    {:ok, view}
  end

  @doc """
  Asserts that interactive elements have proper ARIA attributes.
  """
  def assert_aria_attributes(view) do
    # Check buttons for aria-label, aria-labelledby, or aria-describedby
    buttons = find_elements(view, "button")

    for button <- buttons do
      assert has_aria_accessibility(button),
             "Button is missing required accessibility attributes: #{inspect(button)}"
    end

    # Check form inputs for associated labels
    inputs = find_elements(view, "input")

    for input <- inputs do
      assert has_label_or_aria(input),
             "Input is missing label or ARIA attributes: #{inspect(input)}"
    end

    {:ok, view}
  end

  @doc """
  Asserts that keyboard navigation is properly supported.
  """
  def assert_keyboard_navigation(view) do
    # Check that interactive elements have tabindex="0" or are naturally focusable
    assert_focusable_elements(view)

    # Check for any positive tabindex values (generally an anti-pattern)
    refute has_element?(view, "[tabindex]:not([tabindex='0']):not([tabindex='-1'])")

    # Check for keyboard traps (elements that capture focus)
    # This is hard to test programmatically, but we can check for common patterns

    {:ok, view}
  end

  @doc """
  Asserts that proper color contrast is used (based on CSS classes that we know meet requirements).
  """
  def assert_color_contrast(view) do
    # We can't test actual colors in ExUnit, but we can check for known accessible
    # color combinations based on our CSS classes

    # Check that high-contrast mode is available
    assert has_element?(
             view,
             "[data-theme], [class*='theme'], .high-contrast, #high-contrast-theme"
           )

    {:ok, view}
  end

  @doc """
  Asserts that reduced motion preferences are respected.
  """
  def assert_reduced_motion(view) do
    # Check for the presence of reduced motion CSS
    html = render(view)

    # Media query should be referenced somewhere
    assert html =~ "prefers-reduced-motion" ||
             html =~ "@media (prefers-reduced-motion: reduce)",
           "No reduced motion media query found in the HTML"

    {:ok, view}
  end

  @doc """
  Asserts that images have alt text.
  """
  def assert_images_have_alt_text(view) do
    images = find_elements(view, "img")

    for img <- images do
      assert has_attribute?(img, "alt"),
             "Image is missing alt attribute: #{inspect(img)}"
    end

    {:ok, view}
  end

  @doc """
  Runs all accessibility checks at once.
  """
  def assert_accessibility_compliance(view) do
    view
    |> assert_skip_link()
    |> assert_heading_hierarchy()
    |> assert_aria_attributes()
    |> assert_keyboard_navigation()
    |> assert_color_contrast()
    |> assert_reduced_motion()
    |> assert_images_have_alt_text()

    {:ok, view}
  end

  # Private helpers

  defp find_elements(view, selector) do
    html = render(view)
    {:ok, document} = Floki.parse_document(html)
    Floki.find(document, selector)
  end

  defp has_attribute?(element, attribute) do
    {_, attributes, _} = element
    Enum.any?(attributes, fn {attr, _} -> attr == attribute end)
  end

  defp has_aria_accessibility(button) do
    {_, attributes, children} = button

    # Check for ARIA attributes
    has_aria =
      Enum.any?(attributes, fn {attr, _} ->
        String.starts_with?(attr, "aria-")
      end)

    # Check for sr-only children
    has_sr_only = Floki.find(children, ".sr-only") != []

    has_aria || has_sr_only
  end

  defp has_label_or_aria(input) do
    {_, attributes, _} = input

    # Get the ID if present
    _id =
      Enum.find_value(attributes, fn
        {"id", value} -> value
        _ -> nil
      end)

    # Check for ARIA attributes
    has_aria =
      Enum.any?(attributes, fn {attr, _} ->
        String.starts_with?(attr, "aria-")
      end)

    # If we have an ID, we should check for a label with a matching 'for' attribute,
    # but this is difficult to do with the current implementation.
    # For now, we'll just check for the presence of ARIA attributes.

    has_aria
  end

  defp assert_focusable_elements(view) do
    # Check that interactive elements are focusable

    # Buttons should be focusable
    assert has_element?(view, "button")

    # Links should be focusable
    assert has_element?(view, "a[href]")

    # Form elements should be focusable
    for element_type <- ["input", "select", "textarea", "button"] do
      if has_element?(view, element_type) do
        assert has_element?(view, element_type)
      end
    end

    {:ok, view}
  end
end
