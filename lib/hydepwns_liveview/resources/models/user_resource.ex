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

  defstruct [
    :id,
    :name,
    :email,
    :role,
    :settings,
    :permissions,
    :active,
    :last_login,
    :team_id,
    :__resource_module__
  ]

  @doc """
  Returns the initial state for a user resource as a struct.
  """
  def initial_state do
    %__MODULE__{
      id: nil,
      name: nil,
      email: nil,
      role: "viewer",
      settings: %{theme: "system", notifications: true, sidebar_collapsed: false},
      permissions: [],
      active: true,
      last_login: nil,
      team_id: nil,
      __resource_module__: __MODULE__
    }
  end

  @doc """
  Applies an event to the user resource state, always returning a struct.
  """
  def apply_event(event, %__MODULE__{} = state) do
    # Example: handle event types, fallback to merging event data
    case event.type do
      "user.created" ->
        struct(state, Map.merge(Map.from_struct(state), event.data))

      "user.updated" ->
        struct(state, Map.merge(Map.from_struct(state), event.data))

      "user.deleted" ->
        %{state | active: false}

      _ ->
        struct(state, Map.merge(Map.from_struct(state), event.data || %{}))
    end
  end

  @doc """
  Loads a user resource by ID.

  This is a stub implementation for testing purposes.
  In a real application, this would fetch the user from a database.
  """
  @spec load(String.t()) :: {:ok, map()} | {:error, any()}
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

  @doc """
  Updates a user resource with tracking (for audit/telemetry).

  ## Parameters
  * `resource` - The user resource to update
  * `updates` - The update parameters
  * `metadata` - Additional metadata for the update
  * `opts` - Optional context/options (unused)

  ## Returns
  * `{:ok, updated_resource}` or `{:error, reason}`
  """
  @spec update_with_tracking(map(), map(), map(), map()) :: {:ok, map()} | {:error, any()}
  def update_with_tracking(resource, updates, metadata, _opts \\ %{}) do
    # If update/3 is defined, use it; otherwise, return error
    if function_exported?(__MODULE__, :update, 3) do
      apply(__MODULE__, :update, [resource, updates, metadata])
    else
      {:error, "update/3 not implemented for UserResource"}
    end
  end

  @doc """
  Returns the resource type for this module.
  """
  def resource_type, do: "user"

  # Returns an Ecto.Changeset for use in LiveView forms
  def changeset(attrs) when is_map(attrs) do
    attrs = for {k, v} <- attrs, into: %{}, do: {to_string(k), v}

    types = %{
      id: :string,
      name: :string,
      email: :string,
      role: :string,
      settings: :map,
      permissions: {:array, :string},
      active: :boolean,
      last_login: :utc_datetime,
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

  @doc """
  Validates a user resource map or struct. Returns {:ok, struct} or {:error, errors}.

  # NOTE: Do not use this directly in LiveView forms or controllers. Use `changeset/1` for form validation.
  """
  def validate(attrs) when is_map(attrs) do
    errors = []

    errors =
      if is_nil(attrs["email"]) or attrs["email"] == "",
        do: [{:email, "Email can't be blank"} | errors],
        else: errors

    errors =
      if attrs["email"] && !String.contains?(attrs["email"], "@"),
        do: [{:email, "Email must contain @"} | errors],
        else: errors

    errors =
      if is_nil(attrs["name"]) or attrs["name"] == "",
        do: [{:name, "Name can't be blank"} | errors],
        else: errors

    if errors == [], do: {:ok, struct(__MODULE__, attrs)}, else: {:error, errors}
  end

  @doc """
  Executes a validation plan for the resource.

  ## Parameters
  * `resource` - The resource to validate
  * `plan` - The validation plan to execute

  ## Returns
  * `{:ok, validated_resource}` or `{:error, errors}`
  """
  def execute_validation_plan(resource, plan) do
    case validate_deep(resource) do
      {:ok, validated} -> {:ok, validated}
      {:error, errors} -> {:error, errors}
    end
  end

  @doc """
  Resolves a relationship for the resource.

  ## Parameters
  * `resource` - The resource to resolve the relationship for
  * `relationship` - The relationship to resolve

  ## Returns
  * `{:ok, resolved_resource}` or `{:error, reason}`
  """
  def resolve_relationship(resource, relationship) do
    case relationship do
      :team ->
        if resource.team_id do
          case HydepwnsLiveview.Resources.TeamResource.load(resource.team_id) do
            {:ok, team} -> {:ok, Map.put(resource, :team, team)}
            error -> error
          end
        else
          {:ok, resource}
        end

      :posts ->
        {:ok, Map.put(resource, :posts, [])}

      _ ->
        {:error, "Unknown relationship: #{relationship}"}
    end
  end

  @doc """
  Resolves validation dependencies for the resource.

  ## Returns
  * `{:ok, dependencies}` or `{:error, reason}`
  """
  def resolve_validation_dependencies do
    {:ok,
     [
       email_must_be_valid: &validate_email/1,
       name_must_not_be_empty: &validate_name/1
     ]}
  end

  @doc """
  Performs deep validation of the resource, including nested attributes and relationships.

  ## Parameters
  * `resource` - The resource to validate

  ## Returns
  * `{:ok, validated_resource}` or `{:error, errors}`
  """
  def validate_deep(resource) do
    with {:ok, validated} <- validate(resource),
         {:ok, with_team} <- resolve_relationship(validated, :team),
         {:ok, with_posts} <- resolve_relationship(with_team, :posts) do
      {:ok, with_posts}
    else
      {:error, errors} -> {:error, errors}
    end
  end

  # Private validation functions
  defp validate_email(resource) do
    if resource.email && String.contains?(resource.email, "@") do
      :ok
    else
      {:error, "Email must contain @"}
    end
  end

  defp validate_name(resource) do
    if resource.name && String.length(resource.name) > 0 do
      :ok
    else
      {:error, "Name cannot be empty"}
    end
  end

  defp validate_plan(_plan) do
    :ok
  end
end
