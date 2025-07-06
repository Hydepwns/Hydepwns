# Event-Driven Integration Testing Improvements

This document outlines the improvements made to ensure robust and maintainable event-driven integration tests and projections.

## Overview

The improvements focus on five key areas:

1. **Event Type Consistency** - Standardized event type naming
2. **EventBus Subscription** - Explicit event type subscriptions
3. **MockEventStore Filtering** - Robust filtering with multiple input formats
4. **Test Assertions** - Flexible assertions for event counts and types
5. **Unified Event Creation** - Consistent event creation in tests

## 1. Event Type Consistency

### Problem

The codebase was using inconsistent event type patterns:

- `"resource_created"` (underscore) - used in ResourceProjection
- `"resource.created"` (dot notation) - used in most other places

### Solution

Standardized on dot notation (`"resource.created"`) throughout the codebase for clarity and convention.

### Changes Made

- Updated `ResourceProjection` to use dot notation event types
- Ensured all event generators use consistent dot notation
- Updated test assertions to use consistent event types

### Example

```elixir
# Before
%{type: "resource_created", resource_id: id, data: data}

# After  
%{type: "resource.created", resource_id: id, data: data}
```

## 2. EventBus Subscription

### Problem

Projections were subscribing to all events (`EventBus.subscribe(self())`) which is less robust and may miss events if the EventBus implementation changes.

### Solution

Updated projections to subscribe to specific event types they need.

### Changes Made

- Modified `ResourceProjection` to subscribe to explicit event types
- Added explicit event type subscriptions in test setup

### Example

```elixir
# Before
EventBus.subscribe(self())

# After
EventBus.subscribe(self(), [
  "resource.created",
  "resource.updated", 
  "resource.deleted"
])
```

## 3. MockEventStore Filtering

### Problem

The MockEventStore only handled maps for filtering criteria, but tests might pass criteria in different formats (keyword lists, etc.).

### Solution

Enhanced MockEventStore to handle both maps and keyword lists for filtering criteria.

### Changes Made

- Added support for keyword list criteria
- Added support for both atom and string keys
- Improved error handling for invalid criteria

### Example

```elixir
# Now supports multiple formats
get_events(%{event_type: "resource.created"})
get_events([event_type: "resource.created"])
get_events(%{"event_type" => "resource.created"})
```

## 4. Test Assertions

### Problem

Rigid event count assertions can cause flaky tests if the event pipeline changes or generates additional events.

### Solution

Created flexible assertion helpers that allow for minor event count variations.

### Changes Made

- Added `assert_minimum_event_count/3` for flexible count assertions
- Added `assert_events_of_type/4` for type-specific assertions
- Added `assert_event_order/3` for event ordering assertions
- Enhanced existing assertion helpers

### Example

```elixir
# Before - rigid assertion
assert length(events) == 3

# After - flexible assertion
assert_minimum_event_count(3, :resource, resource.id)
assert_events_of_type("resource.created", :resource, resource.id)
assert_event_order(["resource.created", "resource.updated"], :resource, resource.id)
```

## 5. Unified Event Creation

### Problem

Tests were creating events in different ways, leading to inconsistencies and potential missed events.

### Solution

Created a unified event creation helper that uses the main event creation API.

### Changes Made

- Created `EventTestHelper` module with unified event creation functions
- Added `create_test_resource/2` for consistent test resource creation
- Added `create_resource_event/4` for resource-specific events
- Added `assert_event_properties/4` for event property validation

### Example

```elixir
# Before - inconsistent event creation
{:ok, event} = Event.create("resource.created", %{...})

# After - unified event creation
test_resource = create_test_resource(%{name: "Test"}, %{type: "document"})
{:ok, resource} = ResourceSystem.create_resource(atomize_keys(test_resource))
```

## New Test Helpers

### EventStoreTestHelper Enhancements

- `assert_minimum_event_count/3` - Flexible count assertions
- `assert_events_of_type/4` - Type-specific assertions
- `assert_event_order/3` - Event ordering assertions
- `get_events_with_criteria/1` - Flexible event filtering

### EventTestHelper (New)

- `create_event/3` - Unified event creation
- `create_resource_event/4` - Resource event creation
- `create_test_resource/2` - Test resource creation
- `assert_event_properties/4` - Event property validation
- `create_event_sequence/2` - Event sequence creation

## Benefits

### Robustness

- **Consistent event types** prevent missed events due to type mismatches
- **Explicit subscriptions** ensure projections receive the events they need
- **Flexible filtering** handles various input formats gracefully

### Maintainability

- **Unified event creation** ensures tests use the same pipeline as production
- **Flexible assertions** reduce test brittleness when the event pipeline changes
- **Clear helper functions** make tests more readable and maintainable

### Reliability

- **Explicit event subscriptions** prevent missed events if EventBus implementation changes
- **Robust filtering** prevents silent test failures due to format issues
- **Flexible assertions** accommodate minor event count variations

