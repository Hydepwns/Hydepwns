defmodule HydepwnsLiveview.Events.SnapshotOperationsTest do
  use HydepwnsLiveview.DataCase

  alias HydepwnsLiveview.Events.SnapshotOperations
  alias HydepwnsLiveview.Events.Schemas.Event

  describe "save_snapshot/4" do
    test "saves a valid snapshot" do
      state = %{value: 42}
      metadata = %{event_id: "123", version: 1}

      assert {:ok, snapshot} =
               SnapshotOperations.save_snapshot("test_resource", "123", state, metadata)

      assert snapshot.resource_type == "test_resource"
      assert snapshot.resource_id == "123"
      assert snapshot.state == state
      assert snapshot.metadata == metadata
    end

    test "saves a snapshot with default metadata" do
      state = %{value: 42}

      assert {:ok, snapshot} = SnapshotOperations.save_snapshot("test_resource", "123", state)
      assert snapshot.resource_type == "test_resource"
      assert snapshot.resource_id == "123"
      assert snapshot.state == state
      assert snapshot.metadata == %{}
    end

    test "rejects invalid parameters" do
      assert {:error, :invalid_parameters} = SnapshotOperations.save_snapshot("", "123", %{}, %{})

      assert {:error, :invalid_parameters} =
               SnapshotOperations.save_snapshot("test", "", %{}, %{})

      assert {:error, :invalid_parameters} =
               SnapshotOperations.save_snapshot("test", "123", "not_a_map", %{})

      assert {:error, :invalid_parameters} =
               SnapshotOperations.save_snapshot("test", "123", %{}, "not_a_map")
    end
  end

  describe "get_latest_snapshot/2" do
    setup do
      # Create multiple snapshots for the same resource
      {:ok, snapshot1} =
        SnapshotOperations.save_snapshot("test_resource", "123", %{value: 1}, %{version: 1})

      {:ok, snapshot2} =
        SnapshotOperations.save_snapshot("test_resource", "123", %{value: 2}, %{version: 2})

      {:ok, snapshot3} =
        SnapshotOperations.save_snapshot("test_resource", "123", %{value: 3}, %{version: 3})

      %{snapshots: [snapshot1, snapshot2, snapshot3]}
    end

    test "retrieves the latest snapshot", %{snapshots: [_, _, latest]} do
      assert {:ok, snapshot} = SnapshotOperations.get_latest_snapshot("test_resource", "123")
      assert snapshot.id == latest.id
      assert snapshot.state["value"] == 3
    end

    test "returns not found for non-existent resource" do
      assert {:error, :not_found} =
               SnapshotOperations.get_latest_snapshot("test_resource", "nonexistent")
    end

    test "rejects invalid parameters" do
      assert {:error, :invalid_parameters} = SnapshotOperations.get_latest_snapshot("", "123")
      assert {:error, :invalid_parameters} = SnapshotOperations.get_latest_snapshot("test", "")
    end
  end

  describe "count_events_since_last_snapshot/2" do
    setup do
      # Create a snapshot and some events
      {:ok, snapshot} =
        SnapshotOperations.save_snapshot("test_resource", "123", %{value: 1}, %{
          event_id: "event1"
        })

      # Create events after the snapshot
      {:ok, _} =
        Repo.insert(%Event{
          resource_type: "test_resource",
          resource_id: "123",
          type: "test_event",
          data: %{},
          timestamp: DateTime.utc_now()
        })

      {:ok, _} =
        Repo.insert(%Event{
          resource_type: "test_resource",
          resource_id: "123",
          type: "test_event",
          data: %{},
          timestamp: DateTime.utc_now()
        })

      %{snapshot: snapshot}
    end

    test "counts events since last snapshot" do
      assert {:ok, count} =
               SnapshotOperations.count_events_since_last_snapshot("test_resource", "123")

      assert count == 2
    end

    test "counts all events when no snapshot exists" do
      # Insert events for the nonexistent resource
      {:ok, _} =
        Repo.insert(%Event{
          resource_type: "test_resource",
          resource_id: "nonexistent",
          type: "test_event",
          data: %{},
          timestamp: DateTime.utc_now()
        })

      {:ok, _} =
        Repo.insert(%Event{
          resource_type: "test_resource",
          resource_id: "nonexistent",
          type: "test_event",
          data: %{},
          timestamp: DateTime.utc_now()
        })

      assert {:ok, count} =
               SnapshotOperations.count_events_since_last_snapshot("test_resource", "nonexistent")

      assert count == 2
    end

    test "rejects invalid parameters" do
      assert {:error, :invalid_parameters} =
               SnapshotOperations.count_events_since_last_snapshot("", "123")

      assert {:error, :invalid_parameters} =
               SnapshotOperations.count_events_since_last_snapshot("test", "")
    end
  end

  describe "save_versioned_state/4" do
    test "saves a valid versioned state" do
      state = %{value: 42}

      opts = [
        label: "test_version",
        replay_id: Ecto.UUID.generate(),
        created_at: DateTime.utc_now(),
        point_in_time: DateTime.utc_now(),
        metadata: %{version: 1}
      ]

      assert {:ok, versioned_state} =
               SnapshotOperations.save_versioned_state("test_resource", "123", state, opts)

      assert versioned_state.resource_type == "test_resource"
      assert versioned_state.resource_id == "123"
      assert versioned_state.state == state
      assert versioned_state.label == "test_version"
      assert is_binary(versioned_state.replay_id)
      assert versioned_state.metadata == %{version: 1}
    end

    test "saves versioned state with minimal options" do
      state = %{value: 42}
      opts = [label: "test_version"]

      assert {:ok, versioned_state} =
               SnapshotOperations.save_versioned_state("test_resource", "123", state, opts)

      assert versioned_state.resource_type == "test_resource"
      assert versioned_state.resource_id == "123"
      assert versioned_state.state == state
      assert versioned_state.label == "test_version"
      assert versioned_state.metadata == %{}
    end

    test "rejects invalid parameters" do
      assert {:error, :invalid_parameters} =
               SnapshotOperations.save_versioned_state("", "123", %{}, label: "test")

      assert {:error, :invalid_parameters} =
               SnapshotOperations.save_versioned_state("test", "", %{}, label: "test")

      assert {:error, :invalid_parameters} =
               SnapshotOperations.save_versioned_state("test", "123", "not_a_map", label: "test")

      assert {:error, :invalid_parameters} =
               SnapshotOperations.save_versioned_state("test", "123", %{}, "not_a_list")
    end
  end

  describe "get_snapshots/2" do
    setup do
      # Create multiple snapshots for the same resource
      {:ok, snapshot1} =
        SnapshotOperations.save_snapshot("test_resource", "123", %{value: 1}, %{version: 1})

      {:ok, snapshot2} =
        SnapshotOperations.save_snapshot("test_resource", "123", %{value: 2}, %{version: 2})

      {:ok, snapshot3} =
        SnapshotOperations.save_snapshot("test_resource", "123", %{value: 3}, %{version: 3})

      %{snapshots: [snapshot1, snapshot2, snapshot3]}
    end

    test "retrieves all snapshots in order", %{snapshots: [first, second, third]} do
      assert {:ok, snapshots} = SnapshotOperations.get_snapshots("test_resource", "123")
      assert length(snapshots) == 3
      assert Enum.map(snapshots, & &1.id) == [first.id, second.id, third.id]
    end

    test "returns empty list for non-existent resource" do
      assert {:ok, snapshots} = SnapshotOperations.get_snapshots("test_resource", "nonexistent")
      assert snapshots == []
    end

    test "rejects invalid parameters" do
      assert {:error, :invalid_parameters} = SnapshotOperations.get_snapshots("", "123")
      assert {:error, :invalid_parameters} = SnapshotOperations.get_snapshots("test", "")
    end
  end
end
