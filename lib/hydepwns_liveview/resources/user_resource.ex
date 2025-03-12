defmodule HydepwnsLiveview.Resources.UserResource do
  @moduledoc """
  Defines the User resource for LiveViews.

  This resource uses the new LiveViewResource behavior to define
  attributes, validations, and relationships for a User entity.
  """

  use HydepwnsLiveview.Utils.LiveViewResource

  # Define attributes directly as module attributes
  @attributes [
    %{name: :id, type: :string, required: true},
    %{name: :name, type: :string, required: true},
    %{name: :email, type: :string, format: ~r/@/},
    %{name: :role, type: {:one_of, ["admin", "editor", "viewer"]}, default: "viewer"},
    %{
      name: :settings,
      type: :map,
      nested_attributes: [
        %{name: :theme, type: {:one_of, ["light", "dark", "system"]}, default: "system"},
        %{name: :notifications, type: :boolean, default: true},
        %{name: :sidebar_collapsed, type: :boolean, default: false}
      ]
    },
    %{name: :permissions, type: {:list, :string}, default: []},
    %{name: :active, type: :boolean, default: true},
    %{name: :last_login, type: :datetime}
  ]

  # Override the attributes function
  def attributes, do: @attributes

  # Define relationships directly as module attributes
  @relationships [
    %{
      name: :posts,
      type: :has_many,
      resource: HydepwnsLiveview.Resources.PostResource,
      cardinality: :many
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
        name: :email_must_be_valid,
        validation_fn: fn resource ->
          if resource.email && String.contains?(resource.email, "@") do
            :ok
          else
            {:error, "Email must contain @"}
          end
        end
      },
      %{
        name: :name_must_not_be_empty,
        validation_fn: fn resource ->
          if resource.name && String.length(resource.name) > 0 do
            :ok
          else
            {:error, "Name cannot be empty"}
          end
        end
      }
    ]
  end
end
