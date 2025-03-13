defmodule HydepwnsLiveview.Resources.PostResource do
  @moduledoc """
  Defines the Post resource for LiveViews.

  This is a stub implementation to satisfy relationships in UserResource.
  """

  use HydepwnsLiveview.Utils.ResourceDSL

  attribute(:id, :string, required: true)
  attribute(:title, :string, required: true)
  attribute(:content, :string, required: true)
  attribute(:published, :boolean, default: false)
  attribute(:created_at, :datetime)
  attribute(:updated_at, :datetime)

  belongs_to(:author, HydepwnsLiveview.Resources.UserResource)
  belongs_to(:team, HydepwnsLiveview.Resources.TeamResource)

  # Define a polymorphic relationship for comments
  polymorphic(:commentable,
    types: [
      HydepwnsLiveview.Resources.PostResource,
      HydepwnsLiveview.Resources.UserResource
    ]
  )

  validate(:title_not_empty, fn resource ->
    if resource.title && String.length(resource.title) > 0 do
      :ok
    else
      {:error, "Title cannot be empty"}
    end
  end)

  @doc """
  Loads a post resource by ID.

  This is a stub implementation for testing purposes.
  In a real application, this would fetch the post from a database.
  """
  def load(id) do
    # This is a simple stub that always returns a post with the given ID
    # In a real application, this would query the database
    post = %{
      id: id,
      title: "Post #{id}",
      content: "Content for post #{id}",
      published: true,
      author_id: "user-1",
      team_id: "team-1",
      created_at: DateTime.utc_now(),
      updated_at: DateTime.utc_now(),
      __resource_module__: __MODULE__
    }

    {:ok, post}
  end
end
