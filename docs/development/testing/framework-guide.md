---
title: Event-Sourced Resource Testing Guide
description: '## Overview'
topics:
  - development
  - testing
  - event-sourced-resource-testing-guide
  - overview
  - prerequisites
  - main-content
  - troubleshooting
  - related-documents
  - introduction
  - table-of-contents
  - getting-started
  - basic-concepts
  - testing-patterns
  - use-in-a-scenario
  - test-suites
  - advanced-techniques
  - best-practices
  - examples
  - in-a-test
  - property-testing
  - create-a-complex-initial-state-with-multiple-events
  - api-reference
  - references
  - code-examples
last_updated: '2025-03-14'
---
# Event-Sourced Resource Testing Guide

## Overview


## Prerequisites

* No specific prerequisites


## Main Content


## Troubleshooting

Common issues and their solutions will be documented here.


## Related Documents

* No references yet

This document provides information about Framework-Guide.


## Introduction

This guide provides detailed information on how to use the `TestFramework` module to test event-sourced resources in the Hydepwns project. The testing framework provides a rich set of tools and patterns for writing expressive, maintainable tests for resources that follow the event sourcing pattern.

## Table of Contents

1. [Getting Started](#getting-started)
2. [Basic Concepts](#basic-concepts)
3. [Testing Patterns](#testing-patterns)
   - [Scenario Testing](#scenario-testing)
   - [Property-Based Testing](#property-based-testing)
   - [Command Helpers](#command-helpers)
   - [Test Suites](#test-suites)
4. [Advanced Techniques](#advanced-techniques)
   - [Custom Event Generation](#custom-event-generation)
   - [Stateful Testing](#stateful-testing)
5. [Best Practices](#best-practices)
6. [Examples](#examples)
   - [Basic Scenario](#basic-scenario)
   - [State Verification](#state-verification)
   - [Command Helpers](#example-command-helpers)
   - [Property Testing](#property-testing)
   - [Advanced Scenarios](#advanced-scenarios)
7. [API Reference](#api-reference)

## Getting Started

To get started with the TestFramework, include it in your test files:

```elixir
alias HydepwnsLiveview.Resources.TestFramework
```markdown

The framework is designed to test event-sourced resources, which are modules that:

1. Have an `initial_state/0` function
2. Have an `apply_event/2` function
3. Emit events when commands are executed
4. Have a `resource_type/0` function

## Basic Concepts

### Test Context

The test context is a map that holds the current state of the test, including:

- `resource_module`: The module being tested
- `resource_type`: The type of resource (e.g., "user", "post", "todo")
- `resource_id`: The ID of the test resource
- `initial_state`: The initial state of the resource
- `current_state`: The current state after events/commands
- `events`: The sequence of events that have been applied
- `errors`: Any errors encountered during testing

### Commands and Events

In event sourcing:

- **Commands** are functions that attempt to modify the state and may generate events
- **Events** are immutable facts that describe what happened and are used to build state
- **State** is derived by applying events in sequence

The TestFramework provides tools for testing each aspect of this pattern.

## Testing Patterns

### Scenario Testing

Scenario testing involves defining a sequence of commands and verifying the resulting state:

```elixir
scenario = fn context ->
  context
  |> TestFramework.when_command(fn _state -> Resource.create("Test") end)
  |> TestFramework.when_command(fn state -> Resource.update(state, "Updated") end)
  |> TestFramework.then_state(fn state -> state.title == "Updated" end)
end

TestFramework.scenario_test(ResourceModule, scenario)
```markdown

### Property-Based Testing

Property testing verifies that certain properties hold true across random event sequences:

```elixir
property = fn context ->
  # Define a property that should hold regardless of event sequence
  TestFramework.then_state(context, fn state -> 
    # Property assertion here
    true
  end)
end

TestFramework.property_test(ResourceModule, property, iterations: 100)
```markdown

### Command Helpers

Command helpers make tests more readable by creating named, reusable command functions:

```elixir
create_resource = TestFramework.command_helper(
  :create_resource,
  fn _state, args -> Resource.create(args.name) end,
  fn args, _ctx -> [%{type: "created", data: %{name: args.name}}] end
)

# Use in a scenario
{_, create_fn} = create_resource
context |> create_fn.(%{name: "Test"})
```markdown

## Test Suites

Test suites group multiple related tests:

```elixir
test_cases = %{
  "create_resource" => fn context -> ... end,
  "update_resource" => fn context -> ... end,
  "delete_resource" => fn context -> ... end
}

TestFramework.test_suite(ResourceModule, test_cases)
```markdown

## Advanced Techniques

### Custom Event Generation

For complex scenarios, you can generate custom event sequences:

```elixir
events = [
  %Event{type: "created", resource_type: "resource", resource_id: "r1", data: %{...}},
  %Event{type: "updated", resource_type: "resource", resource_id: "r1", data: %{...}}
]

context |> TestFramework.given_events(events)
```markdown

### Stateful Testing

Verify specific aspects of the state:

```elixir
context |> TestFramework.then_fields(%{
  name: "Expected Name",
  status: "active",
  count: 5
})
```markdown

## Best Practices

1. **Write Descriptive Tests**: Name your test cases clearly to describe the behavior being tested
2. **Test Edge Cases**: Include tests for error conditions and boundary conditions
3. **Keep Tests Independent**: Tests should not depend on the state from previous tests
4. **Use Command Helpers**: Extract reusable command patterns for clarity
5. **Verify Both Events and State**: Test that both the events generated and the resulting state are correct
6. **Use Property Testing for Invariants**: Use property testing to verify that important invariants hold across many different event sequences

## Examples

See the `HydepwnsLiveview.Resources.TestFrameworkExamples` module for complete, runnable examples of each testing pattern.

### Basic Scenario

```elixir
scenario = fn context ->
  context
  |> TestFramework.when_command(
    fn _state -> Resource.create("New Item") end,
    [%{type: "created"}] # Expected event
  )
  |> TestFramework.then_state(fn state -> 
    state.title == "New Item" && state.status == "active"
  end)
end
```markdown

### State Verification

```elixir
context
|> TestFramework.given_events([%Event{type: "created", ...}])
|> TestFramework.then_fields(%{
  title: "Expected Title",
  active: true,
  count: 0
})
```markdown

### Example Command Helpers

```elixir
create_helper = TestFramework.command_helper(
  :create,
  fn _state, args -> Resource.create(args.title) end
)

update_helper = TestFramework.command_helper(
  :update,
  fn state, args -> Resource.update_title(state, args.title) end
)

# In a test
{_, create} = create_helper
{_, update} = update_helper

context
|> create.(%{title: "Original"})
|> update.(%{title: "Updated"})
```markdown

## Property Testing

```elixir
property = fn context ->
  # Property: If item is archived, it remains archived
  was_archived = Enum.any?(context.events, &(&1.type == "archived"))
  
  if was_archived do
    TestFramework.then_state(context, fn state -> state.status == "archived" end)
  else
    context # No assertion needed
  end
end
```markdown

### Advanced Scenarios

```elixir
# Create a complex initial state with multiple events
initial_events = [...]
context
|> TestFramework.given_events(initial_events)
|> TestFramework.when_command(...)
|> TestFramework.then_state(...)
```markdown

## API Reference

See the `TestFramework` module documentation for a complete API reference, including:

- `resource_test/2`
- `when_command/3`
- `given_events/2`
- `then_state/2`
- `then_fields/2`
- `command_helper/3`
- `scenario_test/2`
- `property_test/3`
- `test_suite/2` 

## References

- [Project Documentation](../README.md)
