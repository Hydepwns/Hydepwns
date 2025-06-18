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
  end
end
