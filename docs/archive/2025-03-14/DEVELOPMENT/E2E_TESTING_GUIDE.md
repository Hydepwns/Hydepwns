---
title: End-to-End Testing Guide
description: >-
  > **ARCHIVE NOTICE**: This document has been archived and may contain outdated
  information.

  > It has been moved to the new documentation structure. Please see the 

  > [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!--
  TODO: Fix broken link --> for information about the new locations.
topics:
  - prd
  - development
  - end-to-end-testing-guide
  - prerequisites
  - main-content
  - examples
  - troubleshooting
  - related-documents
  - overview
  - test-structure
  - critical-user-workflows
  - best-practices
  - common-patterns
  - wait-for-liveview-to-fully-render
  - give-liveview-time-to-initialize-
  - testing-across-devices
  - test-on-mobile-view
  - test-on-tablet-view
  - test-on-desktop-view
  - testing-with-different-themes
  - switch-to-dark-theme
  - perform-test-actions
  - '-'
  - switch-to-light-theme
  - tips-for-debugging-tests
  - references
  - code-examples
  - testing
last_updated: '2025-03-14'
---
# End-to-End Testing Guide

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

# End-to-End Testing Guide


> **ARCHIVE NOTICE**: This document has been archived and may contain outdated information.
> It has been moved to the new documentation structure. Please see the 
> [PRD Migration Guide](../project/documentation/migration-guide.md) <!-- TODO: Fix broken link --> <!-- TODO: Fix broken link --> for information about the new locations.


This guide provides instructions and best practices for creating end-to-end tests for critical user workflows in the Hydepwns application using Wallaby.

## Overview

End-to-end tests simulate real user interactions with the application to verify that complete workflows function correctly. Unlike unit or integration tests, E2E tests ensure that all components work together properly in a production-like environment.

## Test Structure

E2E tests in Hydepwns follow a standard structure:

1. **Setup**: Prepare test data and environment
2. **Navigation**: Visit the relevant page(s)
3. **Interaction**: Perform user actions (clicks, form submissions, etc.)
4. **Verification**: Assert that the expected outcomes occurred
5. **Cleanup**: Remove test data (optional, handled by the testing framework in most cases)

## Critical User Workflows

According to our roadmap, we need to implement end-to-end tests for the following critical workflows:

### 1. Resource Creation → Validation → Transformation → Event Generation

This workflow tests the core resource management functionality from creation through the entire lifecycle.

```elixir
defmodule HydepwnsLiveviewWeb.ResourceCreationWorkflowTest do
  use HydepwnsLiveviewWeb.WallabyCase, async: true

  @tag :e2e_test
  test "complete resource creation workflow", %{session: session} do
    # Step 1: Navigate to resource creation page
    session = 
      session
      |> visit_and_wait("/resources/new")
      |> wait_for_live_view()
    
    # Step 2: Fill in resource details
    session =
      session
      |> fill_in(css("[data-test-id='resource-name-input']"), with: "Test Resource")
      |> fill_in(css("[data-test-id='resource-description-input']"), with: "This is a test resource for E2E testing")
      |> select(css("[data-test-id='resource-type-select']"), option: "Document")
      
    # Step 3: Add resource properties
    session =
      session
      |> click(css("[data-test-id='add-property-button']"))
      |> fill_in(css("[data-test-id='property-name-input']"), with: "test_property")
      |> fill_in(css("[data-test-id='property-value-input']"), with: "test_value")
      
    # Step 4: Submit the form
    session =
      session
      |> click(css("[data-test-id='save-resource-button']"))
      
    # Step 5: Verify successful creation
    session
      |> assert_has(css(".resource-created-notification"))
      |> assert_has(css("[data-test-id='resource-name']", text: "Test Resource"))
      
    # Step 6: Verify validation was applied
    session
      |> assert_has(css("[data-test-id='validation-status-success']"))
      
    # Step 7: Verify transformation was applied
    session
      |> assert_has(css("[data-test-id='transformation-result']"))
      
    # Step 8: Navigate to events page
    session =
      session
      |> click(css("[data-test-id='view-events-button']"))
      
    # Step 9: Verify event generation
    session
      |> assert_has(css("[data-test-id='event-type-resource-created']"))
      |> assert_has(css("[data-test-id='event-resource-id']", text: "Test Resource"))
  end
end
```markdown

### 2. Resource Relationship Management

This workflow tests creating, viewing, and modifying relationships between resources.

```elixir
defmodule HydepwnsLiveviewWeb.ResourceRelationshipWorkflowTest do
  use HydepwnsLiveviewWeb.WallabyCase, async: true

  setup do
    # Create test resources
    {:ok, resource1} = create_test_resource("Source Resource")
    {:ok, resource2} = create_test_resource("Target Resource")
    
    %{resource1: resource1, resource2: resource2}
  end

  @tag :e2e_test
  test "resource relationship management workflow", %{session: session, resource1: resource1, resource2: resource2} do
    # Step 1: Navigate to the source resource
    session =
      session
      |> visit_and_wait("/resources/#{resource1.id}")
      |> wait_for_live_view()
    
    # Step 2: Navigate to the relationships tab
    session =
      session
      |> click(css("[data-test-id='relationships-tab']"))
    
    # Step 3: Add a new relationship
    session =
      session
      |> click(css("[data-test-id='add-relationship-button']"))
      |> click(css("[data-test-id='relationship-type-select']"))
      |> click(css("option", text: "depends_on"))
      |> fill_in(css("[data-test-id='relationship-target-search']"), with: "Target")
      |> click(css("[data-test-id='relationship-target-result']", text: "Target Resource"))
      |> click(css("[data-test-id='save-relationship-button']"))
    
    # Step 4: Verify relationship was created
    session
      |> assert_has(css("[data-test-id='relationship-item']"))
      |> assert_has(css("[data-test-id='relationship-type']", text: "depends_on"))
      |> assert_has(css("[data-test-id='relationship-target']", text: "Target Resource"))
    
    # Step 5: Modify the relationship
    session =
      session
      |> click(css("[data-test-id='edit-relationship-button']"))
      |> click(css("[data-test-id='relationship-type-select']"))
      |> click(css("option", text: "references"))
      |> click(css("[data-test-id='save-relationship-button']"))
    
    # Step 6: Verify relationship was updated
    session
      |> assert_has(css("[data-test-id='relationship-type']", text: "references"))
    
    # Step 7: Navigate to the target resource to verify bidirectional relationship
    session =
      session
      |> visit_and_wait("/resources/#{resource2.id}")
      |> wait_for_live_view()
      |> click(css("[data-test-id='relationships-tab']"))
    
    # Step 8: Verify reverse relationship exists
    session
      |> assert_has(css("[data-test-id='relationship-item']"))
      |> assert_has(css("[data-test-id='relationship-type']", text: "referenced_by"))
      |> assert_has(css("[data-test-id='relationship-target']", text: "Source Resource"))
  end
  
  defp create_test_resource(name) do
    # Helper to create test resources
    # This would use your resource creation API
    HydepwnsLiveview.Resources.create_resource(%{
      name: name,
      type: "Document",
      description: "Test resource for relationship testing"
    })
  end
end
```markdown

### 3. Resource Event Processing and Subscription

This workflow tests event subscription, processing, and notification.

```elixir
defmodule HydepwnsLiveviewWeb.EventProcessingWorkflowTest do
  use HydepwnsLiveviewWeb.WallabyCase, async: true

  setup do
    # Create a test resource
    {:ok, resource} = create_test_resource("Event Test Resource")
    
    %{resource: resource}
  end

  @tag :e2e_test
  test "event processing and subscription workflow", %{session: session, resource: resource} do
    # Step 1: Navigate to event dashboard
    session =
      session
      |> visit_and_wait("/events/dashboard")
      |> wait_for_live_view()
    
    # Step 2: Create a new event subscription
    session =
      session
      |> click(css("[data-test-id='create-subscription-button']"))
      |> fill_in(css("[data-test-id='subscription-name-input']"), with: "Test Subscription")
      |> click(css("[data-test-id='event-type-select']"))
      |> click(css("option", text: "resource_updated"))
      |> click(css("[data-test-id='save-subscription-button']"))
    
    # Step 3: Verify subscription was created
    session
      |> assert_has(css("[data-test-id='subscription-item']", text: "Test Subscription"))
      |> assert_has(css("[data-test-id='subscription-event-type']", text: "resource_updated"))
    
    # Step 4: Navigate to resource and generate an update event
    session =
      session
      |> visit_and_wait("/resources/#{resource.id}/edit")
      |> wait_for_live_view()
      |> fill_in(css("[data-test-id='resource-description-input']"), with: "Updated description")
      |> click(css("[data-test-id='save-resource-button']"))
    
    # Step 5: Navigate back to events dashboard
    session =
      session
      |> visit_and_wait("/events/dashboard")
      |> wait_for_live_view()
    
    # Step 6: Verify event was processed
    session
      |> click(css("[data-test-id='subscription-item']", text: "Test Subscription"))
      |> assert_has(css("[data-test-id='event-item']"))
      |> assert_has(css("[data-test-id='event-type']", text: "resource_updated"))
      |> assert_has(css("[data-test-id='event-resource-id']", text: resource.id))
    
    # Step 7: Verify event details
    session
      |> click(css("[data-test-id='event-item']"))
      |> assert_has(css("[data-test-id='event-payload-field']", text: "description"))
      |> assert_has(css("[data-test-id='event-payload-value']", text: "Updated description"))
  end
  
  defp create_test_resource(name) do
    HydepwnsLiveview.Resources.create_resource(%{
      name: name,
      type: "Document",
      description: "Test resource for event testing"
    })
  end
end
```markdown

### 4. Terminal Component Full Workflow

This workflow tests the terminal component from command input through execution.

```elixir
defmodule HydepwnsLiveviewWeb.TerminalWorkflowTest do
  use HydepwnsLiveviewWeb.WallabyCase, async: true

  @tag :e2e_test
  test "terminal component workflow", %{session: session} do
    # Step 1: Navigate to terminal page
    session =
      session
      |> visit_and_wait("/terminal")
      |> wait_for_live_view()
    
    # Step 2: Verify terminal is loaded
    session
      |> assert_has(css("[data-test-id='terminal-container']"))
      |> assert_has(css("[data-test-id='terminal-prompt']"))
    
    # Step 3: Execute a help command
    session =
      session
      |> fill_in(css("[data-test-id='terminal-input']"), with: "help")
      |> element(css("[data-test-id='terminal-form']"))
      |> render_submit()
    
    # Step 4: Verify command output
    session
      |> assert_has(css("[data-test-id='terminal-output-line']", text: "Available commands:"))
    
    # Step 5: Execute a command with arguments
    session =
      session
      |> fill_in(css("[data-test-id='terminal-input']"), with: "echo Hello, World!")
      |> element(css("[data-test-id='terminal-form']"))
      |> render_submit()
    
    # Step 6: Verify command output
    session
      |> assert_has(css("[data-test-id='terminal-output-line']", text: "Hello, World!"))
    
    # Step 7: Test command history navigation
    session =
      session
      |> send_keys(css("[data-test-id='terminal-input']"), [:up])
    
    # Step 8: Verify history navigation worked
    input_value = session |> find(css("[data-test-id='terminal-input']")) |> attribute_value("value")
    assert input_value == "echo Hello, World!"
    
    # Step 9: Test terminal fullscreen mode
    session =
      session
      |> click(css("[data-test-id='terminal-fullscreen-button']"))
    
    # Step 10: Verify fullscreen mode
    session
      |> assert_has(css("[data-test-id='terminal-container'].fullscreen"))
    
    # Step 11: Exit fullscreen mode
    session =
      session
      |> click(css("[data-test-id='terminal-fullscreen-button']"))
    
    # Step 12: Verify exited fullscreen mode
    session
      |> assert_has(css("[data-test-id='terminal-container']:not(.fullscreen)"))
  end
end
```markdown

### 5. Theme System Workflow

This workflow tests theme switching and persistence.

```elixir
defmodule HydepwnsLiveviewWeb.ThemeSystemWorkflowTest do
  use HydepwnsLiveviewWeb.WallabyCase, async: true

  @tag :e2e_test
  test "theme system workflow", %{session: session} do
    # Step 1: Navigate to home page
    session =
      session
      |> visit_and_wait("/")
      |> wait_for_live_view()
    
    # Step 2: Verify default theme is applied
    body_classes = session |> find(css("body")) |> attribute_value("class")
    assert String.contains?(body_classes, "theme-light") or String.contains?(body_classes, "theme-system")
    
    # Step 3: Open theme switcher
    session =
      session
      |> click(css("[data-test-id='theme-switcher-button']"))
    
    # Step 4: Select dark theme
    session =
      session
      |> click(css("[data-test-id='theme-option-dark']"))
    
    # Step 5: Verify dark theme is applied
    body_classes = session |> find(css("body")) |> attribute_value("class")
    assert String.contains?(body_classes, "theme-dark")
    
    # Step 6: Refresh page to verify theme persistence
    session =
      session
      |> visit_and_wait("/")
      |> wait_for_live_view()
    
    # Step 7: Verify theme persisted after refresh
    body_classes = session |> find(css("body")) |> attribute_value("class")
    assert String.contains?(body_classes, "theme-dark")
    
    # Step 8: Switch to dim theme
    session =
      session
      |> click(css("[data-test-id='theme-switcher-button']"))
      |> click(css("[data-test-id='theme-option-dim']"))
    
    # Step 9: Verify dim theme is applied
    body_classes = session |> find(css("body")) |> attribute_value("class")
    assert String.contains?(body_classes, "theme-dim")
    
    # Step 10: Navigate to a different page
    session =
      session
      |> visit_and_wait("/about")
      |> wait_for_live_view()
    
    # Step 11: Verify theme persisted across navigation
    body_classes = session |> find(css("body")) |> attribute_value("class")
    assert String.contains?(body_classes, "theme-dim")
  end
end
```markdown

## Best Practices

1. **Use data attributes for testing**: Always add `data-test-id` attributes to elements you need to interact with in tests.
2. **Test complete workflows**: Focus on testing end-to-end user journeys rather than individual features.
3. **Add wait helpers**: Ensure your tests wait for LiveView to fully render and for animations to complete.
4. **Take screenshots on failure**: Configure Wallaby to capture screenshots when tests fail for easier debugging.
5. **Isolate test data**: Use setup blocks to create isolated test data that won't affect other tests.
6. **Test different device sizes**: Use `resize_window/3` to test workflows on different screen sizes.

## Common Patterns

### Waiting for LiveView

```elixir
# Wait for LiveView to fully render
session =
  session
  |> visit(path)
  |> assert_has(css("body[data-phx-session]"))

# Give LiveView time to initialize 
Process.sleep(300)
```markdown

## Testing across devices

```elixir
# Test on mobile view
session = resize_window(session, 375, 667)

# Test on tablet view
session = resize_window(session, 768, 1024)

# Test on desktop view
session = resize_window(session, 1366, 768)
```markdown

## Testing with different themes

```elixir
# Switch to dark theme
session = click(session, css("[data-test-id='theme-option-dark']"))

# Perform test actions
# ...

# Switch to light theme
session = click(session, css("[data-test-id='theme-option-light']"))

# Perform test actions
# ...
```markdown

## Tips for Debugging Tests

1. Use `take_screenshot/2` to capture screenshots at critical points
2. Enable the headful browser option during test development
3. Add strategic `IO.inspect` calls to track test progress
4. Use smaller, focused tests during development, then combine into workflows
5. Check logs for JavaScript errors that might affect test execution 

## References

- [Project Documentation](../README.md)
