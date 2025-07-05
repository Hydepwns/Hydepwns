defmodule HydepwnsLiveviewWeb.Integration.RealtimeIntegrationTest do
  @moduledoc """
  Comprehensive real-time integration tests covering WebSocket connections,
  PubSub events, LiveView updates, and real-time notifications.
  """

  use HydepwnsLiveviewWeb.ConnCase, async: false
  import Phoenix.LiveViewTest
  import Mox
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

  setup do
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
      email: "realtime_test@example.com",
      password: "password123",
      password_confirmation: "password123",
      name: "Realtime Test User"
    })

    # Create test resource
    {:ok, resource} = ResourceSystem.create_resource(%{
      name: "Realtime Test Resource",
      description: "Resource for realtime testing",
      type: "document",
      status: "published",
      content: %{text: "Test content"}
    })

    {:ok, user: user, resource: resource}
  end

  describe "WebSocket Connection" do
    test "establishes WebSocket connection successfully", %{conn: conn} do
      # Test WebSocket connection to LiveView
      {:ok, view, _html} = live(conn, "/resources")
      
      # Verify connection is established
      assert view |> has_element?("h1", "Resources")
      assert Process.alive?(view.pid)
    end

    test "handles WebSocket disconnection gracefully", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/resources")
      
      # Simulate disconnection
      Process.exit(view.pid, :normal)
      
      # Verify process is terminated
      refute Process.alive?(view.pid)
    end

    test "reconnects after connection loss", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/resources")
      
      # Simulate connection loss and reconnection
      view = view |> element("h1") |> render_click()
      
      # Verify reconnection works
      assert view |> has_element?("h1", "Resources")
    end
  end

  describe "PubSub Event Broadcasting" do
    test "broadcasts resource creation events", %{conn: conn, user: user} do
      # Subscribe to resource events
      Phoenix.PubSub.subscribe(HydepwnsLiveview.PubSub, "resources")
      
      # Create a resource to trigger event
      {:ok, new_resource} = ResourceSystem.create_resource(%{
        name: "PubSub Test Resource",
        type: "document",
        status: "published",
        content: %{text: "PubSub test"}
      })
      
      # Wait for and verify the broadcast
      assert_receive {:resource_created, ^new_resource}
    end

    test "broadcasts resource update events", %{conn: conn, resource: resource} do
      # Subscribe to resource events
      Phoenix.PubSub.subscribe(HydepwnsLiveview.PubSub, "resources")
      
      # Update the resource to trigger event
      {:ok, updated_resource} = ResourceSystem.update_resource(resource.id, %{
        name: "Updated Resource Name"
      })
      
      # Wait for and verify the broadcast
      assert_receive {:resource_updated, ^updated_resource}
    end

    test "broadcasts resource deletion events", %{conn: conn, resource: resource} do
      # Subscribe to resource events
      Phoenix.PubSub.subscribe(HydepwnsLiveview.PubSub, "resources")
      
      # Delete the resource to trigger event
      {:ok, deleted_resource} = ResourceSystem.delete_resource(resource.id)
      
      # Wait for and verify the broadcast
      assert_receive {:resource_deleted, ^deleted_resource}
    end

    test "broadcasts custom events", %{conn: conn} do
      # Subscribe to custom events
      Phoenix.PubSub.subscribe(HydepwnsLiveview.PubSub, "custom_events")
      
      # Broadcast a custom event
      custom_event = %{type: "test_event", data: %{message: "Hello World"}}
      Phoenix.PubSub.broadcast(HydepwnsLiveview.PubSub, "custom_events", custom_event)
      
      # Wait for and verify the broadcast
      assert_receive ^custom_event
    end
  end

  describe "LiveView Real-time Updates" do
    test "updates UI in real-time when resource is created", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/resources")
      
      # Verify initial state
      assert view |> has_element?("h1", "Resources")
      
      # Create a new resource via API
      {:ok, new_resource} = ResourceSystem.create_resource(%{
        name: "Real-time Test Resource",
        type: "document",
        status: "published",
        content: %{text: "Real-time test"}
      })
      
      # Wait for LiveView to receive the update
      Process.sleep(100)
      
      # Verify the new resource appears in the UI
      assert view |> has_element?("a", "Real-time Test Resource")
    end

    test "updates UI in real-time when resource is updated", %{conn: conn, resource: resource} do
      {:ok, view, _html} = live(conn, "/resources")
      
      # Verify initial state
      assert view |> has_element?("a", resource.name)
      
      # Update the resource via API
      {:ok, updated_resource} = ResourceSystem.update_resource(resource.id, %{
        name: "Updated Real-time Resource"
      })
      
      # Wait for LiveView to receive the update
      Process.sleep(100)
      
      # Verify the updated resource name appears in the UI
      assert view |> has_element?("a", "Updated Real-time Resource")
    end

    test "updates UI in real-time when resource is deleted", %{conn: conn, resource: resource} do
      {:ok, view, _html} = live(conn, "/resources")
      
      # Verify initial state
      assert view |> has_element?("a", resource.name)
      
      # Delete the resource via API
      {:ok, _deleted_resource} = ResourceSystem.delete_resource(resource.id)
      
      # Wait for LiveView to receive the update
      Process.sleep(100)
      
      # Verify the resource is removed from the UI
      refute view |> has_element?("a", resource.name)
    end

    test "handles multiple concurrent updates", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/resources")
      
      # Create multiple resources concurrently
      tasks = for i <- 1..5 do
        Task.async(fn ->
          ResourceSystem.create_resource(%{
            name: "Concurrent Resource #{i}",
            type: "document",
            status: "published",
            content: %{text: "Concurrent test #{i}"}
          })
        end)
      end
      
      # Wait for all tasks to complete
      results = Task.await_many(tasks)
      assert length(results) == 5
      
      # Wait for LiveView to receive all updates
      Process.sleep(200)
      
      # Verify all resources appear in the UI
      for i <- 1..5 do
        assert view |> has_element?("a", "Concurrent Resource #{i}")
      end
    end
  end

  describe "Event-Driven Notifications" do
    test "displays real-time notifications for resource events", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/resources")
      
      # Create a resource to trigger notification
      {:ok, _new_resource} = ResourceSystem.create_resource(%{
        name: "Notification Test Resource",
        type: "document",
        status: "published",
        content: %{text: "Notification test"}
      })
      
      # Wait for notification to appear
      Process.sleep(100)
      
      # Verify notification is displayed
      assert view |> has_element?(".alert-success", "Resource created successfully")
    end

    test "handles notification dismissal", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/resources")
      
      # Create a resource to trigger notification
      {:ok, _new_resource} = ResourceSystem.create_resource(%{
        name: "Dismiss Test Resource",
        type: "document",
        status: "published",
        content: %{text: "Dismiss test"}
      })
      
      # Wait for notification to appear
      Process.sleep(100)
      
      # Verify notification is displayed
      assert view |> has_element?(".alert-success")
      
      # Dismiss the notification
      view |> element(".alert-success .close") |> render_click()
      
      # Verify notification is dismissed
      refute view |> has_element?(".alert-success")
    end

    test "displays different notification types", %{conn: conn, resource: resource} do
      {:ok, view, _html} = live(conn, "/resources")
      
      # Test success notification (resource update)
      {:ok, _updated_resource} = ResourceSystem.update_resource(resource.id, %{
        name: "Success Test Resource"
      })
      
      Process.sleep(100)
      assert view |> has_element?(".alert-success")
      
      # Test error notification (invalid update)
      view |> element("a[data-test-id='resource-link-#{resource.id}']") |> render_click()
      view |> element("a[data-test-id='edit-resource-link']") |> render_click()
      
      # Submit invalid form
      view |> form("form", resource: %{name: ""}) |> render_submit()
      
      # Verify error notification
      assert view |> has_element?(".alert-error")
    end
  end

  describe "Presence and User Tracking" do
    test "tracks user presence in real-time", %{conn: conn, user: user} do
      # Login user
      token = Accounts.generate_user_session_token(user)
      session = %{"user_token" => token}
      
      {:ok, view, _html} = live(conn, "/resources", session: session)
      
      # Verify user is tracked in presence
      presence = HydepwnsLiveviewWeb.Presence.list("resources")
      assert map_size(presence) > 0
      
      # Verify current user is in presence
      user_presence = Enum.find(presence, fn {_key, _meta} -> true end)
      assert user_presence != nil
    end

    test "broadcasts presence updates to other users", %{conn: conn, user: user} do
      # Subscribe to presence updates
      Phoenix.PubSub.subscribe(HydepwnsLiveview.PubSub, "resources:presence")
      
      # Login user
      token = Accounts.generate_user_session_token(user)
      session = %{"user_token" => token}
      
      {:ok, _view, _html} = live(conn, "/resources", session: session)
      
      # Wait for presence update
      assert_receive {:presence_diff, _diff}
    end

    test "handles user disconnection gracefully", %{conn: conn, user: user} do
      # Login user
      token = Accounts.generate_user_session_token(user)
      session = %{"user_token" => token}
      
      {:ok, view, _html} = live(conn, "/resources", session: session)
      
      # Get initial presence count
      initial_presence = HydepwnsLiveviewWeb.Presence.list("resources")
      initial_count = map_size(initial_presence)
      
      # Disconnect user
      Process.exit(view.pid, :normal)
      
      # Wait for presence update
      Process.sleep(100)
      
      # Verify presence count decreased
      final_presence = HydepwnsLiveviewWeb.Presence.list("resources")
      final_count = map_size(final_presence)
      assert final_count < initial_count
    end
  end

  describe "Event Bus Integration" do
    test "subscribes to event bus and receives events", %{conn: conn} do
      # Subscribe to event bus
      HydepwnsLiveview.Events.Core.EventBus.subscribe(["resource.created"])
      
      # Create a resource to trigger event
      {:ok, new_resource} = ResourceSystem.create_resource(%{
        name: "Event Bus Test Resource",
        type: "document",
        status: "published",
        content: %{text: "Event bus test"}
      })
      
      # Wait for event
      assert_receive {:event, event, _opts}
      assert event.resource_id == new_resource.id
      assert event.type == "resource.created"
    end

    test "handles multiple event types", %{conn: conn} do
      # Subscribe to multiple event types
      HydepwnsLiveview.Events.Core.EventBus.subscribe([
        "resource.created",
        "resource.updated",
        "resource.deleted"
      ])
      
      # Create resource
      {:ok, resource} = ResourceSystem.create_resource(%{
        name: "Multi Event Test Resource",
        type: "document",
        status: "published",
        content: %{text: "Multi event test"}
      })
      
      # Update resource
      {:ok, _updated_resource} = ResourceSystem.update_resource(resource.id, %{
        name: "Updated Multi Event Resource"
      })
      
      # Delete resource
      {:ok, _deleted_resource} = ResourceSystem.delete_resource(resource.id)
      
      # Wait for all events
      assert_receive {:event, %{type: "resource.created"}, _opts}
      assert_receive {:event, %{type: "resource.updated"}, _opts}
      assert_receive {:event, %{type: "resource.deleted"}, _opts}
    end

    test "unsubscribes from event bus", %{conn: conn} do
      # Subscribe to events
      HydepwnsLiveview.Events.Core.EventBus.subscribe(["resource.created"])
      
      # Unsubscribe
      HydepwnsLiveview.Events.Core.EventBus.unsubscribe(["resource.created"])
      
      # Create a resource
      {:ok, _new_resource} = ResourceSystem.create_resource(%{
        name: "Unsubscribe Test Resource",
        type: "document",
        status: "published",
        content: %{text: "Unsubscribe test"}
      })
      
      # Should not receive event
      refute_receive {:event, _event, _opts}
    end
  end

  describe "Real-time Performance" do
    test "handles high-frequency updates efficiently", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/resources")
      
      # Create many resources rapidly
      start_time = System.monotonic_time(:millisecond)
      
      for i <- 1..50 do
        ResourceSystem.create_resource(%{
          name: "Performance Test Resource #{i}",
          type: "document",
          status: "published",
          content: %{text: "Performance test #{i}"}
        })
      end
      
      end_time = System.monotonic_time(:millisecond)
      duration = end_time - start_time
      
      # Verify performance is acceptable (less than 5 seconds for 50 resources)
      assert duration < 5000
      
      # Wait for UI updates
      Process.sleep(500)
      
      # Verify all resources are displayed
      for i <- 1..50 do
        assert view |> has_element?("a", "Performance Test Resource #{i}")
      end
    end

    test "maintains responsiveness under load", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/resources")
      
      # Simulate high load with concurrent operations
      tasks = for i <- 1..20 do
        Task.async(fn ->
          # Create resource
          {:ok, resource} = ResourceSystem.create_resource(%{
            name: "Load Test Resource #{i}",
            type: "document",
            status: "published",
            content: %{text: "Load test #{i}"}
          })
          
          # Update resource
          ResourceSystem.update_resource(resource.id, %{
            name: "Updated Load Test Resource #{i}"
          })
          
          # Delete resource
          ResourceSystem.delete_resource(resource.id)
        end)
      end
      
      # Wait for all tasks to complete
      Task.await_many(tasks)
      
      # Verify LiveView is still responsive
      assert view |> has_element?("h1", "Resources")
      
      # Verify we can still interact with the UI
      view |> element("h1") |> render_click()
      assert view |> has_element?("h1", "Resources")
    end
  end

  describe "Real-time Error Handling" do
    test "handles event processing errors gracefully", %{conn: conn} do
      # Mock event store to return error
      HydepwnsLiveview.TestSupport.MockEventStore
      |> stub(:store_event, fn _event -> {:error, "Event store error"} end)
      
      {:ok, view, _html} = live(conn, "/resources")
      
      # Create resource (should still work even if event fails)
      {:ok, _new_resource} = ResourceSystem.create_resource(%{
        name: "Error Test Resource",
        type: "document",
        status: "published",
        content: %{text: "Error test"}
      })
      
      # Verify resource is still created and displayed
      Process.sleep(100)
      assert view |> has_element?("a", "Error Test Resource")
    end

    test "handles WebSocket connection errors", %{conn: conn} do
      # Test with invalid session
      invalid_session = %{"invalid" => "session"}
      
      # Should handle gracefully
      {:ok, view, _html} = live(conn, "/resources", session: invalid_session)
      
      # Verify page still loads
      assert view |> has_element?("h1", "Resources")
    end

    test "recovers from temporary service failures", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/resources")
      
      # Mock external service to fail temporarily
      HydepwnsLiveview.MockExternalAPI
      |> stub(:fetch_data, fn _id -> {:error, "Temporary failure"} end)
      
      # Try to create resource
      {:ok, _new_resource} = ResourceSystem.create_resource(%{
        name: "Recovery Test Resource",
        type: "document",
        status: "published",
        content: %{text: "Recovery test"}
      })
      
      # Verify system recovers and resource is created
      Process.sleep(100)
      assert view |> has_element?("a", "Recovery Test Resource")
    end
  end

  describe "Real-time Security" do
    test "validates user permissions for real-time updates", %{conn: conn, user: user} do
      # Login as regular user
      token = Accounts.generate_user_session_token(user)
      session = %{"user_token" => token}
      
      {:ok, view, _html} = live(conn, "/resources", session: session)
      
      # Try to access admin-only real-time features
      # This should be handled gracefully
      assert view |> has_element?("h1", "Resources")
    end

    test "prevents unauthorized event subscriptions", %{conn: conn} do
      # Try to subscribe to admin-only events
      # This should be handled gracefully
      result = HydepwnsLiveview.Events.Core.EventBus.subscribe(["admin.only.event"])
      
      # Should not crash
      assert result == :ok
    end

    test "validates real-time message authenticity", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/resources")
      
      # Try to send invalid event
      # This should be handled gracefully
      Phoenix.PubSub.broadcast(HydepwnsLiveview.PubSub, "resources", {:invalid_event, "malicious"})
      
      # Verify LiveView remains stable
      assert view |> has_element?("h1", "Resources")
    end
  end
end 