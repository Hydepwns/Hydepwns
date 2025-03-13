defmodule HydepwnsLiveview.Utils.RelationshipResolverTest do
  use ExUnit.Case, async: false

  alias HydepwnsLiveview.Utils.RelationshipResolver
  alias HydepwnsLiveview.Resources.UserResource
  alias HydepwnsLiveview.Resources.TeamResource
  alias HydepwnsLiveview.Resources.PostResource

  # Mock the relationships function for UserResource
  setup_all do
    # Define mock relationships
    team_relationship = %{
      name: :team,
      type: :belongs_to,
      resource: TeamResource,
      foreign_key: :team_id,
      cardinality: :one
    }

    posts_relationship = %{
      name: :posts,
      type: :has_many,
      resource: PostResource,
      foreign_key: :author_id,
      cardinality: :many
    }

    team_members_relationship = %{
      name: :team_members,
      type: :through,
      through: :team,
      target: :members,
      cardinality: :many
    }

    # Mock the relationships function
    :meck.new(UserResource, [:passthrough])

    :meck.expect(UserResource, :relationships, fn ->
      [team_relationship, posts_relationship, team_members_relationship]
    end)

    # Mock the relationships function for TeamResource
    members_relationship = %{
      name: :members,
      type: :has_many,
      resource: UserResource,
      foreign_key: :team_id,
      cardinality: :many
    }

    :meck.new(TeamResource, [:passthrough])

    :meck.expect(TeamResource, :relationships, fn ->
      [members_relationship]
    end)

    on_exit(fn ->
      if :meck.validate(UserResource) do
        :meck.unload(UserResource)
      end

      if :meck.validate(TeamResource) do
        :meck.unload(TeamResource)
      end
    end)

    :ok
  end

  # Create test data structs with metadata
  def create_test_user(attrs \\ %{}) do
    base = %{
      id: "user-1",
      name: "Test User",
      email: "test@example.com",
      team_id: "team-1",
      __resource_module__: UserResource
    }

    user = Map.merge(base, attrs)

    # Add relationship cache if provided
    case Map.get(attrs, :__relationship_cache__) do
      nil -> user
      cache -> Map.put(user, :__relationship_cache__, cache)
    end
  end

  def create_test_team(attrs \\ %{}) do
    base = %{
      id: "team-1",
      name: "Test Team",
      description: "A test team",
      __resource_module__: TeamResource
    }

    team = Map.merge(base, attrs)

    # Add relationship cache if provided
    case Map.get(attrs, :__relationship_cache__) do
      nil -> team
      cache -> Map.put(team, :__relationship_cache__, cache)
    end
  end

  def create_test_post(attrs \\ %{}) do
    base = %{
      id: "post-1",
      title: "Test Post",
      content: "Post content",
      author_id: "user-1",
      team_id: "team-1",
      __resource_module__: PostResource
    }

    post = Map.merge(base, attrs)

    # Add relationship cache if provided
    case Map.get(attrs, :__relationship_cache__) do
      nil -> post
      cache -> Map.put(post, :__relationship_cache__, cache)
    end
  end

  describe "get_relationship_definition/2" do
    test "returns relationship definition when it exists" do
      relationship = RelationshipResolver.get_relationship_definition(UserResource, :team)
      assert relationship != nil
      assert relationship.name == :team
      assert relationship.type == :belongs_to
      assert relationship.resource == TeamResource
    end

    test "returns nil when relationship doesn't exist" do
      relationship = RelationshipResolver.get_relationship_definition(UserResource, :non_existent)
      assert relationship == nil
    end
  end

  describe "get_relationships/1" do
    test "returns all relationships for a resource" do
      relationships = RelationshipResolver.get_relationships(UserResource)
      assert is_list(relationships)
      assert length(relationships) > 0

      # Check for specific relationships
      assert Enum.any?(relationships, fn r -> r.name == :team end)
      assert Enum.any?(relationships, fn r -> r.name == :posts end)
      assert Enum.any?(relationships, fn r -> r.name == :team_members end)
    end

    test "returns empty list for module without relationships" do
      defmodule EmptyResource do
        use HydepwnsLiveview.Utils.ResourceDSL
      end

      relationships = RelationshipResolver.get_relationships(EmptyResource)
      assert relationships == []
    end
  end

  describe "resolve_relationship/3" do
    # Mock the TeamResource.load function for testing
    test "resolves belongs_to relationship" do
      # Create a user with a team_id
      user = create_test_user()

      # Mock the load function
      orig_load = &TeamResource.load/1

      try do
        # Replace the load function with our mock
        :meck.expect(TeamResource, :load, fn _id ->
          {:ok, create_test_team()}
        end)

        # Test resolving the team relationship
        result = RelationshipResolver.resolve_relationship(user, :team)

        assert {:ok, team} = result
        assert team.id == "team-1"
        assert team.name == "Test Team"
        assert team.__resource_module__ == TeamResource

        # Get the updated resource from the process dictionary
        updated_user = Process.get({:resource_cache, UserResource, user.id})

        # Check that the relationship is cached
        assert updated_user != nil
        assert Map.has_key?(updated_user, :__relationship_cache__)
        assert Map.has_key?(updated_user.__relationship_cache__, :team)
      after
        # Restore the original function
        if orig_load do
          :meck.expect(TeamResource, :load, orig_load)
        end
      end
    end

    test "returns cached relationship if available" do
      # Create a team
      team = create_test_team()

      # Create a user with a cached team
      user =
        create_test_user(%{
          __relationship_cache__: %{
            team: team
          }
        })

      # Resolve the relationship (should use cache)
      result = RelationshipResolver.resolve_relationship(user, :team)

      assert {:ok, cached_team} = result
      assert cached_team.id == "team-1"
      assert cached_team.name == "Test Team"
    end

    test "returns error for non-existent relationship" do
      user = create_test_user()

      result = RelationshipResolver.resolve_relationship(user, :non_existent)

      assert {:error, _message} = result
    end

    test "returns error if resource module is missing" do
      # No __resource_module__
      user = %{id: "user-1", name: "Test User"}

      result = RelationshipResolver.resolve_relationship(user, :team)

      assert {:error, _message} = result
    end

    test "supports lazy loading" do
      user = create_test_user()

      # Mock the load function
      orig_load = &TeamResource.load/1

      try do
        # Replace the load function with our mock
        :meck.expect(TeamResource, :load, fn _id ->
          {:ok, create_test_team()}
        end)

        # Test lazy loading
        result = RelationshipResolver.resolve_relationship(user, :team, lazy: true)

        assert {:ok, loader_fn} = result
        assert is_function(loader_fn, 0)

        # Calling the loader function should return the team
        assert {:ok, team} = loader_fn.()
        assert team.id == "team-1"
        assert team.name == "Test Team"
      after
        # Restore the original function
        if orig_load do
          :meck.expect(TeamResource, :load, orig_load)
        end
      end
    end
  end

  describe "eager_load/3" do
    test "loads multiple relationships at once" do
      user = create_test_user()

      # Mock the load functions
      orig_team_load = &TeamResource.load/1
      orig_post_load = &PostResource.load/1

      try do
        # Replace the load functions with our mocks
        :meck.expect(TeamResource, :load, fn _id ->
          {:ok, create_test_team()}
        end)

        :meck.expect(PostResource, :load, fn _id ->
          {:ok, create_test_post()}
        end)

        # Test eager loading
        result = RelationshipResolver.eager_load(user, [:team])

        assert {:ok, loaded_user} = result
        assert loaded_user.team.id == "team-1"
        assert loaded_user.team.name == "Test Team"
      after
        # Restore the original functions
        if orig_team_load do
          :meck.expect(TeamResource, :load, orig_team_load)
        end

        if orig_post_load do
          :meck.expect(PostResource, :load, orig_post_load)
        end
      end
    end

    test "supports loading relationships for a collection" do
      user1 = create_test_user(%{id: "user-1"})
      user2 = create_test_user(%{id: "user-2"})

      # Mock the load function
      orig_load = &TeamResource.load/1

      try do
        # Replace the load function with our mock
        :meck.expect(TeamResource, :load, fn _id ->
          {:ok, create_test_team()}
        end)

        # Test eager loading for a collection
        result = RelationshipResolver.eager_load([user1, user2], [:team])

        assert {:ok, [loaded_user1, loaded_user2]} = result
        assert loaded_user1.team.id == "team-1"
        assert loaded_user2.team.id == "team-1"
      after
        # Restore the original function
        if orig_load do
          :meck.expect(TeamResource, :load, orig_load)
        end
      end
    end
  end
end
