---
title: Hydepwns Testing Guide
description: >-
  > **ARCHIVE NOTICE**: This document has been archived and may contain outdated
  information.

  > It has been moved to the new documentation structure. Please see the 

  > [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!--
  TODO: Fix broken link --> for information about the new locations.
topics:
  - archive
  - prd
  - development
  - hydepwns-testing-guide
  - prerequisites
  - main-content
  - examples
  - troubleshooting
  - related-documents
  - overview
  - table-of-contents
  - testing-philosophy
  - test-types
  - testing-tools
  - test-organization
  - writing-tests
  - test-helpers
  - running-tests
  - run-all-tests
  - run-a-specific-test-file
  - run-a-specific-test-line-number-
  - run-tests-with-tags
  - run-tests-with-coverage
  - ci-cd-integration
  - testing-checklist
  - javascript-component-testing
  - project-structure
  - basic-component-test-structure
  - run-all-javascript-tests
  - run-tests-for-a-specific-component
  - run-tests-in-watch-mode
  - troubleshooting-common-test-issues
  - additional-resources
  - references
  - code-examples
  - testing
last_updated: '2025-03-14'
---
# Hydepwns Testing Guide

> **ARCHIVE NOTICE**: This document has been archived and may contain outdated information.
> It has been moved to the new documentation structure. Please see the 
> [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link --> for information about the new locations.


## Prerequisites

* No specific prerequisites


## Main Content


## Examples

Examples will be added here.


## Troubleshooting

Common issues and their solutions will be documented here.


## Related Documents

* No references yet

# Hydepwns Testing Guide


> **ARCHIVE NOTICE**: This document has been archived and may contain outdated information.
> It has been moved to the new documentation structure. Please see the 
> [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link --> for information about the new locations.


## Overview

This document provides information about TESTING GUIDE.


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
- [JavaScript Component Testing](#javascript-component-testing)

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
```markdown

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
```markdown

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
```markdown

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
```markdown

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
```markdown

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

```markdown
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
```markdown

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
```markdown

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

## JavaScript Component Testing

The Hydepwns application includes JavaScript components that are tested using Jest. This section provides guidance for testing JavaScript components.

### Setting Up Jest Tests

Jest tests for JavaScript components should be placed in the `test/js` directory, with each test file named after the component it tests with a `_test.js` suffix.

```bash
# Project structure
assets/
  js/
    components/
      auto_resize.js
      toast.js
      mono_tabs.js
test/
  js/
    components/
      auto_resize_test.js
      toast_test.js
      mono_tabs_test.js
```markdown

## Basic Component Test Structure

A typical JavaScript component test includes:

```javascript
// Import the component
import AutoResizeComponent from '../assets/js/components/auto_resize';

// Optional: Mock dependencies
jest.mock('../assets/js/utils/dom_cleanup', () => {
  return {
    register: jest.fn().mockReturnValue({
      registerElement: jest.fn(),
      registerTimeout: jest.fn(),
      cleanup: jest.fn()
    })
  };
});

// Test suite
describe('AutoResize Component', () => {
  // Setup before each test
  let container;
  let textarea;
  
  beforeEach(() => {
    // Create DOM elements
    container = document.createElement('div');
    textarea = document.createElement('textarea');
    container.appendChild(textarea);
    document.body.appendChild(container);
  });
  
  // Cleanup after each test
  afterEach(() => {
    document.body.innerHTML = '';
    jest.clearAllMocks();
  });
  
  // Individual tests
  test('initializes with correct properties', () => {
    const autoResize = new AutoResizeComponent({
      container: container,
      textarea: textarea
    }).mount();
    
    expect(autoResize.elements.container).toBe(container);
    expect(autoResize.elements.textarea).toBe(textarea);
  });
  
  test('adjusts height on input', () => {
    const autoResize = new AutoResizeComponent({
      container: container,
      textarea: textarea
    }).mount();
    
    // Mock scrollHeight
    Object.defineProperty(textarea, 'scrollHeight', { value: 100 });
    
    // Trigger input event
    const event = new Event('input');
    textarea.dispatchEvent(event);
    
    // Check that height was adjusted
    expect(textarea.style.height).toBe('100px');
  });
});
```markdown

### Handling ES Modules in Jest

Jest is designed for CommonJS modules, which can cause issues when testing ES modules. Use the following strategies:

1. **Configure Babel properly**:

```javascript
// babel.config.js
module.exports = {
  presets: [
    ['@babel/preset-env', {
      targets: {
        node: 'current',
      },
    }],
  ],
};
```markdown

2. **Use dynamic imports in test files**:

```javascript
// Instead of this (ES Module syntax)
import ToastComponent from '../../assets/js/components/toast';

// Use this (CommonJS syntax)
const ToastComponent = require('../../assets/js/components/toast');
```markdown

3. **Avoid ES module imports in Jest setup files**:

```javascript
// jest.setup.js
// BAD: import { setupDOM } from './setup_helpers';
// GOOD:
const { setupDOM } = require('./setup_helpers');
```markdown

### Testing DOM Manipulation

Components that manipulate the DOM require special care:

1. **Setup the DOM structure properly**:

```javascript
beforeEach(() => {
  // Create required DOM elements
  container = document.createElement('div');
  document.body.appendChild(container);
  
  // For components that create their own elements,
  // manually establish parent-child relationships
  if (componentCreatesChildren) {
    const child = document.createElement('div');
    container.appendChild(child);
  }
});
```markdown

2. **Mock DOM creation but test manipulation directly**:

```javascript
// Mock the createElement method
const domCleanup = require('../../assets/js/utils/dom_cleanup');
domCleanup.createElement.mockImplementation((tag, attrs) => {
  // Return a real DOM element instead of a mock object
  const element = document.createElement(tag);
  if (attrs) {
    Object.entries(attrs).forEach(([key, value]) => {
      if (key === 'className') {
        element.className = value;
      } else {
        element.setAttribute(key, value);
      }
    });
  }
  return element;
});
```markdown

3. **Test animation and timing with Jest's timer mocks**:

```javascript
// Enable fake timers
jest.useFakeTimers();

test('component fades out after duration', () => {
  const component = new Component().mount();
  component.show();
  
  // Fast-forward time
  jest.advanceTimersByTime(1000);
  
  // Check that fade-out started
  expect(component.element.style.opacity).toBe('0');
  
  // Fast-forward through animation
  jest.advanceTimersByTime(300);
  
  // Check that element was removed
  expect(component.element.parentNode).toBeNull();
});
```markdown

### Testing Complex Components

For complex components like the Toast component:

1. **Separate creation from manipulation**:
   - Mock the creation of elements
   - Test the manipulation directly
   - Manually establish parent-child relationships

2. **Use spies to verify method calls**:

```javascript
test('dismisses toast when clicked', () => {
  const toast = new ToastComponent({
    container: container
  }).mount();
  
  // Setup the DOM structure
  container.appendChild(mockToastContainer);
  mockToastContainer.appendChild(mockToastElement);
  
  // Create a spy on the dismiss method
  const dismissSpy = jest.spyOn(toast, 'dismiss');
  
  // Show a toast
  const toastId = toast.show({ message: 'Test message' });
  
  // Click the toast
  mockToastElement.click();
  
  // Verify the dismiss method was called
  expect(dismissSpy).toHaveBeenCalledWith(toastId);
});
```markdown

3. **Test each variant of the component**:

```javascript
['success', 'error', 'warning', 'info'].forEach(type => {
  test(`shows a ${type} toast with correct classes`, () => {
    const toast = new ToastComponent({
      container: container
    }).mount();
    
    // Set up DOM
    container.appendChild(mockToastContainer);
    mockToastContainer.appendChild(mockToastElement);
    
    // Show a toast with the specific type
    toast.show({
      message: `Test ${type} message`,
      type: type
    });
    
    // Verify the toast has the correct class
    expect(mockToastElement.classList.contains(`toast-${type}`)).toBe(true);
  });
});
```markdown

### Running JavaScript Tests

To run JavaScript component tests:

```bash
# Run all JavaScript tests
npx jest

# Run tests for a specific component
npx jest test/js/components/auto_resize_test.js

# Run tests with coverage
npx jest --coverage

# Run tests in watch mode
npx jest --watch
```markdown

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


## References

- [Project Documentation](../README.md)
