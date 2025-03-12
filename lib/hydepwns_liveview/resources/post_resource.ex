defmodule HydepwnsLiveview.Resources.PostResource do
  @moduledoc """
  Defines the Post resource for LiveViews.

  This is a stub implementation to satisfy relationships in UserResource.
  """

  use HydepwnsLiveview.Utils.LiveViewResource

  # Define attributes directly as module attributes
  @attributes [
    %{name: :id, type: :string, required: true},
    %{name: :title, type: :string, required: true},
    %{name: :content, type: :string, required: true},
    %{name: :published, type: :boolean, default: false},
    %{name: :created_at, type: :datetime},
    %{name: :updated_at, type: :datetime}
  ]

  # Override the attributes function
  def attributes, do: @attributes

  # Define relationships directly as module attributes
  @relationships [
    %{
      name: :author,
      type: :belongs_to,
      resource: HydepwnsLiveview.Resources.UserResource,
      cardinality: :one
    },
    %{
      name: :team,
      type: :belongs_to,
      resource: HydepwnsLiveview.Resources.TeamResource,
      cardinality: :one
    }
  ]

  # Override the relationships function
  def relationships, do: @relationships

  # Define validations directly in the function
  def validations do
    [
      %{
        name: :title_not_empty,
        validation_fn: fn resource ->
          if resource.title && String.length(resource.title) > 0 do
            :ok
          else
            {:error, "Title cannot be empty"}
          end
        end
      }
    ]
  end
end
