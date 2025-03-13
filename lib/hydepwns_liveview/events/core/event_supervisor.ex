defmodule HydepwnsLiveview.Events.Core.EventSupervisor do
  @moduledoc """
  Top-level supervisor for the Resource Event System.

  This supervisor manages all components of the event system:
  - EventBus: Distributes events to subscribers
  - EventStore: Persists events to the database
  - HandlerSupervisor: Manages event handlers
  - ProjectionSupervisor: Manages projections
  """

  use Supervisor
  require Logger

  alias HydepwnsLiveview.Events.EventBus
  alias HydepwnsLiveview.Events.EventStore
  alias HydepwnsLiveview.Events.HandlerSupervisor
  alias HydepwnsLiveview.Events.ProjectionSupervisor
  alias HydepwnsLiveview.Events.StandardHandlers

  @doc """
  Starts the event system supervisor.
  """
  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      # Event bus for distributing events
      {EventBus, []},

      # Event store for persisting events
      {EventStore, []},

      # Handler supervisor for managing event handlers
      {HandlerSupervisor, []},

      # Projection supervisor for managing projections
      {ProjectionSupervisor, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  @doc """
  Registers standard projections that should be started with the application.

  This is called after the application has started to ensure all dependencies
  are available.
  """
  def register_standard_projections do
    if function_exported?(ProjectionSupervisor, :register_standard_projections, 0) do
      ProjectionSupervisor.register_standard_projections()
    else
      Logger.warn("ProjectionSupervisor does not export register_standard_projections/0")
    end
  end

  @doc """
  Registers standard handlers that should be started with the application.

  This is called after the application has started to ensure all dependencies
  are available.
  """
  def register_standard_handlers do
    if function_exported?(StandardHandlers, :register_handlers, 0) do
      StandardHandlers.register_handlers()
    else
      Logger.warn("StandardHandlers does not export register_handlers/0")
    end
  end
end
