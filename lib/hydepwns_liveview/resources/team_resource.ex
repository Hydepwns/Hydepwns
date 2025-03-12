defmodule HydepwnsLiveview.Resources.TeamResource do
  @moduledoc """
  Defines the Team resource for LiveViews.

  This is a stub implementation to satisfy relationships in UserResource.
  """

  use HydepwnsLiveview.Utils.LiveViewResource

  # Define attributes directly as module attributes
  @attributes [
    %{name: :id, type: :string, required: true},
    %{name: :name, type: :string, required: true},
    %{name: :description, type: :string},
    %{name: :created_at, type: :datetime},
    %{name: :active, type: :boolean, default: true}
  ]

  # Override the attributes function
  def attributes, do: @attributes

  # Define relationships directly as module attributes
  @relationships [
    %{
      name: :members,
      type: :has_many,
      resource: HydepwnsLiveview.Resources.UserResource,
      cardinality: :many
    },
    %{
      name: :posts,
      type: :has_many,
      resource: HydepwnsLiveview.Resources.PostResource,
      cardinality: :many
    }
  ]

  # Override the relationships function
  def relationships, do: @relationships

  # Define validations directly in the function
  def validations do
    [
      %{
        name: :name_not_empty,
        validation_fn: fn resource ->
          if resource.name && String.length(resource.name) > 0 do
            :ok
          else
            {:error, "Team name cannot be empty"}
          end
        end
      }
    ]
  end
end
