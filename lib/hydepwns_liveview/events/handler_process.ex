defmodule HydepwnsLiveview.Events.HandlerProcess do
  @moduledoc """
  Bridge module for the Handler Process.

  This module delegates to HydepwnsLiveview.Events.Handlers.HandlerProcess,
  which is the actual implementation of the handler process.

  This module exists to maintain backward compatibility with code that
  expects the handler process to be at this module path.
  """

  alias HydepwnsLiveview.Events.Handlers.HandlerProcess, as: CoreHandlerProcess

  # Process lifecycle functions
  defdelegate start_link(opts), to: CoreHandlerProcess
  defdelegate child_spec(opts), to: CoreHandlerProcess

  # Event handling functions
  defdelegate handle_event(handler_pid, event), to: CoreHandlerProcess

  @doc """
  Note: This bridge module is maintained for backward compatibility.
  When adding new handler process functionality, ensure:
  1. The core implementation in HydepwnsLiveview.Events.Handlers.HandlerProcess is updated
  2. A corresponding delegation is added to this module
  """
end
