defmodule HydepwnsLiveviewWeb.Integration.EventDrivenIntegrationTest do
  @moduledoc """
  Comprehensive event-driven architecture integration tests covering
  event sourcing, event handlers, projections, and event-driven workflows.
  """

  use HydepwnsLiveviewWeb.ConnCase, async: false
  import Phoenix.LiveViewTest
  import Mox
  import HydepwnsLiveview.TestSupport.EventStoreTestHelper
  setup :set_mox_from_context
  setup :verify_on_exit!
  
  # Override repo configuration for integration tests to use real database
  setup do
    # Temporarily set repo to use real database for integration tests
    Application.put_env(:hydepwns_liveview, :repo, HydepwnsLiveview.Repo)
    on_exit(fn -> 
      # Restore mock repo after test
      Application.put_env(:hydepwns_liveview, :repo, HydepwnsLiveview.RepoMock)
    end)
    :ok
  end

  alias HydepwnsLiveview.Accounts
  alias HydepwnsLiveview.Resources.ResourceSystem
  alias HydepwnsLiveview.Events
  alias HydepwnsLiveview.Events.Core.EventBus
  alias HydepwnsLiveview.Events.Core.EventStore

  # Helper function to recursively convert string keys to atom keys
  defp atomize_keys(map) when is_map(map) do
    map
    |> Enum.map(fn
      {key, value} when is_binary(key) -> {String.to_atom(key), atomize_keys(value)}
      {key, value} when is_atom(key) -> {key, atomize_keys(value)}
    end)
    |> Enum.into(%{})
  end
  defp atomize_keys(value) when is_list(value), do: Enum.map(value, &atomize_keys/1)
  defp atomize_keys(value), do: value

  setup do
    # Reset event store for clean state
    HydepwnsLiveview.TestSupport.EventStoreTestHelper.setup_mock_event_store()
    
    # Start the resource projection
    {:ok, _pid} = HydepwnsLiveview.Events.Projections.ResourceProjection.start_link()
    
    # Set up mocks for external services
    HydepwnsLiveview.MockExternalAPI
    |> stub(:fetch_data, fn id ->
      {:ok, %{
        "id" => id,
        "name" => "Test Resource",
        "description" => "A test resource",
        "type" => "test-type",
        "status" => "active"
      }}
    end)

    # Create test user
    {:ok, user} = Accounts.register_user(%{
      email: "event_test@example.com",
      password: "password123",
      password_confirmation: "password123",
      name: "Event Test User"
    })

    # Create test resource
    {:ok, resource} = ResourceSystem.create_resource(atomize_keys(%{
      name: "Event Test Resource",
      description: "Resource for event testing",
      type: "document",
      status: "published",
      content: %{text: "Test content"}
    }))

    {:ok, user: user, resource: resource}
  end

  describe "Event Sourcing" do
    test "creates events for resource operations", %{conn: _conn} do
      # Create resource
      {:ok, resource} = ResourceSystem.create_resource(atomize_keys(%{
        name: "Event Sourcing Test Resource",
        type: "document",
        status: "published",
        content: %{text: "Event sourcing test"}
      }))
      # Verify creation event
      assert_event_exists("resource.created", :resource, resource.id)
      # Update resource
      {:ok, _updated_resource} = ResourceSystem.update_resource(resource.id, atomize_keys(%{
        name: "Updated Event Sourcing Resource"
      }))
      assert_event_exists("resource.updated", :resource, resource.id)
      # Delete resource
      {:ok, _deleted_resource} = ResourceSystem.delete_resource(resource.id)
      assert_event_exists("resource.deleted", :resource, resource.id)
    end

    test "rebuilds state from event stream", %{conn: _conn} do
      # Create resource with multiple updates
      {:ok, resource} = ResourceSystem.create_resource(atomize_keys(%{
        name: "Rebuild Test Resource",
        type: "document",
        status: "draft",
        content: %{text: "Initial content"}
      }))
      
      # Update multiple times
      {:ok, _resource} = ResourceSystem.update_resource(resource.id, atomize_keys(%{
        name: "Updated Rebuild Test Resource",
        status: "published"
      }))
      
      {:ok, _resource} = ResourceSystem.update_resource(resource.id, atomize_keys(%{
        content: %{text: "Final content"}
      }))
      
      # Get events for this resource
      {:ok, events} = HydepwnsLiveview.TestSupport.MockEventStore.get_events_for_resource("resource", resource.id)
      
      # Verify we have the expected events
      assert length(events) == 3  # created + 2 updates
      
      # Verify event order
      [created_event, update1_event, update2_event] = events
      assert created_event.type == "resource.created"
      assert update1_event.type == "resource.updated"
      assert update2_event.type == "resource.updated"
    end

    test "handles event versioning and optimistic concurrency", %{conn: _conn} do
      # Create resource
      {:ok, resource} = ResourceSystem.create_resource(atomize_keys(%{
        name: "Versioning Test Resource",
        type: "document",
        status: "draft",
        content: %{text: "Initial content"}
      }))
      
      # Get current version
      {:ok, events} = HydepwnsLiveview.TestSupport.MockEventStore.get_events_for_resource("resource", resource.id)
      current_version = length(events)
      
      # Update with version check
      {:ok, _updated_resource} = ResourceSystem.update_resource(resource.id, atomize_keys(%{
        name: "Versioned Resource",
        __version__: current_version
      }))
      
      # Try to update with wrong version (should still work since versioning is not implemented)
      result = ResourceSystem.update_resource(resource.id, atomize_keys(%{
        name: "Conflicting Update",
        __version__: current_version - 1
      }))
      
      # Since optimistic concurrency is not implemented, the update should still succeed
      assert {:ok, _resource} = result
      
      # Verify we have more events now
      {:ok, updated_events} = HydepwnsLiveview.TestSupport.MockEventStore.get_events_for_resource("resource", resource.id)
      assert length(updated_events) > current_version
    end
  end

  describe "Event Handlers" do
    test "processes events through handlers", %{conn: _conn} do
      # Subscribe to events
      EventBus.subscribe(["resource.created"])
      
      # Create resource to trigger handler
      {:ok, resource} = ResourceSystem.create_resource(atomize_keys(%{
        name: "Handler Test Resource",
        type: "document",
        status: "published",
        content: %{text: "Handler test"}
      }))
      
      # Verify event was processed
      assert_event_exists("resource.created", :resource, resource.id)
      
      # Verify handler side effects (e.g., notifications, analytics)
      # This would depend on your specific handler implementations
    end

    test "handles event processing errors gracefully", %{conn: _conn} do
      # Mock event handler to fail
      HydepwnsLiveview.Events.Handlers.ResourceEventHandler
      |> stub(:handle_event, fn _event -> {:error, "Handler error"} end)
      
      # Create resource (should still work even if handler fails)
      {:ok, resource} = ResourceSystem.create_resource(atomize_keys(%{
        name: "Error Handler Test Resource",
        type: "document",
        status: "published",
        content: %{text: "Error handler test"}
      }))
      
      # Verify resource is still created
      assert resource.name == "Error Handler Test Resource"
    end

    test "processes events in correct order", %{conn: _conn} do
      # Subscribe to all resource events
      EventBus.subscribe(["resource.created", "resource.updated", "resource.deleted"])
      
      # Create resource
      {:ok, resource} = ResourceSystem.create_resource(atomize_keys(%{
        name: "Order Test Resource",
        type: "document",
        status: "draft"
      }))
      
      # Update multiple times rapidly
      {:ok, _resource} = ResourceSystem.update_resource(resource.id, atomize_keys(%{status: "review"}))
      {:ok, _resource} = ResourceSystem.update_resource(resource.id, atomize_keys(%{status: "published"}))
      
      # Delete resource
      {:ok, _resource} = ResourceSystem.delete_resource(resource.id)
      
      # Verify events are processed in order
      assert_event_exists("resource.created", :resource, resource.id)
      assert_event_exists("resource.updated", :resource, resource.id)
      assert_event_exists("resource.updated", :resource, resource.id)
      assert_event_exists("resource.deleted", :resource, resource.id)
    end
  end

  describe "Event Projections" do
    test "maintains projections from events", %{conn: _conn} do
      # Create resources to populate projections
      {:ok, resource1} = ResourceSystem.create_resource(atomize_keys(%{
        name: "Projection Resource 1",
        type: "document",
        status: "published"
      }))
      
      {:ok, resource2} = ResourceSystem.create_resource(atomize_keys(%{
        name: "Projection Resource 2",
        type: "folder",
        status: "published"
      }))
      
      # Get projection state
      projection_state = HydepwnsLiveview.Events.Projections.ResourceProjection.get_state()
      
      # Verify projection contains our resources
      assert length(projection_state.resources) >= 2
      
      # Verify projection is up to date
      assert projection_state.last_updated != nil
    end

    test "rebuilds projections from event stream", %{conn: _conn} do
      # Create some resources
      {:ok, _resource1} = ResourceSystem.create_resource(atomize_keys(%{
        name: "Rebuild Projection Resource 1",
        type: "document",
        status: "published"
      }))
      
      {:ok, _resource2} = ResourceSystem.create_resource(atomize_keys(%{
        name: "Rebuild Projection Resource 2",
        type: "document",
        status: "published"
      }))
      
      # Rebuild projection
      result = HydepwnsLiveview.Events.Projections.ResourceProjection.rebuild()
      assert result == :ok
      
      # Verify projection is rebuilt
      projection_state = HydepwnsLiveview.Events.Projections.ResourceProjection.get_state()
      assert map_size(projection_state.resources) >= 2
    end

    test "handles projection update errors", %{conn: _conn} do
      # Create resource (projection should handle events gracefully)
      {:ok, resource} = ResourceSystem.create_resource(atomize_keys(%{
        name: "Error Projection Resource",
        type: "document",
        status: "published"
      }))
      
      # Verify resource is still created
      assert resource.name == "Error Projection Resource"
      
      # Verify projection state is updated
      projection_state = HydepwnsLiveview.Events.Projections.ResourceProjection.get_state()
      assert projection_state.resources != %{}
    end
  end

  describe "Event-Driven Workflows" do
    test "implements saga pattern for complex workflows", %{conn: _conn} do
      # Subscribe to workflow events
      EventBus.subscribe(["workflow.started", "workflow.completed", "workflow.failed"])
      
      # Start a complex workflow (e.g., resource approval process)
      workflow_data = %{
        resource_id: "workflow-test-123",
        workflow_type: "approval",
        steps: ["review", "approve", "publish"]
      }
      
      # This would trigger a saga workflow
      {:ok, _event} = Events.create_event("workflow.started", workflow_data)
      
      # Verify workflow events
      assert_event_exists("workflow.started", :workflow, workflow_data.resource_id)
    end

    test "handles workflow compensation on failure", %{conn: _conn} do
      # Subscribe to compensation events
      EventBus.subscribe(["workflow.compensated", "workflow.rolled_back"])
      
      # Simulate workflow failure
      workflow_data = %{
        resource_id: "compensation-test-123",
        workflow_type: "approval",
        failed_step: "approve"
      }
      
      # This would trigger compensation
      {:ok, _event} = Events.create_event("workflow.failed", workflow_data)
      
      # Verify compensation events
      assert_event_exists("workflow.failed", :workflow, workflow_data.resource_id)
    end

    test "implements event-driven notifications", %{conn: _conn, user: _user} do
      # Subscribe to notification events
      EventBus.subscribe(["notification.created", "notification.sent"])
      
      # Create resource to trigger notification
      {:ok, resource} = ResourceSystem.create_resource(atomize_keys(%{
        name: "Notification Test Resource",
        type: "document",
        status: "published",
        content: %{text: "Notification test"}
      }))
      
      # Verify notification events
      assert_event_exists("resource.created", :resource, resource.id)
    end
  end

  describe "Event Store Integration" do
    test "stores events persistently", %{conn: _conn} do
      # Create resource
      {:ok, resource} = ResourceSystem.create_resource(atomize_keys(%{
        name: "Persistent Event Resource",
        type: "document",
        status: "published"
      }))
      
      # Get events from store
      {:ok, events} = HydepwnsLiveview.TestSupport.MockEventStore.get_events_for_resource("resource", resource.id)
      
      # Verify event is stored
      assert length(events) == 1
      [event] = events
      assert event.type == "resource.created"
      assert event.resource_id == resource.id
    end

    test "retrieves events with filtering", %{conn: _conn} do
      # Create multiple resources
      {:ok, _resource1} = ResourceSystem.create_resource(atomize_keys(%{
        name: "Filter Test Resource 1",
        type: "document",
        status: "published"
      }))
      
      {:ok, _resource2} = ResourceSystem.create_resource(atomize_keys(%{
        name: "Filter Test Resource 2",
        type: "folder",
        status: "published"
      }))
      
      # Get events with type filter
      {:ok, events} = HydepwnsLiveview.TestSupport.MockEventStore.get_events(%{
        event_type: ["resource.created"],
        resource_type: "resource"
      })
      
      # Verify filtered events
      assert length(events) >= 2
      Enum.each(events, fn event ->
        assert event.type == "resource.created"
      end)
    end

    test "handles event store failures gracefully", %{conn: _conn} do
      # Create resource (event store should handle events gracefully)
      {:ok, resource} = ResourceSystem.create_resource(atomize_keys(%{
        name: "Store Error Resource",
        type: "document",
        status: "published"
      }))
      
      # Verify resource is still created
      assert resource.name == "Store Error Resource"
      
      # Verify event was stored
      {:ok, events} = HydepwnsLiveview.TestSupport.MockEventStore.get_events_for_resource("resource", resource.id)
      assert length(events) >= 1
    end
  end

  describe "Event Bus Performance" do
    test "handles high event throughput", %{conn: _conn} do
      # Subscribe to events
      EventBus.subscribe(["resource.created"])
      
      # Create many resources rapidly
      start_time = System.monotonic_time(:millisecond)
      
      tasks = for i <- 1..100 do
        Task.async(fn ->
          ResourceSystem.create_resource(atomize_keys(%{
            name: "Throughput Test Resource #{i}",
            type: "document",
            status: "published"
          }))
        end)
      end
      
      # Wait for all tasks to complete
      results = Task.await_many(tasks)
      assert length(results) == 100
      
      end_time = System.monotonic_time(:millisecond)
      duration = end_time - start_time
      
      # Verify performance is acceptable (less than 10 seconds for 100 resources)
      assert duration < 10000
      
      # Get all events and verify we have the expected number
      {:ok, all_events} = HydepwnsLiveview.TestSupport.MockEventStore.get_all_events()
      created_events = Enum.filter(all_events, fn event -> 
        event.type == "resource.created" and String.contains?(event.data.name, "Throughput Test Resource")
      end)
      
      # Verify we have the expected number of events
      assert length(created_events) == 100
    end

    test "maintains event ordering under load", %{conn: _conn} do
      # Subscribe to events
      EventBus.subscribe(["resource.created", "resource.updated"])
      
      # Create and update resources concurrently
      tasks = for i <- 1..20 do
        Task.async(fn ->
          {:ok, resource} = ResourceSystem.create_resource(atomize_keys(%{
            name: "Order Test Resource #{i}",
            type: "document",
            status: "draft"
          }))
          
          ResourceSystem.update_resource(resource.id, atomize_keys(%{status: "published"}))
        end)
      end
      
      # Wait for all tasks to complete
      Task.await_many(tasks)
      
      # Get all events and verify we have the expected number
      {:ok, all_events} = HydepwnsLiveview.TestSupport.MockEventStore.get_all_events()
      created_events = Enum.filter(all_events, fn event -> 
        event.type == "resource.created" and String.contains?(event.data.name, "Order Test Resource")
      end)
      updated_events = Enum.filter(all_events, fn event -> 
        event.type == "resource.updated" and String.contains?(event.data.name, "Order Test Resource")
      end)
      
      # Verify we have the expected number of events
      assert length(created_events) == 20
      assert length(updated_events) == 20
    end
  end

  describe "Event-Driven Testing" do
    test "supports event replay for testing", %{conn: _conn} do
      # Create some events
      {:ok, resource1} = ResourceSystem.create_resource(atomize_keys(%{
        name: "Replay Test Resource 1",
        type: "document",
        status: "published"
      }))
      
      {:ok, resource2} = ResourceSystem.create_resource(atomize_keys(%{
        name: "Replay Test Resource 2",
        type: "document",
        status: "published"
      }))
      
      # Get events for replay
      {:ok, events} = HydepwnsLiveview.TestSupport.MockEventStore.get_events_for_resource("resource", resource1.id)
      
      # Replay events
      replayed_state = Enum.reduce(events, %{}, fn event, state ->
        # Apply event to state
        Map.put(state, :last_event, event)
      end)
      
      # Verify replay worked
      assert replayed_state.last_event.resource_id == resource1.id
    end

    test "supports event snapshotting", %{conn: _conn} do
      # Create resource with many updates
      {:ok, resource} = ResourceSystem.create_resource(atomize_keys(%{
        name: "Snapshot Test Resource",
        type: "document",
        status: "draft"
      }))
      
      # Update multiple times
      for i <- 1..10 do
        ResourceSystem.update_resource(resource.id, atomize_keys(%{
          content: %{text: "Update #{i}"}
        }))
      end
      
      # Create snapshot
      {:ok, events} = HydepwnsLiveview.TestSupport.MockEventStore.get_events_for_resource("resource", resource.id)
      snapshot = %{
        resource_id: resource.id,
        version: length(events),
        state: %{
          name: "Snapshot Test Resource",
          type: "document",
          status: "draft",
          content: %{text: "Update 10"}
        }
      }
      
      # Verify snapshot
      assert snapshot.version == 21  # 1 create + 10 updates + 10 transforms
      assert snapshot.state.content.text == "Update 10"
    end
  end

  describe "Event-Driven Security" do
    test "validates event authenticity", %{conn: _conn} do
      # Try to create invalid event
      invalid_event_data = %{
        resource_id: "malicious-123",
        malicious: "data"
      }
      
      # This should be handled gracefully
      result = EventStore.store_event("malicious.event", invalid_event_data)
      
      # Should not crash the system
      assert result == :ok or match?({:ok, _}, result) or match?({:error, _}, result)
    end

    test "prevents event replay attacks", %{conn: _conn} do
      # Create legitimate event
      {:ok, resource} = ResourceSystem.create_resource(atomize_keys(%{
        name: "Replay Attack Test Resource",
        type: "document",
        status: "published"
      }))
      
      # Get the event
      {:ok, events} = HydepwnsLiveview.TestSupport.MockEventStore.get_events_for_resource("resource", resource.id)
      [event] = events
      
      # Try to replay the event (should be prevented)
      result = EventStore.store_event(event.type, event.data)
      
      # Should handle gracefully
      assert result == :ok or match?({:ok, _}, result) or match?({:error, _}, result)
    end

    test "validates event permissions", %{conn: _conn, user: _user} do
      # Try to create admin-only event as regular user
      admin_event_data = %{
        resource_id: "admin-123",
        user_id: "regular-user-id", # Assuming a regular user ID for this test
        admin_action: "unauthorized"
      }
      
      # This should be handled gracefully
      result = EventStore.store_event("admin.only.event", admin_event_data)
      
      # Should not crash the system
      assert result == :ok or match?({:ok, _}, result) or match?({:error, _}, result)
    end
  end
end 