defmodule HydepwnsLiveview.Events.ResourceEventGenerator do
  @moduledoc """
  Utility module for generating events related to resources.

  This module provides functions to create and publish events
  for resource-related operations like create, update, delete, etc.
  """

  alias HydepwnsLiveview.Events.Event

  @doc """
  Generate and publish an event for a resource.

  ## Parameters

  * `resource_module` - The module of the resource (e.g., UserResource)
  * `event` - The event data to publish

  ## Returns

  * `{:ok, event}` - The event was published successfully
  * `{:error, reason}` - The event failed to publish
  """
  def generate_event(resource_module, event_data) when is_map(event_data) do
    # Extract resource type from module name
    resource_type = extract_resource_type(resource_module)

    # Create the event
    {:ok, event} =
      Event.create(
        event_data.type,
        %{
          resource_type: resource_type,
          resource_id: event_data.resource_id,
          data: event_data.data || %{},
          metadata: event_data.metadata || %{}
        }
      )

    # Publish the event
    HydepwnsLiveview.Events.EventBus.publish(event)

    {:ok, event}
  end

  @doc """
  Generate a resource created event.

  ## Parameters

  * `resource_module` - The module of the resource
  * `resource_id` - The ID of the created resource
  * `data` - Additional data about the creation
  * `metadata` - Additional metadata about the event

  ## Returns

  * `{:ok, event}` - The event was published successfully
  * `{:error, reason}` - The event failed to publish
  """
  def resource_created(resource_module, resource_id, data \\ %{}, metadata \\ %{}) do
    generate_event(resource_module, %{
      type: "#{extract_resource_type(resource_module)}.created",
      resource_id: resource_id,
      data: data,
      metadata: metadata
    })
  end

  @doc """
  Generate a resource updated event.

  ## Parameters

  * `resource_module` - The module of the resource
  * `resource_id` - The ID of the updated resource
  * `data` - Additional data about the update
  * `metadata` - Additional metadata about the event

  ## Returns

  * `{:ok, event}` - The event was published successfully
  * `{:error, reason}` - The event failed to publish
  """
  def resource_updated(resource_module, resource_id, data \\ %{}, metadata \\ %{}) do
    generate_event(resource_module, %{
      type: "#{extract_resource_type(resource_module)}.updated",
      resource_id: resource_id,
      data: data,
      metadata: metadata
    })
  end

  @doc """
  Generate a resource deleted event.

  ## Parameters

  * `resource_module` - The module of the resource
  * `resource_id` - The ID of the deleted resource
  * `data` - Additional data about the deletion
  * `metadata` - Additional metadata about the event

  ## Returns

  * `{:ok, event}` - The event was published successfully
  * `{:error, reason}` - The event failed to publish
  """
  def resource_deleted(resource_module, resource_id, data \\ %{}, metadata \\ %{}) do
    generate_event(resource_module, %{
      type: "#{extract_resource_type(resource_module)}.deleted",
      resource_id: resource_id,
      data: data,
      metadata: metadata
    })
  end

  # Private functions

  # Extract the resource type from the module name
  # Example: HydepwnsLiveview.Resources.UserResource -> "user"
  defp extract_resource_type(module) when is_atom(module) do
    module
    |> to_string()
    |> String.split(".")
    |> List.last()
    |> String.replace("Resource", "")
    |> String.downcase()
  end
end
