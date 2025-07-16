defmodule HydepwnsLiveview.Events.ResourceEventGenerator do
  @moduledoc """
  Utility module for generating events related to resources.

  This module provides functions to create and publish events
  for resource-related operations like create, update, delete, etc.
  """

  alias HydepwnsLiveview.Events.Core.Event

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

    IO.puts("ResourceEventGenerator: Creating event of type #{event_data.type} for resource #{event_data.resource_id}")

    # Create the event
    case Event.create(
      event_data.type,
      %{
        resource_type: resource_type,
        resource_id: event_data.resource_id,
        data: event_data.data || %{},
        metadata: event_data.metadata || %{}
      }
    ) do
      {:ok, event} ->
        IO.puts("ResourceEventGenerator: Event created successfully, attempting to store")

        # Store the event in the database
        case HydepwnsLiveview.Events.Core.EventStore.store_event(event) do
          {:ok, stored_event} ->
            IO.puts("ResourceEventGenerator: Event stored successfully, publishing to EventBus")
            # Publish the event
            HydepwnsLiveview.Events.EventBus.publish(stored_event)
            {:ok, stored_event}

          {:error, reason} ->
            IO.puts("ResourceEventGenerator: Failed to store event: #{inspect(reason)}")
            {:error, reason}
        end

      {:error, changeset} ->
        IO.puts("ResourceEventGenerator: Failed to create event: #{inspect(changeset.errors)}")
        {:error, changeset}
    end
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

  defp extract_resource_type(module_or_struct) do
    cond do
      is_atom(module_or_struct) ->
        module_or_struct
        |> Module.split()
        |> List.last()
        |> String.replace("Resource", "")
        |> Macro.underscore()
        |> case do
          "" -> "resource"
          type -> type
        end
      is_map(module_or_struct) and Map.has_key?(module_or_struct, :type) ->
        to_string(module_or_struct.type)
      is_map(module_or_struct) and Map.has_key?(module_or_struct, :__struct__) ->
        module_or_struct.__struct__
        |> Module.split()
        |> List.last()
        |> String.replace("Resource", "")
        |> Macro.underscore()
      true ->
        "resource"
    end
  end
end
