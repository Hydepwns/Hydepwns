defmodule HydepwnsLiveview.Events.EventBus do
  @moduledoc """
  Bridge module for the Event Bus.

  This module delegates to HydepwnsLiveview.Events.Core.EventBus,
  which is the actual implementation of the event bus.

  This module exists to maintain backward compatibility with code that
  expects the event bus to be at this module path.
  """

  alias HydepwnsLiveview.Events.Core.EventBus, as: CoreEventBus

  defdelegate start_link(opts), to: CoreEventBus
  defdelegate child_spec(opts), to: CoreEventBus

  # Delegate all public functions to the core implementation
  defdelegate subscribe(subscriber, event_types), to: CoreEventBus
  defdelegate unsubscribe(subscriber, event_types), to: CoreEventBus
  defdelegate publish(event), to: CoreEventBus

  # Add any other functions that might be called on EventBus
  # For example:
  # defdelegate some_function(args), to: CoreEventBus
end
