defmodule HydepwnsLiveview.Events.ResourceIntegration.ResourceEventIntegration do
  @moduledoc """
  Main entry point for the Resource Event System integration.

  This module brings together all components of the resource event system and
  provides a unified API for working with event-driven resources. It serves as
  the primary integration point between the resource system and event system.

  Features:
  - Transactional resource operations with event generation
  - Event-sourced resource management
  - Event replay capabilities
  - Event-driven UI updates
  - Resource history and versioning
  """

  import Phoenix.LiveView, only: [connected?: 1]

  alias HydepwnsLiveview.Events.Core.Event
  alias HydepwnsLiveview.Events.Core.EventBus
  alias HydepwnsLiveview.Events.Core.EventStore
  alias HydepwnsLiveview.Events.ResourceIntegration.ResourceEventGenerator
  alias HydepwnsLiveview.Events.ResourceIntegration.TransactionalResourceChanges
  alias HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResource
  alias HydepwnsLiveview.Events.ResourceIntegration.ResourceReplay
  alias HydepwnsLiveview.Events.Handlers.LiveEventUpdater

  @doc """
  Creates a resource with events in a transaction.

  This is a unified entry point for creating resources that handles both
  traditional and event-sourced resources appropriately.

  ## Parameters
  * `resource_module` - The resource module
  * `params` - The params to create the resource with
  * `metadata` - Additional metadata for the event

  ## Returns
  * `{:ok, resource, events}` - The resource was created and events stored
  * `{:error, reason}` - The resource creation failed
  """
  def create_resource(resource_module, params, metadata \\ %{}) do
    # Check if this is an event-sourced resource
    if is_event_sourced_resource?(resource_module) do
      case resource_module.create(params) do
        {:ok, resource} -> {:ok, resource, []}
        error -> error
      end
    else
      # Use transactional resource changes for regular resources
      TransactionalResourceChanges.create_resource(resource_module, params, metadata)
    end
  end

  @doc """
  Updates a resource with events in a transaction.

  This is a unified entry point for updating resources that handles both
  traditional and event-sourced resources appropriately.

  ## Parameters
  * `resource_module` - The resource module
  * `id` - The resource ID or the resource itself
  * `params` - The params to update the resource with
  * `metadata` - Additional metadata for the event

  ## Returns
  * `{:ok, resource, events}` - The resource was updated and events stored
  * `{:error, reason}` - The resource update failed
  """
  def update_resource(resource_module, id_or_resource, params, metadata \\ %{}) do
    # Check if this is an event-sourced resource
    if is_event_sourced_resource?(resource_module) do
      # Get the resource if needed
      with {:ok, resource} <- get_resource(resource_module, id_or_resource) do
        case resource_module.update(resource, params, metadata) do
          {:ok, updated_resource} -> {:ok, updated_resource, []}
          error -> error
        end
      end
    else
      # Extract ID if a resource was passed
      id = get_id(id_or_resource)

      # Use transactional resource changes for regular resources
      TransactionalResourceChanges.update_resource(resource_module, id, params, metadata)
    end
  end

  @doc """
  Deletes a resource with events in a transaction.

  This is a unified entry point for deleting resources that handles both
  traditional and event-sourced resources appropriately.

  ## Parameters
  * `resource_module` - The resource module
  * `id` - The resource ID or the resource itself
  * `metadata` - Additional metadata for the event

  ## Returns
  * `{:ok, resource, events}` - The resource was deleted and events stored
  * `{:error, reason}` - The resource deletion failed
  """
  def delete_resource(resource_module, id_or_resource, metadata \\ %{}) do
    # Check if this is an event-sourced resource
    if is_event_sourced_resource?(resource_module) do
      # Get the resource if needed
      with {:ok, resource} <- get_resource(resource_module, id_or_resource) do
        case resource_module.delete(resource, metadata) do
          {:ok, deleted_resource} -> {:ok, deleted_resource, []}
          error -> error
        end
      end
    else
      # Extract ID if a resource was passed
      id = get_id(id_or_resource)

      # Use transactional resource changes for regular resources
      TransactionalResourceChanges.delete_resource(resource_module, id, metadata)
    end
  end

  @doc """
  Executes a command on a resource with event generation.

  This is primarily for event-sourced resources that support commands.

  ## Parameters
  * `resource_module` - The resource module
  * `id` - The resource ID
  * `command` - The command to execute
  * `params` - Parameters for the command
  * `metadata` - Additional metadata for the events

  ## Returns
  * `{:ok, updated_resource}` - The command was executed successfully
  * `{:error, reason}` - The command could not be executed
  """
  def execute_command(resource_module, id, command, params \\ %{}, metadata \\ %{}) do
    if is_event_sourced_resource?(resource_module) do
      resource_module.execute(id, command, params, metadata)
    else
      {:error, :not_event_sourced}
    end
  end

  @doc """
  Gets a resource by ID.

  This is a unified entry point for retrieving resources that handles both
  traditional and event-sourced resources appropriately.

  ## Parameters
  * `resource_module` - The resource module
  * `id` - The resource ID

  ## Returns
  * `{:ok, resource}` - The resource was found
  * `{:error, reason}` - The resource could not be retrieved
  """
  def get_resource(resource_module, id) when is_binary(id) or is_integer(id) do
    if is_event_sourced_resource?(resource_module) do
      resource_module.get(id)
    else
      # Use whatever get function the resource module provides
      resource_module.get(id)
    end
  end

  # If a resource was passed instead of an ID, return it directly
  def get_resource(_resource_module, resource) when is_map(resource) do
    {:ok, resource}
  end

  @doc """
  Gets a resource at a specific point in time.

  This is only supported for event-sourced resources.

  ## Parameters
  * `resource_module` - The resource module
  * `id` - The resource ID
  * `timestamp` - The point in time to retrieve the resource at

  ## Returns
  * `{:ok, resource}` - The resource was found at that point in time
  * `{:error, reason}` - The resource could not be retrieved
  """
  def get_resource_at(resource_module, id, timestamp) do
    if is_event_sourced_resource?(resource_module) do
      resource_module.get_at(id, timestamp)
    else
      {:error, :not_event_sourced}
    end
  end

  @doc """
  Gets the history of events for a resource.

  ## Parameters
  * `resource_module` - The resource module
  * `id` - The resource ID
  * `opts` - Options for filtering events

  ## Returns
  * `{:ok, events}` - The events for the resource
  * `{:error, reason}` - Could not retrieve events
  """
  def get_resource_history(resource_module, id, opts \\ %{}) do
    resource_type = get_resource_type(resource_module)
    EventStore.get_events(resource_type, id, opts)
  end

  @doc """
  Creates a point-in-time replay for a resource.

  ## Parameters
  * `resource_module` - The resource module
  * `id` - The resource ID
  * `point_in_time` - The DateTime to replay to
  * `opts` - Additional options

  ## Returns
  * `{:ok, replay_id}` - Replay was created successfully
  * `{:error, reason}` - Failed to create replay
  """
  def create_replay(resource_module, id, point_in_time, opts \\ []) do
    if is_event_sourced_resource?(resource_module) do
      ResourceReplay.create_point_in_time_replay(resource_module, id, point_in_time, opts)
    else
      {:error, :not_event_sourced}
    end
  end

  @doc """
  Executes a replay and returns the reconstructed resource state.

  ## Parameters
  * `replay_id` - The ID of the replay session
  * `resource_module` - The resource module

  ## Returns
  * `{:ok, state}` - The reconstructed state
  * `{:error, reason}` - Failed to execute replay
  """
  def execute_replay(replay_id, resource_module) do
    if is_event_sourced_resource?(resource_module) do
      ResourceReplay.execute_replay(replay_id, resource_module)
    else
      {:error, :not_event_sourced}
    end
  end

  @doc """
  Creates an event-driven LiveView component.

  This is a convenience function that wraps LiveEventUpdater.live_event_component.

  ## Parameters
  * Same as LiveEventUpdater.live_event_component

  ## Returns
  * A LiveComponent definition
  """
  defmacro event_driven_component(name, opts \\ [], do_block) do
    quote do
      LiveEventUpdater.live_event_component(unquote(name), unquote(opts), unquote(do_block))
    end
  end

  @doc """
  Subscribes a LiveView to resource events.

  ## Parameters
  * `socket` - The LiveView socket
  * `event_types` - List of event types to subscribe to, or `:all` for all events
  * `resource_type` - The resource type to subscribe to
  * `resource_id` - The resource ID to subscribe to

  ## Returns
  * `socket` - The updated socket
  """
  def subscribe_to_resource_events(socket, event_types \\ :all, resource_type, resource_id) do
    if connected?(socket) do
      LiveEventUpdater.subscribe_to_resources(event_types, [{resource_type, resource_id}])
    end

    socket
  end

  @doc """
  Handles a resource event in a LiveView.

  ## Parameters
  * `event` - The event to handle
  * `socket` - The LiveView socket
  * `handlers` - Map of event type patterns to handler functions
  * `default_handler` - Optional function to handle events that don't match any pattern

  ## Returns
  * Updated socket
  """
  def handle_resource_event(event, socket, handlers, default_handler \\ nil) do
    LiveEventUpdater.handle_event_update(socket, event, handlers, default_handler)
  end

  # Private functions

  # Check if a module is an event-sourced resource
  defp is_event_sourced_resource?(module) do
    # Check if the module implements the EventSourcedResource behavior
    function_exported?(module, :apply_event, 2) and
      function_exported?(module, :initial_state, 0) and
      function_exported?(module, :resource_type, 0)
  end

  # Get resource ID from either an ID or a resource
  defp get_id(id) when is_binary(id) or is_integer(id), do: id
  defp get_id(resource) when is_map(resource), do: resource.id

  # Get resource type from a module
  defp get_resource_type(module) do
    if function_exported?(module, :resource_type, 0) do
      module.resource_type()
    else
      # Try to infer from module name
      module
      |> Atom.to_string()
      |> String.split(".")
      |> List.last()
      |> then(fn name -> String.replace(name, "Resource", "") end)
      |> String.downcase()
    end
  end
end
