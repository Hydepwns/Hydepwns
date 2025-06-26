defmodule HydepwnsLiveviewWeb.TestMockHelper do
  @moduledoc """
  Helper for mocking external dependencies in tests.

  This module provides utilities for creating and using mocks in tests,
  particularly for external services and APIs that should not be called
  during testing.

  ## Usage

  ```elixir
  # In your test setup
  setup do
    MockHelper.setup_mocks()
    :ok
  end

  # In your test
  test "external API call is mocked", %{conn: conn} do
    MockHelper.expect_api_call(:external_service, :get_data, fn _ -> 
      {:ok, %{"result" => "mocked data"}} 
    end)
    
    # Test with mocked API
  end
  ```

  """

  import Mox

  @doc """
  Sets up mocks for external dependencies.

  Call this in your test setup to ensure mocks are properly configured.
  """
  def setup_mocks do
    # Reset all mocks before each test
    Mox.stub_with(HydepwnsLiveview.MockHTTPClient, HydepwnsLiveview.DefaultHTTPClient)
    Mox.stub_with(HydepwnsLiveview.MockExternalAPI, HydepwnsLiveview.DefaultExternalAPI)
    
    # Set up RepoMock with flexible stub for any resource ID
    setup_repo_mock()
    
    :ok
  end

  @doc """
  Sets up RepoMock with a flexible stub that can handle any resource ID.
  This prevents Mox.UnexpectedCallError when tests create resources with random IDs.
  """
  def setup_repo_mock do
    HydepwnsLiveview.RepoMock
    |> stub(:get, fn module, id, _opts ->
      case module do
        HydepwnsLiveview.Resources.Resource ->
          %HydepwnsLiveview.Resources.Resource{
            id: id,
            name: "Test Resource",
            description: "A test resource",
            type: "document",
            status: "published",
            content: %{text: "Test content"},
            metadata: %{},
            settings: %{},
            version: 1,
            parent_id: nil,
            child_ids: [],
            tags: [],
            categories: [],
            created_by: nil,
            updated_by: nil,
            inserted_at: DateTime.utc_now(),
            updated_at: DateTime.utc_now()
          }
        _ ->
          nil
      end
    end)
    |> stub(:get!, fn module, id, _opts ->
      case module do
        HydepwnsLiveview.Resources.Resource ->
          %HydepwnsLiveview.Resources.Resource{
            id: id,
            name: "Test Resource",
            description: "A test resource",
            type: "document",
            status: "published",
            content: %{text: "Test content"},
            metadata: %{},
            settings: %{},
            version: 1,
            parent_id: nil,
            child_ids: [],
            tags: [],
            categories: [],
            created_by: nil,
            updated_by: nil,
            inserted_at: DateTime.utc_now(),
            updated_at: DateTime.utc_now()
          }
        _ ->
          raise Ecto.QueryError, message: "Resource not found"
      end
    end)
    |> stub(:get_by, fn module, _clauses, _opts ->
      case module do
        HydepwnsLiveview.Resources.Resource ->
          %HydepwnsLiveview.Resources.Resource{
            id: "test-resource-id",
            name: "Test Resource",
            description: "A test resource",
            type: "document",
            status: "published",
            content: %{text: "Test content"},
            metadata: %{},
            settings: %{},
            version: 1,
            parent_id: nil,
            child_ids: [],
            tags: [],
            categories: [],
            created_by: nil,
            updated_by: nil,
            inserted_at: DateTime.utc_now(),
            updated_at: DateTime.utc_now()
          }
        _ ->
          nil
      end
    end)
    |> stub(:insert, fn changeset ->
      # Check if the changeset is valid
      if changeset.valid? do
        # Generate a random ID for the new resource
        id = Ecto.UUID.generate()
        resource = %HydepwnsLiveview.Resources.Resource{
          id: id,
          name: changeset.changes[:name] || "Test Resource",
          description: changeset.changes[:description] || "A test resource",
          type: changeset.changes[:type] || "document",
          status: changeset.changes[:status] || "published",
          content: changeset.changes[:content] || %{text: "Test content"},
          metadata: changeset.changes[:metadata] || %{},
          settings: changeset.changes[:settings] || %{},
          version: changeset.changes[:version] || 1,
          parent_id: changeset.changes[:parent_id],
          child_ids: changeset.changes[:child_ids] || [],
          tags: changeset.changes[:tags] || [],
          categories: changeset.changes[:categories] || [],
          created_by: changeset.changes[:created_by],
          updated_by: changeset.changes[:updated_by],
          inserted_at: DateTime.utc_now(),
          updated_at: DateTime.utc_now()
        }
        {:ok, resource}
      else
        # Return the changeset with errors
        {:error, changeset}
      end
    end)
    |> stub(:update, fn changeset ->
      # Check if the changeset is valid
      if changeset.valid? do
        # Update the resource with the changes
        resource = %{changeset.data | 
          name: changeset.changes[:name] || changeset.data.name,
          description: changeset.changes[:description] || changeset.data.description,
          type: changeset.changes[:type] || changeset.data.type,
          status: changeset.changes[:status] || changeset.data.status,
          content: changeset.changes[:content] || changeset.data.content,
          metadata: changeset.changes[:metadata] || changeset.data.metadata,
          settings: changeset.changes[:settings] || changeset.data.settings,
          version: changeset.changes[:version] || changeset.data.version,
          parent_id: changeset.changes[:parent_id] || changeset.data.parent_id,
          child_ids: changeset.changes[:child_ids] || changeset.data.child_ids,
          tags: changeset.changes[:tags] || changeset.data.tags,
          categories: changeset.changes[:categories] || changeset.data.categories,
          created_by: changeset.changes[:created_by] || changeset.data.created_by,
          updated_by: changeset.changes[:updated_by] || changeset.data.updated_by,
          updated_at: DateTime.utc_now()
        }
        {:ok, resource}
      else
        # Return the changeset with errors
        {:error, changeset}
      end
    end)
    |> stub(:delete, fn resource ->
      {:ok, resource}
    end)
    |> stub(:delete_all, fn module ->
      case module do
        HydepwnsLiveview.Resources.Resource -> {0, nil}
        _ -> {0, nil}
      end
    end)
  end

  @doc """
  Expects an API call to be made with the given parameters and returns the specified result.

  ## Parameters

  - `service` - The service being mocked (e.g., `:external_service`)
  - `action` - The action being performed (e.g., `:get_data`)
  - `callback` - A function that takes the parameters and returns a mocked result

  ## Example

  ```elixir
  MockHelper.expect_api_call(:external_service, :get_data, fn _ -> 
    {:ok, %{"result" => "mocked data"}} 
  end)
  ```
  """
  def expect_api_call(service, action, callback) when is_function(callback) do
    mock =
      case service do
        :external_api -> HydepwnsLiveview.MockExternalAPI
        :http_client -> HydepwnsLiveview.MockHTTPClient
        m when is_atom(m) -> m
        m -> m
      end

    Mox.expect(mock, action, callback)
  end

  @doc """
  Verifies that all expected calls were made.

  Call this at the end of your test to ensure all expected mocked calls were made.
  """
  def verify_all_mocks do
    verify!(HydepwnsLiveview.MockHTTPClient)
    verify!(HydepwnsLiveview.MockExternalAPI)
  end
end
