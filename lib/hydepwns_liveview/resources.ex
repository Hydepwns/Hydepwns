defmodule HydepwnsLiveview.Resources do
  @moduledoc """
  Main interface for working with resources in the system.
  This module provides common functions for CRUD operations on resources.
  """

  alias HydepwnsLiveview.Resources.DocumentResource
  alias HydepwnsLiveview.Resources.RelationshipManager
  alias HydepwnsLiveview.Resources.ResourceSystem

  @doc """
  Gets a resource by id.
  """
  def get_resource!(id) do
    case ResourceSystem.get_resource(id) do
      {:ok, resource} -> resource
      {:error, :not_found} -> 
        # For now, create a mock resource for testing
        # In a real implementation, this would likely fetch from a database
        struct(DocumentResource, %{
          id: id,
          name: "Test Resource",
          content: %{text: "Test content for resource #{id}"},
          description: "A test resource for development",
          status: "active",
          type: "document",
          parent_id: nil
        })
    end
  end

  @doc """
  Updates a resource with the given params.
  """
  def update_resource(resource, params) do
    # Convert string keys to atom keys in params
    atom_params = for {k, v} <- params, into: %{}, do: {String.to_existing_atom(k), v}
    ResourceSystem.update_resource(resource.id, atom_params)
  end

  @doc """
  Deletes a resource by id.
  """
  def delete_resource(id) do
    ResourceSystem.delete_resource(id)
  end

  @doc """
  Creates a changeset for a resource.
  """
  def change_resource(resource, attrs \\ %{}) do
    DocumentResource.changeset(resource, attrs)
  end

  @doc """
  Creates a new resource with the given params.
  """
  def create_resource(params) do
    # Convert string keys to atom keys in params
    atom_params = for {k, v} <- params, into: %{}, do: {String.to_existing_atom(k), v}
    ResourceSystem.create_resource(atom_params)
  end

  @doc """
  Lists all resources.
  """
  def list_resources do
    ResourceSystem.list_resources()
  end

  @doc """
  Lists child resources for a given parent resource ID.
  """
  def list_child_resources(parent_id) do
    list_resources()
    |> Enum.filter(&(&1.parent_id == parent_id))
  end

  @doc """
  Creates a relationship between two resources.
  """
  def create_relationship(parent_id, child_id) do
    case RelationshipManager.create_relationship(parent_id, child_id, "parent_child") do
      {:ok, relationship} ->
        # Update the child resource with the parent_id
        child = get_resource!(child_id)
        update_resource(child, %{parent_id: parent_id})
        {:ok, relationship}
      error -> error
    end
  end

  @doc """
  Removes a relationship between two resources.
  """
  def remove_relationship(parent_id, child_id) do
    # Update the child resource to remove the parent_id
    child = get_resource!(child_id)
    update_resource(child, %{parent_id: nil})
    {:ok, struct(DocumentResource, %{parent_id: parent_id, id: child_id})}
  end
end