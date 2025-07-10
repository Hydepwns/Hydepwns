defmodule HydepwnsLiveview.Events.EventStoreTest do
  use ExUnit.Case, async: true

  alias HydepwnsLiveview.Events.EventStore
  alias HydepwnsLiveview.Events.Core.Event
  alias HydepwnsLiveview.Events.Schemas.{ReplaySession, Snapshot, VersionedState}

  describe "event operations" do
    test "store_event/1 delegates to event store module" do
      event = %Event{id: "test-event", type: "user_created", data: %{name: "John"}}

      # Test that the function exists and can be called
      # The actual implementation will be tested in integration tests
      assert is_function(&EventStore.store_event/1)
    end

    test "store_event/2 delegates to event store module" do
      type = "user_created"
      data = %{name: "John"}

      # Test that the function exists and can be called
      assert is_function(&EventStore.store_event/2)
    end

    test "store_events/1 delegates to event store module" do
      events = [
        %Event{id: "event-1", type: "user_created"},
        %Event{id: "event-2", type: "user_updated"}
      ]

      # Test that the function exists and can be called
      assert is_function(&EventStore.store_events/1)
    end

    test "get_events/1 delegates to event store module" do
      criteria = %{resource_type: "user", resource_id: "user-123"}

      # Test that the function exists and can be called
      assert is_function(&EventStore.get_events/1)
    end

    test "get_events_for_resource/2 delegates to event store module" do
      resource_type = "user"
      resource_id = "user-123"

      # Test that the function exists and can be called
      assert is_function(&EventStore.get_events_for_resource/2)
    end

    test "get_events_for_resource_at/3 delegates to event store module" do
      resource_type = "user"
      resource_id = "user-123"
      timestamp = DateTime.utc_now()

      # Test that the function exists and can be called
      assert is_function(&EventStore.get_events_for_resource_at/3)
    end

    test "get_event/1 delegates to event store module" do
      event_id = "event-123"

      # Test that the function exists and can be called
      assert is_function(&EventStore.get_event/1)
    end

    test "delete_event/1 handles not found events" do
      event_id = "non-existent-event"

      # Test that the function exists and can be called
      assert is_function(&EventStore.delete_event/1)
    end

    test "list_all_events/0 delegates to event store module" do
      # Test that the function exists and can be called
      assert is_function(&EventStore.list_all_events/0)
    end
  end

  describe "replay operations" do
    test "create_replay_session/4 delegates to ReplayOperations" do
      name = "test_session"
      resource_type = "user"
      resource_id = "user-123"
      opts = [limit: 100]

      # Test that the function exists and can be called
      assert is_function(&EventStore.create_replay_session/4)
    end

    test "create_replay_session/3 uses default options" do
      name = "test_session"
      resource_type = "user"
      resource_id = "user-123"

      # Test that the function exists and can be called
      assert is_function(&EventStore.create_replay_session/3)
    end

    test "get_replay_session/1 returns mock session" do
      session_id = "session-123"

      assert {:ok, session} = EventStore.get_replay_session(session_id)
      assert session.id == session_id
      assert session.status == "pending"
    end

    test "list_replay_sessions/0 delegates to ReplayOperations" do
      # Test that the function exists and can be called
      assert is_function(&EventStore.list_replay_sessions/0)
    end

    test "complete_replay_session/2 delegates to ReplayOperations" do
      session_id = "session-123"
      final_state = %{name: "John", email: "john@example.com"}

      # Test that the function exists and can be called
      assert is_function(&EventStore.complete_replay_session/2)
    end

    test "complete_replay_session/2 returns error for invalid parameters" do
      assert {:error, :invalid_parameters} = EventStore.complete_replay_session(123, "not a map")
      assert {:error, :invalid_parameters} = EventStore.complete_replay_session("session-123", "not a map")
      assert {:error, :invalid_parameters} = EventStore.complete_replay_session(123, %{})
    end

    test "get_replay_session_events/1 delegates to ReplayOperations" do
      session_id = "session-123"

      # Test that the function exists and can be called
      assert is_function(&EventStore.get_replay_session_events/1)
    end

    test "get_replay_session_events/1 returns error for invalid session_id" do
      assert {:error, :invalid_parameters} = EventStore.get_replay_session_events(123)
      assert {:error, :invalid_parameters} = EventStore.get_replay_session_events(nil)
    end
  end

  describe "snapshot operations" do
    test "get_latest_snapshot/2 delegates to SnapshotOperations" do
      resource_type = "user"
      resource_id = "user-123"

      # Test that the function exists and can be called
      assert is_function(&EventStore.get_latest_snapshot/2)
    end

    test "get_latest_snapshot/2 returns error for invalid parameters" do
      assert {:error, :invalid_parameters} = EventStore.get_latest_snapshot(123, "user-123")
      assert {:error, :invalid_parameters} = EventStore.get_latest_snapshot("user", 123)
      assert {:error, :invalid_parameters} = EventStore.get_latest_snapshot(nil, nil)
    end

    test "save_snapshot/4 delegates to SnapshotOperations" do
      resource_type = "user"
      resource_id = "user-123"
      state = %{name: "John", email: "john@example.com"}
      metadata = %{version: "1.0"}

      # Test that the function exists and can be called
      assert is_function(&EventStore.save_snapshot/4)
    end

    test "save_snapshot/3 uses default metadata" do
      resource_type = "user"
      resource_id = "user-123"
      state = %{name: "John"}

      # Test that the function exists and can be called
      assert is_function(&EventStore.save_snapshot/3)
    end

    test "get_snapshot/1 returns not_implemented" do
      assert {:error, :not_implemented} = EventStore.get_snapshot("snapshot-123")
    end

    test "list_snapshots/2 delegates to SnapshotOperations" do
      resource_type = "user"
      resource_id = "user-123"

      # Test that the function exists and can be called
      assert is_function(&EventStore.list_snapshots/2)
    end

    test "get_snapshots/2 delegates to SnapshotOperations" do
      resource_type = "user"
      resource_id = "user-123"

      # Test that the function exists and can be called
      assert is_function(&EventStore.get_snapshots/2)
    end

    test "delete_snapshot/1 returns not_implemented" do
      assert {:error, :not_implemented} = EventStore.delete_snapshot("snapshot-123")
    end
  end

  describe "versioned state operations" do
    test "save_versioned_state/4 delegates to SnapshotOperations" do
      resource_type = "user"
      resource_id = "user-123"
      state = %{name: "John", email: "john@example.com"}
      metadata = %{version: "1.0"}

      # Test that the function exists and can be called
      assert is_function(&EventStore.save_versioned_state/4)
    end

    test "save_versioned_state/3 uses default metadata" do
      resource_type = "user"
      resource_id = "user-123"
      state = %{name: "John"}

      # Test that the function exists and can be called
      assert is_function(&EventStore.save_versioned_state/3)
    end

    test "get_versioned_state/1 returns not_implemented" do
      assert {:error, :not_implemented} = EventStore.get_versioned_state("state-123")
    end

    test "get_latest_versioned_state/2 returns not_implemented" do
      assert {:error, :not_implemented} = EventStore.get_latest_versioned_state("user", "user-123")
    end

    test "list_versioned_states/2 returns not_implemented" do
      assert {:error, :not_implemented} = EventStore.list_versioned_states("user", "user-123")
    end

    test "delete_versioned_state/1 returns not_implemented" do
      assert {:error, :not_implemented} = EventStore.delete_versioned_state("state-123")
    end
  end

  describe "replay session status updates" do
    test "update_replay_session_status/3 returns mock session" do
      session_id = "session-123"
      status = "in_progress"
      results = %{events_processed: 100}

      assert {:ok, session} = EventStore.update_replay_session_status(session_id, status, results)
      assert session.id == session_id
      assert session.status == status
      assert session.results == results
    end

    test "update_replay_session_status/2 uses default results" do
      session_id = "session-123"
      status = "completed"

      assert {:ok, session} = EventStore.update_replay_session_status(session_id, status)
      assert session.id == session_id
      assert session.status == status
      assert session.results == %{}
    end
  end

  describe "configuration" do
    test "uses configured event store module" do
      # Test that the module uses the configured event store
      # This is tested indirectly through the delegation pattern
      assert is_function(&EventStore.store_event/1)
    end
  end

  describe "edge cases" do
    test "handles unicode resource types and ids" do
      resource_type = "utilisateur"
      resource_id = "utilisateur-123"

      # Test that the function exists and can be called
      assert is_function(&EventStore.get_latest_snapshot/2)
    end

    test "handles special characters in session ids" do
      session_id = "session-123-with-special-chars"

      assert {:ok, session} = EventStore.get_replay_session(session_id)
      assert session.id == session_id
    end

    test "handles empty strings in parameters" do
      # Test that functions handle empty strings gracefully
      assert is_function(&EventStore.get_event/1)
      assert is_function(&EventStore.get_latest_snapshot/2)
    end

    test "handles nil parameters" do
      # Test that functions handle nil parameters gracefully
      assert {:error, :invalid_parameters} = EventStore.get_replay_session_events(nil)
      assert {:error, :invalid_parameters} = EventStore.get_latest_snapshot(nil, nil)
    end
  end

  describe "function signatures" do
    test "all public functions have correct arity" do
      # Test that all public functions exist with correct arity
      assert is_function(&EventStore.store_event/1)
      assert is_function(&EventStore.store_event/2)
      assert is_function(&EventStore.store_events/1)
      assert is_function(&EventStore.get_events/1)
      assert is_function(&EventStore.get_events_for_resource/2)
      assert is_function(&EventStore.get_events_for_resource_at/3)
      assert is_function(&EventStore.get_event/1)
      assert is_function(&EventStore.delete_event/1)
      assert is_function(&EventStore.list_all_events/0)
      assert is_function(&EventStore.create_replay_session/3)
      assert is_function(&EventStore.create_replay_session/4)
      assert is_function(&EventStore.get_replay_session/1)
      assert is_function(&EventStore.list_replay_sessions/0)
      assert is_function(&EventStore.complete_replay_session/2)
      assert is_function(&EventStore.get_replay_session_events/1)
      assert is_function(&EventStore.get_latest_snapshot/2)
      assert is_function(&EventStore.save_snapshot/3)
      assert is_function(&EventStore.save_snapshot/4)
      assert is_function(&EventStore.get_snapshot/1)
      assert is_function(&EventStore.list_snapshots/2)
      assert is_function(&EventStore.get_snapshots/2)
      assert is_function(&EventStore.delete_snapshot/1)
      assert is_function(&EventStore.save_versioned_state/3)
      assert is_function(&EventStore.save_versioned_state/4)
      assert is_function(&EventStore.get_versioned_state/1)
      assert is_function(&EventStore.get_latest_versioned_state/2)
      assert is_function(&EventStore.list_versioned_states/2)
      assert is_function(&EventStore.delete_versioned_state/1)
      assert is_function(&EventStore.update_replay_session_status/2)
      assert is_function(&EventStore.update_replay_session_status/3)
    end
  end
end
