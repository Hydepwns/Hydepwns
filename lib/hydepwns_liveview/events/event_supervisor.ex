defmodule HydepwnsLiveview.Events.EventSupervisor do
  @moduledoc """
  Supervisor for the Resource Event System.

  This module delegates to HydepwnsLiveview.Events.Core.EventSupervisor,
  which is the actual implementation of the event system supervisor.

  This module exists to maintain backward compatibility with code that
  expects the supervisor to be at this module path.
  """

  use Supervisor
  require Logger

  @doc """
  Starts the event system supervisor.
  """
  def start_link(init_arg) do
    HydepwnsLiveview.Events.Core.EventSupervisor.start_link(init_arg)
  end

  @doc """
  Registers standard projections that should be started with the application.
  """
  def register_standard_projections do
    HydepwnsLiveview.Events.Core.EventSupervisor.register_standard_projections()
  end

  @doc """
  Registers standard handlers that should be started with the application.
  """
  def register_standard_handlers do
    HydepwnsLiveview.Events.Core.EventSupervisor.register_standard_handlers()
  end
end
