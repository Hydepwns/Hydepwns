defmodule HydepwnsLiveviewWeb.TestHelpers do
  @moduledoc """
  Helper functions for testing LiveView components.
  """

  import Phoenix.LiveViewTest
  import ExUnit.Assertions

  @doc """
  Asserts that dynamic focus is working correctly.
  """
  def assert_dynamic_focus(view) do
    # Focus an element
    element(view, "#focus-test")
    |> render_focus()

    # Assert the element has focus
    assert has_element?(view, "#focus-test:focus")
  end

  @doc """
  Asserts that focus indicators are present.
  """
  def assert_focus_indicators(view) do
    # Focus an element
    element(view, "#focus-test")
    |> render_focus()

    # Assert focus indicator is present
    assert has_element?(view, "#focus-test.focus-visible")
  end

  @doc """
  Asserts that focus is restored after an action.
  """
  def assert_focus_restoration(view) do
    # Focus an element
    element(view, "#focus-test")
    |> render_focus()

    # Perform an action that might change focus
    element(view, "#action-button")
    |> render_click()

    # Assert focus is restored
    assert has_element?(view, "#focus-test:focus")
  end

  @doc """
  Asserts that a modal has proper focus trapping.
  """
  def assert_modal_focus_trap(view) do
    # Open modal
    element(view, "#open-modal")
    |> render_click()

    # Assert modal is focused
    assert has_element?(view, "#modal:focus")

    # Try to focus outside modal
    element(view, "#outside-element")
    |> render_focus()

    # Assert focus remains in modal
    assert has_element?(view, "#modal:focus")
  end

  # Private helper functions

  defp check_element_exists?(view, selector) do
    case render(view) do
      html when is_binary(html) ->
        case Floki.parse_document(html) do
          {:ok, document} ->
            case Floki.find(document, selector) do
              [] -> false
              _ -> true
            end
          _ -> false
        end
      _ -> false
    end
  end
end 