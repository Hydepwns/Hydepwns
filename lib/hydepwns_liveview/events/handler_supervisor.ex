defmodule HydepwnsLiveview.Events.HandlerSupervisor do
  @moduledoc """
  Bridge module for the Handler Supervisor.

  This module delegates to HydepwnsLiveview.Events.Handlers.HandlerSupervisor,
  which is the actual implementation of the handler supervisor.

  This module exists to maintain backward compatibility with code that
  expects the handler supervisor to be at this module path.
  """

  alias HydepwnsLiveview.Events.Handlers.HandlerSupervisor, as: CoreHandlerSupervisor

  # Process lifecycle functions
  defdelegate start_link(opts), to: CoreHandlerSupervisor
  defdelegate child_spec(opts), to: CoreHandlerSupervisor

  # Handler management functions
  defdelegate list_handlers(), to: CoreHandlerSupervisor

  @doc """
  Note: This bridge module is maintained for backward compatibility.
  When adding new handler supervisor functionality, ensure:
  1. The core implementation in HydepwnsLiveview.Events.Handlers.HandlerSupervisor is updated
  2. A corresponding delegation is added to this module
  """
end
