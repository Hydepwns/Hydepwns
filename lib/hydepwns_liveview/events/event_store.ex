defmodule HydepwnsLiveview.Events.EventStore do
  @moduledoc """
  Bridge module for the Event Store.

  This module delegates to HydepwnsLiveview.Events.Core.EventStore,
  which is the actual implementation of the event store.

  This module exists to maintain backward compatibility with code that
  expects the event store to be at this module path.
  """

  alias HydepwnsLiveview.Events.Core.EventStore, as: CoreEventStore
  alias HydepwnsLiveview.Repo
  alias HydepwnsLiveview.Events.Event

  defdelegate start_link(opts), to: CoreEventStore
  defdelegate child_spec(opts), to: CoreEventStore

  # Delegate all public functions to the core implementation
  defdelegate store_event(event), to: CoreEventStore
  # Keep store/1 for backward compatibility
  def store(event), do: store_event(event)

  defdelegate get_events_for_resource(resource_type, resource_id), to: CoreEventStore

  # Clear function delegations with matching names
  defdelegate get_events(criteria \\ %{}), to: CoreEventStore
  defdelegate get_event(id), to: CoreEventStore
  defdelegate get_latest_snapshot(resource_type, resource_id), to: CoreEventStore

  defdelegate save_snapshot(resource_type, resource_id, state, metadata \\ %{}),
    to: CoreEventStore

  # Additional useful delegations
  defdelegate count_events_since_last_snapshot(resource_type, resource_id), to: CoreEventStore
  defdelegate event_stream(criteria \\ %{}), to: CoreEventStore
  defdelegate count_events(criteria \\ %{}), to: CoreEventStore

  defdelegate create_replay_session(name, resource_type, resource_id, opts \\ []),
    to: CoreEventStore

  defdelegate complete_replay_session(session_id, results), to: CoreEventStore
  defdelegate fail_replay_session(session_id, error_details), to: CoreEventStore
  defdelegate get_replay_session(session_id), to: CoreEventStore
  defdelegate get_replay_session_events(session_id), to: CoreEventStore
  defdelegate get_snapshots(resource_type, resource_id), to: CoreEventStore

  defdelegate save_versioned_state(resource_type, resource_id, state, opts \\ []),
    to: CoreEventStore

  @doc """
  Stores an event in the event store.
  """
  def store_event(event_type, event_data) do
    %Event{}
    |> Event.changeset(%{
      type: event_type,
      data: event_data,
      timestamp: DateTime.utc_now()
    })
    |> Repo.insert()
  end

  @doc """
  Gets events for a resource at a specific point in time.
  """
  def get_events_for_resource_at(resource_type, resource_id, timestamp) do
    CoreEventStore.get_events_for_resource_at(resource_type, resource_id, timestamp)
  end

  @doc """
  Updates a replay session status.
  """
  def update_replay_session_status(session_id, status) do
    CoreEventStore.update_replay_session_status(session_id, status)
  end

  @doc """
  Updates a replay session status with metadata.
  """
  def update_replay_session_status(session_id, status, metadata) do
    CoreEventStore.update_replay_session_status(session_id, status, metadata)
  end
end