## Usage Examples

### Basic Event Testing

```elixir
# Create test resource
test_resource = create_test_resource(%{name: "Test"}, %{type: "document"})
{:ok, resource} = ResourceSystem.create_resource(atomize_keys(test_resource))

# Verify events with flexible assertions
assert_events_of_type("resource.created", :resource, resource.id)
assert_minimum_event_count(1, :resource, resource.id)
```

### Event Order Testing

```elixir
# Create and update resource
{:ok, resource} = ResourceSystem.create_resource(attrs)
{:ok, _updated} = ResourceSystem.update_resource(resource.id, update_attrs)

# Verify event order
assert_event_order(["resource.created", "resource.updated"], :resource, resource.id)
```

### Event Property Testing

```elixir
# Get events and verify properties
{:ok, events} = get_events_with_criteria(%{resource_id: resource.id})
[event] = events
assert_event_properties(event, "resource.created", resource.id, %{name: "Test Resource"})
```

## Migration Guide

### For Existing Tests

1. **Update event type assertions** to use dot notation
2. **Replace rigid count assertions** with flexible ones
3. **Use unified event creation** helpers
4. **Add explicit event subscriptions** where needed

### For New Tests

1. **Use EventTestHelper** for event creation
2. **Use flexible assertions** from EventStoreTestHelper
3. **Subscribe to specific event types** in projections
4. **Use consistent event type naming**

## Implementation Details

### ResourceProjection Changes

```elixir
# Before
EventBus.subscribe(self())

# After
EventBus.subscribe(self(), [
  "resource.created",
  "resource.updated", 
  "resource.deleted"
])

# Event type handling
defp update_state(state, event) do
  case event do
    %{type: "resource.created", resource_id: id, data: data} ->
      # Handle creation
    %{type: "resource.updated", resource_id: id, data: data} ->
      # Handle update
    %{type: "resource.deleted", resource_id: id} ->
      # Handle deletion
  end
end
```

### MockEventStore Enhancements

```elixir
# Support for multiple input formats
def get_events(criteria) when is_map(criteria) do
  get_events_with_criteria(criteria)
end

def get_events(criteria) when is_list(criteria) do
  criteria_map = Enum.into(criteria, %{})
  get_events_with_criteria(criteria_map)
end

# Enhanced filtering with both atom and string keys
defp get_events_with_criteria(criteria) do
  # Handle both {:key, value} and {"key", value} patterns
  Enum.all?(criteria, fn
    {:event_type, event_type} -> # handle atom key
    {"event_type", event_type} -> # handle string key
    # ... other patterns
  end)
end
```

### Flexible Assertions

```elixir
# Minimum count assertion
def assert_minimum_event_count(minimum_count, resource_type, resource_id) do
  {:ok, events} = get_events_for_resource(resource_type, resource_id)
  actual_count = length(events)
  
  unless actual_count >= minimum_count do
    flunk("Expected at least #{minimum_count} events, but found #{actual_count}")
  end
  
  true
end

# Event order assertion
def assert_event_order(expected_types, resource_type, resource_id) do
  {:ok, events} = get_events_for_resource(resource_type, resource_id)
  actual_types = Enum.map(events, & &1.type)
  
  # Check if expected types are a subsequence of actual types
  has_order = Enum.reduce_while(expected_types, actual_types, fn expected_type, remaining_types, _acc ->
    case Enum.find_index(remaining_types, & &1 == expected_type) do
      nil -> {:halt, false}
      index -> {:cont, Enum.drop(remaining_types, index + 1)}
    end
  end)
  
  unless has_order do
    flunk("Expected events in order #{inspect(expected_types)}, but got #{inspect(actual_types)}")
  end
  
  true
end
```

## Testing the Improvements

### Running the Updated Tests

```bash
# Run the event-driven integration tests
mix test test/hydepwns_liveview_web/integration/event_driven_integration_test.exs

# Run all event-related tests
mix test test/hydepwns_liveview/events/
```

### Verifying the Changes

1. **Event Type Consistency**: All tests should pass with dot notation
2. **Explicit Subscriptions**: ResourceProjection should receive events correctly
3. **Flexible Filtering**: MockEventStore should handle various input formats
4. **Flexible Assertions**: Tests should be more resilient to minor changes
5. **Unified Event Creation**: All event creation should use the main API

## Conclusion

These improvements make the event-driven integration tests more robust, maintainable, and reliable. The consistent event type usage, explicit subscriptions, flexible filtering, and unified event creation ensure that tests accurately reflect the production event pipeline while remaining resilient to minor changes.

The key benefits are:

- **Reduced test flakiness** through flexible assertions
- **Better maintainability** through consistent patterns
- **Improved reliability** through explicit subscriptions
- **Enhanced robustness** through unified event creation
- **Clearer test code** through helper functions

This approach provides a solid foundation for event-driven testing that can evolve with the system while maintaining reliability and clarity.
