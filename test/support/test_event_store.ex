defmodule HydepwnsLiveview.Events.EventStore do
  @moduledoc """
  Test-specific EventStore module that delegates to MockEventStore during tests.
  
  This module is only used during tests and provides the same API as the real EventStore
  but delegates all operations to the MockEventStore for in-memory testing.
  """

  alias HydepwnsLiveview.TestSupport.MockEventStore

  @doc """
  Stores a single event in the mock event store.
  """
  def store_event(event, metadata \\ %{}) do
    MockEventStore.store_event(event, metadata)
  end

  @doc """
  Stores a single event with the given type and data.
  """
  def store_event(type, data) do
    event = %{
      type: type,
      data: data,
      resource_id: data[:resource_id] || data[:id],
      resource_type: data[:resource_type] || "unknown"
    }
    MockEventStore.store_event(event, %{})
  end

  @doc """
  Retrieves all events for a specific resource.
  """
  def get_events_for_resource(resource_type, resource_id) do
    MockEventStore.get_events_for_resource(resource_type, resource_id)
  end

  @doc """
  Retrieves all events for a specific resource with options.
  """
  def get_events_for_resource(resource_type, resource_id, _opts) do
    MockEventStore.get_events_for_resource(resource_type, resource_id)
  end

  @doc """
  Retrieves events for a resource up to a specific point in time.
  """
  def get_events_for_resource_at(resource_type, resource_id, timestamp) do
    MockEventStore.get_events_for_resource_at(resource_type, resource_id, timestamp)
  end

  @doc """
  Retrieves events based on the given criteria.
  """
  def get_events(criteria) do
    MockEventStore.get_events(criteria)
  end

  @doc """
  Retrieves a single event by its ID.
  """
  def get_event(id) do
    MockEventStore.get_event(id)
  end

  @doc """
  Lists all events in the mock event store.
  """
  def list_all_events do
    MockEventStore.get_all_events()
  end

  @doc """
  Creates a new replay session (stub implementation for tests).
  """
  def create_replay_session(name, resource_type, resource_id, opts \\ []) do
    {:ok, %{id: "test-session-#{System.unique_integer()}", name: name, resource_type: resource_type, resource_id: resource_id}}
  end

  @doc """
  Gets a replay session by ID (stub implementation for tests).
  """
  def get_replay_session(session_id) do
    {:ok, %{id: session_id, status: "pending"}}
  end

  @doc """
  Lists all replay sessions (stub implementation for tests).
  """
  def list_replay_sessions do
    {:ok, []}
  end

  @doc """
  Gets snapshots for a resource (stub implementation for tests).
  """
  def get_snapshots(resource_type, resource_id) do
    {:ok, []}
  end

  @doc """
  Gets the latest snapshot for a resource (stub implementation for tests).
  """
  def get_latest_snapshot(resource_type, resource_id) do
    {:error, :not_found}
  end

  @doc """
  Saves a snapshot (stub implementation for tests).
  """
  def save_snapshot(resource_type, resource_id, state, metadata) do
    {:ok, %{id: "snapshot-#{System.unique_integer()}", resource_type: resource_type, resource_id: resource_id}}
  end
end 