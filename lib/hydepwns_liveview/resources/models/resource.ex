defmodule HydepwnsLiveview.ResourceSystem.Models.Resource do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "resources" do
    field :name, :string
    field :type, :string
    field :status, :string
    field :description, :string
    field :content, :string
    field :parent_id, :binary_id
    field :child_ids, {:array, :binary_id}
    field :metadata, :map
    field :tags, {:array, :string}
    field :categories, {:array, :string}

    timestamps()
  end

  @doc false
  def changeset(resource, attrs) do
    resource
    |> cast(attrs, [:name, :type, :status, :description, :content, :parent_id, :child_ids, :metadata, :tags, :categories])
    |> validate_required([:name, :type, :status])
  end
end 