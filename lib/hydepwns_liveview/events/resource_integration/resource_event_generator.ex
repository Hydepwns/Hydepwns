defmodule HydepwnsLiveview.Events.ResourceIntegration.ResourceEventGenerator do
  @moduledoc """
  Generates events from resource changes.

  This module provides functionality to automatically generate events
  when resources are created, updated, or deleted.
  """

  alias HydepwnsLiveview.Events.Event

  @doc """
  Generates and publishes an event for a resource creation.

  ## Parameters

  * `resource` - The resource that was created
  * `metadata` - Additional metadata about the creation

  ## Returns

  * `{:ok, event}` - The event was created and published successfully
  * `{:error, reason}` - The event creation or publishing failed
  """
  def resource_created(resource, metadata \\ %{}) do
    with {:ok, resource_info} <- extract_resource_info(resource),
         {:ok, event} <-
           Event.create("#{resource_info.type}.created", %{
             resource_id: resource_info.id,
             resource_type: resource_info.type,
             data: resource_info.data,
             metadata: Map.merge(%{action: "create"}, metadata)
           }),
         :ok <- HydepwnsLiveview.Events.EventBus.publish(event) do
      {:ok, event}
    else
      error -> error
    end
  end

  @doc """
  Generates and publishes an event for a resource update.

  ## Parameters

  * `resource` - The resource that was updated
  * `changes` - Map of changes that were made (optional)
  * `metadata` - Additional metadata about the update

  ## Returns

  * `{:ok, event}` - The event was created and published successfully
  * `{:error, reason}` - The event creation or publishing failed
  """
  def resource_updated(resource, changes \\ %{}, metadata \\ %{}) do
    with {:ok, resource_info} <- extract_resource_info(resource),
         {:ok, event} <-
           Event.create("#{resource_info.type}.updated", %{
             resource_id: resource_info.id,
             resource_type: resource_info.type,
             data: Map.merge(resource_info.data, %{changes: changes}),
             metadata: Map.merge(%{action: "update"}, metadata)
           }),
         :ok <- HydepwnsLiveview.Events.EventBus.publish(event) do
      {:ok, event}
    else
      error -> error
    end
  end

  @doc """
  Generates and publishes an event for a resource deletion.

  ## Parameters

  * `resource` - The resource that was deleted
  * `metadata` - Additional metadata about the deletion

  ## Returns

  * `{:ok, event}` - The event was created and published successfully
  * `{:error, reason}` - The event creation or publishing failed
  """
  def resource_deleted(resource, metadata \\ %{}) do
    with {:ok, resource_info} <- extract_resource_info(resource),
         {:ok, event} <-
           Event.create("#{resource_info.type}.deleted", %{
             resource_id: resource_info.id,
             resource_type: resource_info.type,
             data: resource_info.data,
             metadata: Map.merge(%{action: "delete"}, metadata)
           }),
         :ok <- HydepwnsLiveview.Events.EventBus.publish(event) do
      {:ok, event}
    else
      error -> error
    end
  end

  @doc """
  Generates and publishes a custom event for a resource.

  ## Parameters

  * `resource` - The related resource
  * `event_type` - The custom event type suffix (e.g. "activated")
  * `data` - The event data
  * `metadata` - Additional metadata about the event

  ## Returns

  * `{:ok, event}` - The event was created and published successfully
  * `{:error, reason}` - The event creation or publishing failed
  """
  def resource_event(resource, event_type, data \\ %{}, metadata \\ %{}) do
    with {:ok, resource_info} <- extract_resource_info(resource),
         {:ok, event} <-
           Event.create("#{resource_info.type}.#{event_type}", %{
             resource_id: resource_info.id,
             resource_type: resource_info.type,
             data: Map.merge(resource_info.data, data),
             metadata: metadata
           }),
         :ok <- HydepwnsLiveview.Events.EventBus.publish(event) do
      {:ok, event}
    else
      error -> error
    end
  end

  # Private functions

  # Extracts essential information from a resource
  defp extract_resource_info(resource) do
    cond do
      # Handle maps with __resource_module__ field
      is_map(resource) && Map.has_key?(resource, :__resource_module__) ->
        resource_module = resource.__resource_module__
        resource_type = resource_type_from_module(resource_module)

        {:ok,
         %{
           id: extract_id(resource),
           type: resource_type,
           data: Map.drop(resource, [:__resource_module__, :__meta__, :__struct__])
         }}

      # Handle structs with __meta__ field (likely Ecto schemas)
      is_map(resource) && Map.has_key?(resource, :__struct__) && Map.has_key?(resource, :__meta__) ->
        resource_type = resource_type_from_module(resource.__struct__)

        {:ok,
         %{
           id: extract_id(resource),
           type: resource_type,
           data: Map.drop(resource, [:__meta__, :__struct__])
         }}

      # Handle simple maps with an ID
      is_map(resource) && (Map.has_key?(resource, :id) || Map.has_key?(resource, "id")) ->
        # Try to determine type from map keys
        type = infer_resource_type(resource)

        {:ok,
         %{
           id: extract_id(resource),
           type: type,
           data: resource
         }}

      true ->
        {:error, :invalid_resource}
    end
  end

  # Extracts the ID from a resource
  defp extract_id(resource) do
    cond do
      Map.has_key?(resource, :id) -> resource.id
      Map.has_key?(resource, "id") -> resource["id"]
      true -> raise ArgumentError, "Resource must have an ID"
    end
  end

  # Converts a module name to a resource type string
  defp resource_type_from_module(module) do
    module
    |> Atom.to_string()
    |> String.split(".")
    |> List.last()
    |> then(fn name -> String.replace(name, "Resource", "") end)
    |> String.downcase()
  end

  # Infers a resource type from a map of attributes
  defp infer_resource_type(resource) do
    cond do
      Map.has_key?(resource, :type) -> resource.type
      Map.has_key?(resource, "type") -> resource["type"]
      Map.has_key?(resource, :name) || Map.has_key?(resource, "name") -> "user"
      Map.has_key?(resource, :title) || Map.has_key?(resource, "title") -> "post"
      Map.has_key?(resource, :email) || Map.has_key?(resource, "email") -> "user"
      true -> "resource"
    end
  end
end
