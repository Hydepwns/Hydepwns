defmodule HydepwnsLiveview.Events.EventStore do
  @moduledoc """
  Bridge module for the Event Store.

  This module delegates to HydepwnsLiveview.Events.Core.EventStore,
  which is the actual implementation of the event store.

  This module exists to maintain backward compatibility with code that
  expects the event store to be at this module path.
  """

  alias HydepwnsLiveview.Events.Core.EventStore, as: CoreEventStore

  defdelegate start_link(opts), to: CoreEventStore
  defdelegate child_spec(opts), to: CoreEventStore

  # Delegate all public functions to the core implementation
  defdelegate store_event(event), to: CoreEventStore
  # Keep store/1 for backward compatibility
  def store(event), do: store_event(event)

  defdelegate get_events_for_resource(resource_type, resource_id), to: CoreEventStore
  defdelegate get_events_by_type(event_type), to: CoreEventStore

  # Clear function delegations with matching names
  defdelegate get_events(criteria \\ %{}), to: CoreEventStore
  defdelegate get_event(id), to: CoreEventStore
  defdelegate get_latest_snapshot(resource_type, resource_id), to: CoreEventStore

  defdelegate save_snapshot(resource_type, resource_id, state, metadata \\ %{}),
    to: CoreEventStore

  # Explicitly delegate to matching function names
  defdelegate get_snapshots(resource_type, resource_id), to: CoreEventStore
  defdelegate get_snapshot_before(resource_type, resource_id, timestamp), to: CoreEventStore

  defdelegate get_events_between(resource_type, resource_id, start_time, end_time, opts \\ %{}),
    to: CoreEventStore

  # Additional useful delegations
  defdelegate count_events_since_last_snapshot(resource_type, resource_id), to: CoreEventStore
  defdelegate event_stream(criteria \\ %{}), to: CoreEventStore
  defdelegate count_events(criteria \\ %{}), to: CoreEventStore

  # Add documentation about maintenance of this bridge module
  @doc """
  Note: This bridge module is maintained for backward compatibility.
  When adding new event store functionality, ensure:
  1. The core implementation in HydepwnsLiveview.Events.Core.EventStore is updated
  2. A corresponding delegation is added to this module
  """
end
