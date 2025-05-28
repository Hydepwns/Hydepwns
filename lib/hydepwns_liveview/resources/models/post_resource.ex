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
  @spec load(String.t()) :: {:ok, map()} | {:error, any()}
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

  @doc """
  Updates a post resource with tracking (for audit/telemetry).

  ## Parameters
  * `resource` - The post resource to update
  * `updates` - The update parameters
  * `metadata` - Additional metadata for the update
  * `opts` - Optional context/options (unused)

  ## Returns
  * `{:ok, updated_resource}` or `{:error, reason}`
  """
  @spec update_with_tracking(map(), map(), map(), map()) :: {:ok, map()} | {:error, any()}
  def update_with_tracking(resource, updates, metadata, _opts \\ %{}) do
    HydepwnsLiveview.Utils.ChangeTracker.track_change(resource, updates, metadata)
  end

  defstruct [
    :id,
    :title,
    :content,
    :published,
    :created_at,
    :updated_at,
    :author_id,
    :team_id,
    :__resource_module__
  ]

  @doc """
  Returns the initial state for a post resource as a struct.
  """
  def initial_state do
    %__MODULE__{
      id: nil,
      title: nil,
      content: nil,
      published: false,
      created_at: nil,
      updated_at: nil,
      author_id: nil,
      team_id: nil,
      __resource_module__: __MODULE__
    }
  end

  @doc """
  Applies an event to the post resource state, always returning a struct.
  """
  def apply_event(event, %__MODULE__{} = state) do
    case event.type do
      "post.created" ->
        struct(state, Map.merge(Map.from_struct(state), event.data))
      "post.updated" ->
        struct(state, Map.merge(Map.from_struct(state), event.data))
      "post.deleted" ->
        %{state | published: false}
      _ ->
        struct(state, Map.merge(Map.from_struct(state), event.data || %{}))
    end
  end

  @doc """
  Returns the resource type for this module.
  """
  def resource_type, do: "post"

  @doc """
  Validates a post resource map or struct. Returns {:ok, struct} or {:error, errors}.
  
  # NOTE: Do not use this directly in LiveView forms or controllers. Use `changeset/1` for form validation.
  """
  def validate(attrs) when is_map(attrs) do
    errors = []
    errors = if is_nil(attrs["title"]) or attrs["title"] == "", do: [{:title, "Title cannot be empty"} | errors], else: errors
    if errors == [], do: {:ok, struct(__MODULE__, attrs)}, else: {:error, errors}
  end

  def changeset(attrs) when is_map(attrs) do
    attrs = for {k, v} <- attrs, into: %{}, do: {to_string(k), v}
    types = %{
      id: :string,
      title: :string,
      content: :string,
      published: :boolean,
      created_at: :utc_datetime,
      updated_at: :utc_datetime,
      author_id: :string,
      team_id: :string
    }
    case validate(attrs) do
      {:ok, _struct} ->
        {%{}, types}
        |> Ecto.Changeset.cast(attrs, Map.keys(types))
      {:error, errors} ->
        changeset = {%{}, types} |> Ecto.Changeset.cast(attrs, Map.keys(types))
        Enum.reduce(errors, changeset, fn {field, msg}, cs ->
          Ecto.Changeset.add_error(cs, field, msg)
        end)
    end
  end
  def changeset(_), do: Ecto.Changeset.change(%{})
end
