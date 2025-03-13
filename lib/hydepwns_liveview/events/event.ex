defmodule HydepwnsLiveview.Events.Event do
  @moduledoc """
  Bridge module for the Event structure.

  This module delegates to HydepwnsLiveview.Events.Core.Event,
  which is the actual implementation of the event structure.

  This module exists to maintain backward compatibility with code that
  expects the event structure to be at this module path.
  """

  alias HydepwnsLiveview.Events.Core.Event, as: CoreEvent

  # Delegate all public functions to the core implementation
  defdelegate create(type, attrs), to: CoreEvent

  # Add any other functions that might be called on Event
  # For example:
  # defdelegate some_function(args), to: CoreEvent
end
