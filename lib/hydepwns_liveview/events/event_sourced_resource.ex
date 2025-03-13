defmodule HydepwnsLiveview.Events.EventSourcedResource do
  @moduledoc """
  Bridge module for the Event Sourced Resource.

  This module delegates to HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResource,
  which is the actual implementation of the event sourced resource.

  This module exists to maintain backward compatibility with code that
  expects the event sourced resource to be at this module path.
  """

  alias HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResource,
    as: CoreEventSourcedResource

  # Delegate all public functions to the core implementation with matching names
  defdelegate rebuild_from_events(events, initial_state, apply_event_fn),
    to: CoreEventSourcedResource

  defdelegate get_current_state(resource_module, id), to: CoreEventSourcedResource
  defdelegate list_resources(resource_module), to: CoreEventSourcedResource

  defdelegate create_event(resource_module, id, event_type, data, metadata \\ %{}),
    to: CoreEventSourcedResource

  defdelegate set_snapshot_interval(resource_module, interval), to: CoreEventSourcedResource

  # Maintain compatibility with the older function signature 
  # (if it was used with module as the first parameter)
  def rebuild_from_events(resource_module, initial_state, events) do
    CoreEventSourcedResource.rebuild_from_events(
      events,
      initial_state,
      &resource_module.apply_event/2
    )
  end

  @doc """
  Note: This bridge module is maintained for backward compatibility.
  When adding new event sourced resource functionality, ensure:
  1. The core implementation in HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResource is updated
  2. A corresponding delegation is added to this module
  """
end
