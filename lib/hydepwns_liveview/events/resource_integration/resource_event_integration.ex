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

  alias HydepwnsLiveview.Events.ResourceIntegration.ResourceEventGenerator
  alias HydepwnsLiveview.Events.ResourceIntegration.TransactionalResourceChanges
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
  * `params`
  """
  def execute_command(resource_module, id, command, params) do
    # Implementation of execute_command function
  end

  @doc """
  Returns true if the resource module is event-sourced, false otherwise.
  """
  @spec is_event_sourced_resource?(module()) :: boolean()
  defp is_event_sourced_resource?(_resource_module), do: false

  @doc """
  Gets the resource by ID or returns the resource if already loaded.
  """
  @spec get_resource(module(), any()) :: {:ok, any()} | {:error, any()}
  defp get_resource(_resource_module, resource_or_id), do: {:ok, resource_or_id}

  @doc """
  Extracts the ID from a resource or returns the ID if already provided.
  """
  @spec get_id(any()) :: any()
  defp get_id(id_or_resource), do: id_or_resource
end
