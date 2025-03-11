# Hydepwns Testing Guide

This guide provides an overview of the testing infrastructure and best practices for the Hydepwns monospace web application.

## Table of Contents

- [Testing Philosophy](#testing-philosophy)
- [Test Types](#test-types)
- [Testing Tools](#testing-tools)
- [Test Organization](#test-organization)
- [Writing Tests](#writing-tests)
- [Test Helpers](#test-helpers)
- [Running Tests](#running-tests)
- [CI/CD Integration](#cicd-integration)
- [Testing Checklist](#testing-checklist)

## Testing Philosophy

Our testing philosophy is based on the following principles:

1. **Test behavior, not implementation**: Focus on testing what the code does, not how it does it
2. **Test at the right level**: Use the appropriate test type for each component or feature
3. **Prioritize user-facing functionality**: Focus on testing features that directly impact users
4. **Test edge cases**: Include tests for error handling, boundary conditions, and edge cases
5. **Maintain test quality**: Tests should be readable, maintainable, and reliable

## Test Types

The Hydepwns application uses the following types of tests:

### Unit Tests

Unit tests verify the behavior of individual functions or modules in isolation. These tests focus on pure business logic and utility functions.

Example:
```elixir
defmodule HydepwnsLiveviewWeb.TOCHelperTest do
  use ExUnit.Case, async: true
  alias HydepwnsLiveviewWeb.TOCHelper

  test "extract_toc_items_from_content extracts headings" do
    content = """
    <h1>Title</h1>
    <h2 id="section-1">Section 1</h2>
    <p>Some content</p>
    <h2 id="section-2">Section 2</h2>
    """
    
    toc_items = TOCHelper.extract_toc_items_from_content(content)
    
    assert length(toc_items) == 2
    assert Enum.at(toc_items, 0).id == "section-1"
    assert Enum.at(toc_items, 0).text == "Section 1"
    assert Enum.at(toc_items, 1).id == "section-2"
    assert Enum.at(toc_items, 1).text == "Section 2"
  end
end
```

### Component Tests

Component tests verify the behavior of LiveView components in isolation. These tests focus on rendering, event handling, and component lifecycle.

Example:
```elixir
defmodule HydepwnsLiveviewWeb.Components.TerminalTest do
  use HydepwnsLiveviewWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import HydepwnsLiveviewWeb.ComponentTestHelper
  alias HydepwnsLiveviewWeb.Components.Terminal

  test "renders the terminal component with default values", %{conn: conn} do
    {:ok, view, html} = render_component(conn, Terminal, id: "test-terminal")
    
    assert html =~ "terminal-container"
    assert html =~ "terminal-screen"
    assert html =~ "terminal-prompt"
  end
  
  test "handles command input", %{conn: conn} do
    {:ok, view, _html} = render_component(conn, Terminal, id: "test-terminal")
    
    assert_change(view, "#test-terminal-input", %{"value" => "help"}, "Available commands")
  end
end
```

### LiveView Tests

LiveView tests verify the behavior of LiveView pages, including rendering, event handling, and navigation.

Example:
```elixir
defmodule HydepwnsLiveviewWeb.StyleGuideLiveTest do
  use HydepwnsLiveviewWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  
  test "renders the style guide page", %{conn: conn} do
    {:ok, view, html} = live(conn, "/style-guide")
    
    assert html =~ "Hydepwns Monospace Style Guide"
    assert html =~ "Typography"
    assert html =~ "Color Palette"
  end
  
  test "can change theme", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/style-guide")
    
    view
    |> element("#light-theme")
    |> render_click()
    
    assert has_element?(view, "[data-theme='light-theme']")
  end
end
```

### Integration Tests

Integration tests verify the behavior of multiple components working together, including user flows and interactions.

Example:
```elixir
defmodule HydepwnsLiveviewWeb.UserFlowTest do
  use HydepwnsLiveviewWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  
  test "can navigate from home to style guide", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")
    
    view
    |> element("a", "Style Guide")
    |> render_click()
    
    assert_redirected(view, "/style-guide")
    
    {:ok, view, html} = follow_redirect(view, conn)
    
    assert html =~ "Hydepwns Monospace Style Guide"
  end
end
```

### Accessibility Tests

Accessibility tests verify that the application is accessible to users with disabilities, including screen readers, keyboard navigation, and ARIA attributes.

Example:
```elixir
defmodule HydepwnsLiveviewWeb.AccessibilityTest do
  use HydepwnsLiveviewWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import HydepwnsLiveviewWeb.ComponentTestHelper
  
  test "skip to content link is present", %{conn: conn} do
    {:ok, view, html} = live(conn, "/")
    
    assert html =~ "Skip to content"
    assert html =~ "skip-to-content"
    assert html =~ "href=\"#main-content\""
  end
  
  test "keyboard navigation is supported", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/style-guide")
    
    assert_element_exists(view, "button[tabindex='0']")
  end
end
```

## Testing Tools

The Hydepwns application uses the following testing tools:

- **ExUnit**: The built-in testing framework for Elixir
- **Phoenix.LiveViewTest**: Provides utilities for testing LiveView components and pages
- **Floki**: HTML parser for assertions on rendered HTML
- **ComponentTestHelper**: Custom helpers for component testing
- **AccessibilityHelper**: Custom helpers for accessibility testing
- **FixtureHelper**: Custom helpers for generating test data

## Test Organization

Tests are organized according to the following structure:

```
test/
├── hydepwns_liveview/             # Tests for business logic
├── hydepwns_liveview_web/         # Tests for web components
│   ├── components/                # Component tests
│   ├── controllers/               # Controller tests
│   ├── js/                        # JavaScript tests
│   └── live/                      # LiveView tests
├── support/                       # Test helpers and fixtures
│   ├── accessibility_helper.ex    # Accessibility testing helpers
│   ├── component_test_helper.ex   # Component testing helpers
│   ├── conn_case.ex               # Connection case for web tests
│   ├── fixture_helper.ex          # Test data fixtures
│   ├── js_test_helper.ex          # JavaScript testing helpers
│   └── render_helper.ex           # Rendering test helpers
└── test_helper.exs                # Test configuration
```

## Writing Tests

When writing tests for the Hydepwns application, follow these guidelines:

### Naming Conventions

- Test files should be named after the module they test, with a `_test` suffix
- Test module names should match the file name
- Test function names should describe the behavior being tested
- Use descriptive test names that explain what's being tested

### Test Structure

- Use `describe` blocks to group related tests
- Use clear and descriptive test names with the format "verbs what happens"
- Set up test data in the test function rather than in global variables
- Use test helpers and fixtures for common setup and assertions

### Assertions

- Use the appropriate assertion for each test case
- Use `assert` for positive assertions and `refute` for negative assertions
- Use `assert_element`, `assert_attribute`, etc. from the ComponentTestHelper for component tests
- Use `floki_text` for assertions on text content

## Test Helpers

The Hydepwns application provides several test helpers to simplify testing:

### ComponentTestHelper

The `ComponentTestHelper` module provides utilities for testing LiveView components, including:

- `render_component/3`: Renders a component in isolation
- `assert_element/3`: Asserts that an element exists with the given text
- `refute_element/2`: Asserts that an element does not exist
- `assert_element_exists/2`: Asserts that an element exists
- `assert_attribute/4`: Asserts that an element has the specified attribute
- `assert_click/3`: Simulates a click event and asserts the result
- `assert_change/4`: Simulates a change event and asserts the result
- `assert_submit/4`: Simulates a form submission and asserts the result
- `assert_accessibility/1`: Checks for common accessibility issues

### FixtureHelper

The `FixtureHelper` module provides utilities for generating test data:

- `build_user/1`: Builds a user fixture with the given attributes
- `build_post/1`: Builds a post fixture with the given attributes
- `build_comment/1`: Builds a comment fixture with the given attributes

### AccessibilityHelper

The `AccessibilityHelper` module provides utilities for accessibility testing:

- `assert_skip_link/1`: Asserts that a skip link is present
- `assert_heading_hierarchy/1`: Asserts that heading hierarchy is proper
- `assert_aria_attributes/1`: Asserts that ARIA attributes are present
- `assert_keyboard_navigation/1`: Asserts that keyboard navigation is supported

## Running Tests

To run the test suite, use the following commands:

```bash
# Run all tests
mix test

# Run a specific test file
mix test test/hydepwns_liveview_web/components/terminal_test.exs

# Run a specific test (line number)
mix test test/hydepwns_liveview_web/components/terminal_test.exs:42

# Run tests with tags
mix test --only accessibility

# Run tests with coverage
mix test --cover
```

## CI/CD Integration

The Hydepwns application uses GitHub Actions for CI/CD integration. The test suite is run on every push and pull request.

The CI pipeline includes:

- Running the test suite
- Checking code formatting with `mix format --check-formatted`
- Running static analysis with `mix credo --strict`
- Checking for compiler warnings with `mix compile --warnings-as-errors`
- Generating test coverage reports with `mix test --cover`

## Testing Checklist

Use this checklist when writing and reviewing tests:

- [ ] All public functions have unit tests
- [ ] All components have component tests
- [ ] All LiveViews have LiveView tests
- [ ] All user flows have integration tests
- [ ] All accessibility features have accessibility tests
- [ ] Tests are descriptive and focused
- [ ] Tests use the appropriate helpers and assertions
- [ ] Tests are fast and reliable
- [ ] Tests cover edge cases and error handling
- [ ] Tests are isolated and don't depend on global state

## Troubleshooting Common Test Issues

### Tests Failing Intermittently

If tests are failing intermittently, check for:

- Race conditions in asynchronous code
- Dependencies on global state
- Time-dependent tests
- Resource leaks

### Tests Taking Too Long

If tests are taking too long to run, check for:

- Unnecessary setup or teardown
- Too many assertions in a single test
- Inefficient queries or operations
- Missing `async: true` in test modules

### Tests Failing After Refactoring

If tests are failing after refactoring, check for:

- Tests that depend on implementation details
- Hardcoded values or selectors
- Missing abstractions
- Tests that are too specific

## Additional Resources

- [ExUnit Documentation](https://hexdocs.pm/ex_unit/ExUnit.html)
- [Phoenix.LiveViewTest Documentation](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveViewTest.html)
- [Testing Phoenix Applications](https://hexdocs.pm/phoenix/testing.html)
- [Accessibility Testing Guide](https://www.w3.org/WAI/test-evaluate/) 