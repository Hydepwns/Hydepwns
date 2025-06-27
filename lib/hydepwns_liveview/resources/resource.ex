defmodule HydepwnsLiveview.Resources.Resource do
  @moduledoc """
  Schema and changeset functions for Resources in the application.

  This module defines a generic resource entity that can be categorized, tagged,
  and structured in hierarchical relationships through parent-child associations.
  Resources contain customizable content, metadata and settings as map fields.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "resources" do
    field :name, :string
    field :type, :string
    field :status, :string
    field :description, :string
    field :content, :map, default: %{}
    field :metadata, :map, default: %{}
    field :settings, :map, default: %{}
    field :version, :integer, default: 1
    field :parent_id, :binary_id
    field :child_ids, {:array, :binary_id}
    field :tags, {:array, :string}
    field :categories, {:array, :string}
    field :created_by, :binary_id
    field :updated_by, :binary_id

    timestamps(type: :utc_datetime_usec)
  end

  @doc """
  Creates a changeset for resource records.

  Validates required fields and ensures data integrity for the resource.
  Also validates relationships and data format consistency.
  """
  def changeset(resource, attrs) do
    resource
    |> cast(attrs, [
      :name,
      :type,
      :status,
      :description,
      :content,
      :metadata,
      :settings,
      :version,
      :parent_id,
      :child_ids,
      :tags,
      :categories,
      :created_by,
      :updated_by
    ])
    |> validate_required([:name, :type, :status])
    |> validate_length(:name, min: 3, max: 255)
    |> validate_inclusion(:status, ["draft", "published", "archived", "deleted"])
    |> validate_number(:version, greater_than: 0)
    |> validate_format(:type, ~r/^[a-z][a-z0-9_]*$/,
      message:
        "must start with a lowercase letter and only contain lowercase letters, numbers, and underscores"
    )
    |> validate_circular_relationship()
    |> validate_relationship_type()
  end

  defp validate_circular_relationship(changeset) do
    parent_id = get_field(changeset, :parent_id)
    id = get_field(changeset, :id)
    
    cond do
      !parent_id || !id ->
        changeset
      parent_id == id ->
        add_error(changeset, :parent_id, "Circular relationship detected")
      would_create_circular_relationship?(id, parent_id) ->
        add_error(changeset, :parent_id, "Circular relationship detected")
      true ->
        changeset
    end
  end

  defp would_create_circular_relationship?(child_id, parent_id) do
    # Check if setting parent_id would create a circular relationship
    # by traversing up the parent chain from the potential parent
    check_parent_chain(parent_id, child_id, MapSet.new())
  end

  defp check_parent_chain(current_id, target_id, visited) do
    cond do
      MapSet.member?(visited, current_id) ->
        false
      current_id == target_id ->
        true
      true ->
        visited = MapSet.put(visited, current_id)
        
        case HydepwnsLiveview.Resources.ResourceSystem.get_resource(current_id) do
          {:ok, %{parent_id: parent_id}} when not is_nil(parent_id) ->
            check_parent_chain(parent_id, target_id, visited)
          _ ->
            false
        end
    end
  end

  defp validate_relationship_type(changeset) do
    parent_id = get_field(changeset, :parent_id)
    resource_type = get_field(changeset, :type)
    
    cond do
      !parent_id ->
        changeset
      true ->
        case HydepwnsLiveview.Resources.ResourceSystem.get_resource(parent_id) do
          {:ok, parent_resource} ->
            if is_incompatible_relationship?(parent_resource.type, resource_type) do
              add_error(changeset, :parent_id, "Incompatible resource types")
            else
              changeset
            end
          _ ->
            changeset
        end
    end
  end

  defp is_incompatible_relationship?(parent_type, child_type) do
    # Define incompatible relationships
    # Document can't be parent of folder
    parent_type == "document" && child_type == "folder"
  end
end
