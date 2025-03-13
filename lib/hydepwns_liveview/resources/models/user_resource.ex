defmodule HydepwnsLiveview.Resources.UserResource do
  @moduledoc """
  Defines the User resource for LiveViews.

  This resource uses the ResourceDSL to define
  attributes, validations, and relationships for a User entity.
  """

  use HydepwnsLiveview.Utils.ResourceDSL

  attribute(:id, :string, required: true)
  attribute(:name, :string, required: true)
  attribute(:email, :string, format: ~r/@/)
  attribute(:role, {:one_of, ["admin", "editor", "viewer"]}, default: "viewer")

  attribute :settings, :map do
    attribute(:theme, {:one_of, ["light", "dark", "system"]}, default: "system")
    attribute(:notifications, :boolean, default: true)
    attribute(:sidebar_collapsed, :boolean, default: false)
  end

  attribute(:permissions, {:list, :string}, default: [])
  attribute(:active, :boolean, default: true)
  attribute(:last_login, :datetime)

  has_many(:posts, HydepwnsLiveview.Resources.PostResource)
  belongs_to(:team, HydepwnsLiveview.Resources.TeamResource)

  # Define a through relationship to get team members through the team
  has_many_through(:team_members, through: [:team, :members])

  # Define a polymorphic relationship for content ownership
  polymorphic(:manageable,
    types: [
      HydepwnsLiveview.Resources.PostResource,
      HydepwnsLiveview.Resources.TeamResource
    ]
  )

  validate(:email_must_be_valid, fn resource ->
    if resource.email && String.contains?(resource.email, "@") do
      :ok
    else
      {:error, "Email must contain @"}
    end
  end)

  validate(:name_must_not_be_empty, fn resource ->
    if resource.name && String.length(resource.name) > 0 do
      :ok
    else
      {:error, "Name cannot be empty"}
    end
  end)

  @doc """
  Loads a user resource by ID.

  This is a stub implementation for testing purposes.
  In a real application, this would fetch the user from a database.
  """
  def load(id) do
    # This is a simple stub that always returns a user with the given ID
    # In a real application, this would query the database
    user = %{
      id: id,
      name: "User #{id}",
      email: "user_#{id}@example.com",
      role: "viewer",
      permissions: [],
      active: true,
      settings: %{
        theme: "system",
        notifications: true,
        sidebar_collapsed: false
      },
      team_id: "team-1",
      __resource_module__: __MODULE__
    }

    {:ok, user}
  end
end
