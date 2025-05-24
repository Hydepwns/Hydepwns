defmodule HydepwnsLiveview.Events.ProjectionSupervisor do
  @moduledoc """
  Bridge module for the Projection Supervisor.

  This module delegates to HydepwnsLiveview.Events.Projections.ProjectionSupervisor,
  which is the actual implementation of the projection supervisor.

  This module exists to maintain backward compatibility with code that
  expects the projection supervisor to be at this module path.
  """

  alias HydepwnsLiveview.Events.Projections.ProjectionSupervisor, as: CoreProjectionSupervisor

  # Process lifecycle functions
  defdelegate start_link(opts), to: CoreProjectionSupervisor
  defdelegate child_spec(opts), to: CoreProjectionSupervisor

  # Core projection management functions
  defdelegate register_standard_projections(), to: CoreProjectionSupervisor
  defdelegate start_projection(projection_module, opts \\ []), to: CoreProjectionSupervisor
  defdelegate stop_projection(pid), to: CoreProjectionSupervisor

  # Projection inspection and management functions
  defdelegate list_projections(), to: CoreProjectionSupervisor
  defdelegate get_projection_state(pid), to: CoreProjectionSupervisor
  defdelegate rebuild_projection(pid), to: CoreProjectionSupervisor

  @doc """
  Note: This bridge module is maintained for backward compatibility.
  When adding new projection supervisor functionality, ensure:
  1. The core implementation in HydepwnsLiveview.Events.Projections.ProjectionSupervisor is updated
  2. A corresponding delegation is added to this module
  """
end
