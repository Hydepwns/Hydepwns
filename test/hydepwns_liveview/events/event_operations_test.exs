defmodule HydepwnsLiveview.Events.EventOperationsTest do
  use HydepwnsLiveview.DataCase

  alias HydepwnsLiveview.Events.EventOperations
  alias HydepwnsLiveview.Events.Core.Event

  describe "store_event/1" do
    test "stores a valid event" do
      event = %Event{
        type: "test_event",
        resource_id: "123",
        resource_type: "test_resource",
        data: %{key: "value"},
        timestamp: DateTime.utc_now()
      }

      assert {:ok, stored_event} = EventOperations.store_event(event)
      assert stored_event.type == event.type
      assert stored_event.data == event.data
      assert stored_event.resource_id == event.resource_id
      assert stored_event.resource_type == event.resource_type
    end

    test "rejects invalid event" do
      assert {:error, :invalid_event} = EventOperations.store_event("not_an_event")
      assert {:error, :invalid_event} = EventOperations.store_event(nil)
      assert {:error, :invalid_event} = EventOperations.store_event(%{})
    end
  end

  describe "store_event/2" do
    test "stores a valid event with type and data" do
      type = "test_event"
      data = %{key: "value"}

      assert {:ok, event} = EventOperations.store_event(type, data)
      assert event.type == type
      assert event.data == data
      assert is_struct(event.timestamp, DateTime)
    end

    test "rejects invalid event type" do
      assert {:error, :invalid_parameters} = EventOperations.store_event("", %{})
      assert {:error, :invalid_parameters} = EventOperations.store_event("ab", %{})
      assert {:error, :invalid_parameters} = EventOperations.store_event(123, %{})
      assert {:error, :invalid_parameters} = EventOperations.store_event(nil, %{})
    end

    test "rejects invalid event data" do
      assert {:error, :invalid_parameters} =
               EventOperations.store_event("test_event", "not_a_map")

      assert {:error, :invalid_parameters} = EventOperations.store_event("test_event", nil)
      assert {:error, :invalid_parameters} = EventOperations.store_event("test_event", 123)
    end
  end

  describe "store_events/1" do
    test "stores multiple valid events" do
      events = [
        %Event{
          type: "test_event_1",
          resource_id: "123",
          resource_type: "test_resource",
          data: %{key: "value1"},
          timestamp: DateTime.utc_now()
        },
        %Event{
          type: "test_event_2",
          resource_id: "123",
          resource_type: "test_resource",
          data: %{key: "value2"},
          timestamp: DateTime.utc_now()
        }
      ]

      assert {:ok, stored_events} = EventOperations.store_events(events)
      assert length(stored_events) == 2
      assert Enum.all?(stored_events, &is_struct(&1, Event))
    end

    test "rejects empty event list" do
      assert {:error, :empty_event_list} = EventOperations.store_events([])
    end

    test "rejects invalid event list" do
      assert {:error, :invalid_events} = EventOperations.store_events("not_a_list")
      assert {:error, :invalid_events} = EventOperations.store_events(nil)
      assert {:error, :invalid_events} = EventOperations.store_events(%{})
    end
  end

  describe "get_events/1" do
    test "retrieves events with valid criteria" do
      # First create some test events
      {:ok, event1} = EventOperations.store_event("test_event_1", %{key: "value1"})
      {:ok, _event2} = EventOperations.store_event("test_event_2", %{key: "value2"})

      # Test various criteria
      assert {:ok, events} = EventOperations.get_events(%{})
      assert length(events) >= 2

      assert {:ok, [event]} = EventOperations.get_events(%{id: event1.id})
      assert event.id == event1.id

      assert {:ok, events} = EventOperations.get_events(%{event_type: "test_event_1"})
      assert Enum.all?(events, &(&1.type == "test_event_1"))

      assert {:ok, events} = EventOperations.get_events(%{limit: 1})
      assert length(events) == 1
    end

    test "rejects invalid criteria" do
      assert {:error, :invalid_criteria} = EventOperations.get_events("not_a_map")
      assert {:error, :invalid_criteria} = EventOperations.get_events(nil)
      assert {:error, :invalid_criteria} = EventOperations.get_events(123)
    end

    test "handles invalid query parameters" do
      assert {:ok, []} = EventOperations.get_events(%{id: "invalid_id"})
      assert {:ok, []} = EventOperations.get_events(%{event_type: "nonexistent_type"})
    end
  end
end
