defmodule HydepwnsLiveview.TestSupport.EventStoreTestHelper do
  @moduledoc """
  Test helper for setting up and managing the mock event store in tests.
  
  This module provides utilities to:
  - Start the mock event store
  - Reset the event store state between tests
  - Provide helper functions for common event store operations in tests
  """

  import ExUnit.Assertions
  alias HydepwnsLiveview.TestSupport.MockEventStore

  @doc """
  Sets up the mock event store for a test.
  This should be called in the setup block of any test that uses event-sourced resources.
  """
  def setup_mock_event_store do
    {:ok, _} = MockEventStore.start_link([])
    :ok
  end

  @doc """
  Resets the mock event store to a clean state.
  This should be called between tests to ensure isolation.
  """
  def reset_mock_event_store do
    MockEventStore.reset()
  end

  @doc """
  Gets all events from the mock event store.
  Useful for assertions in tests.
  """
  def get_all_events do
    MockEventStore.get_all_events()
  end

  @doc """
  Gets events for a specific resource from the mock event store.
  
  ## Parameters
  * `resource_type` - The type of resource (as atom)
  * `resource_id` - The ID of the resource
  
  ## Returns
  * List of events for the resource
  """
  def get_events_for_resource(resource_type, resource_id) do
    MockEventStore.get_events_for_resource(resource_type, resource_id)
  end

  @doc """
  Asserts that a specific event exists in the mock event store.
  
  ## Parameters
  * `event_type` - The type of event to look for
  * `resource_type` - The type of resource (as atom)
  * `resource_id` - The ID of the resource
  
  ## Returns
  * `true` if the event exists, raises an assertion error otherwise
  """
  def assert_event_exists(event_type, resource_type, resource_id) do
    {:ok, events} = get_events_for_resource(resource_type, resource_id)
    
    event_exists? = Enum.any?(events, fn event ->
      event.type == event_type
    end)
    
    unless event_exists? do
      flunk("Expected event of type '#{event_type}' for resource #{resource_type}:#{resource_id}, but it was not found")
    end
    
    true
  end

  @doc """
  Asserts that no events exist for a specific resource.
  
  ## Parameters
  * `resource_type` - The type of resource (as atom)
  * `resource_id` - The ID of the resource
  
  ## Returns
  * `true` if no events exist, raises an assertion error otherwise
  """
  def assert_no_events_for_resource(resource_type, resource_id) do
    {:ok, events} = get_events_for_resource(resource_type, resource_id)
    
    unless Enum.empty?(events) do
      flunk("Expected no events for resource #{resource_type}:#{resource_id}, but found #{length(events)} events")
    end
    
    true
  end

  @doc """
  Asserts that a specific number of events exist for a resource.
  
  ## Parameters
  * `expected_count` - The expected number of events
  * `resource_type` - The type of resource (as atom)
  * `resource_id` - The ID of the resource
  
  ## Returns
  * `true` if the count matches, raises an assertion error otherwise
  """
  def assert_event_count(expected_count, resource_type, resource_id) do
    {:ok, events} = get_events_for_resource(resource_type, resource_id)
    actual_count = length(events)
    
    unless actual_count == expected_count do
      flunk("Expected #{expected_count} events for resource #{resource_type}:#{resource_id}, but found #{actual_count}")
    end
    
    true
  end
end 