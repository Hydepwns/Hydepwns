defmodule HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResourceTest do
  @moduledoc """
  Tests for the EventSourcedResource behavior to verify proper integration between resources and the event system. These tests validate the core functionality of event sourcing including state reconstruction, command execution, and event application.
  """
  use HydepwnsLiveview.DataCase

  defmodule TestResource do
    @moduledoc """
    Test implementation of EventSourcedResource behavior for testing purposes.
    Implements a simple counter that can be incremented and decremented.
    """
    use HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResource

    def resource_type, do: :test_resource

    def initial_state, do: %{value: 0}

    def apply_event(state, %{type: "increment", data: %{amount: amount}}) do
      Map.update!(state, :value, &(&1 + amount))
    end

    def apply_event(state, %{type: "decrement", data: %{amount: amount}}) do
      Map.update!(state, :value, &(&1 - amount))
    end

    def apply_event(state, _event), do: state

    def create_events(params) do
      [
        %HydepwnsLiveview.Events.Core.Event{
          type: "increment",
          resource_id: params.id,
          resource_type: "test_resource",
          data: %{amount: params.initial_value},
          timestamp: DateTime.utc_now()
        }
      ]
    end

    def execute_command(state, "increment", %{amount: amount}) do
      [
        %HydepwnsLiveview.Events.Core.Event{
          type: "increment",
          resource_id: state.id,
          resource_type: "test_resource",
          data: %{amount: amount},
          timestamp: DateTime.utc_now()
        }
      ]
    end

    def execute_command(state, "decrement", %{amount: amount}) do
      [
        %HydepwnsLiveview.Events.Core.Event{
          type: "decrement",
          resource_id: state.id,
          resource_type: "test_resource",
          data: %{amount: amount},
          timestamp: DateTime.utc_now()
        }
      ]
    end
  end

  describe "get/1" do
    test "retrieves a valid resource" do
      {:ok, _} = TestResource.create(%{id: "123", initial_value: 10})
      assert {:ok, state} = TestResource.get("123")
      assert state.value == 10
    end

    test "rejects invalid id" do
      assert {:error, :invalid_id} = TestResource.get("")
      assert {:error, :invalid_id} = TestResource.get(nil)
      assert {:error, :invalid_id} = TestResource.get(123)
    end
  end

  describe "get_at/2" do
    test "retrieves a resource at a specific time" do
      {:ok, _} = TestResource.create(%{id: "123", initial_value: 10})
      timestamp = DateTime.utc_now()
      {:ok, _} = TestResource.execute("123", "increment", %{amount: 5})
      
      assert {:ok, state} = TestResource.get_at("123", timestamp)
      assert state.value == 10
    end

    test "rejects invalid parameters" do
      assert {:error, :invalid_parameters} = TestResource.get_at("", DateTime.utc_now())
      assert {:error, :invalid_parameters} = TestResource.get_at("123", "not_a_datetime")
      assert {:error, :invalid_parameters} = TestResource.get_at(nil, DateTime.utc_now())
    end
  end

  describe "create/1" do
    test "creates a valid resource" do
      assert {:ok, state} = TestResource.create(%{id: "123", initial_value: 10})
      assert state.value == 10
    end

    test "rejects invalid parameters" do
      assert {:error, :invalid_parameters} = TestResource.create("not_a_map")
      assert {:error, :invalid_parameters} = TestResource.create(nil)
      assert {:error, :invalid_parameters} = TestResource.create(123)
    end
  end

  describe "execute/4" do
    setup do
      {:ok, _} = TestResource.create(%{id: "123", initial_value: 10})
      :ok
    end

    test "executes a valid command" do
      assert {:ok, state} = TestResource.execute("123", "increment", %{amount: 5})
      assert state.value == 15
    end

    test "rejects invalid parameters" do
      assert {:error, :invalid_parameters} = TestResource.execute("", "increment", %{amount: 5})
      assert {:error, :invalid_parameters} = TestResource.execute("123", "", %{amount: 5})
      assert {:error, :invalid_parameters} = TestResource.execute("123", "increment", "not_a_map")
      assert {:error, :invalid_parameters} = TestResource.execute("123", "increment", %{amount: 5}, "not_a_map")
    end
  end

  describe "get_history/2" do
    setup do
      {:ok, _} = TestResource.create(%{id: "123", initial_value: 10})
      {:ok, _} = TestResource.execute("123", "increment", %{amount: 5})
      :ok
    end

    test "retrieves resource history" do
      assert {:ok, events} = TestResource.get_history("123", %{})
      assert length(events) == 2
    end

    test "rejects invalid parameters" do
      assert {:error, :invalid_parameters} = TestResource.get_history("", %{})
      assert {:error, :invalid_parameters} = TestResource.get_history("123", "not_a_map")
      assert {:error, :invalid_parameters} = TestResource.get_history(nil, %{})
    end
  end

  describe "rebuild_from_events/3" do
    test "rebuilds state from valid events" do
      events = [
        %HydepwnsLiveview.Events.Core.Event{
          type: "increment",
          resource_id: "123",
          resource_type: "test_resource",
          data: %{amount: 5},
          timestamp: DateTime.utc_now()
        },
        %HydepwnsLiveview.Events.Core.Event{
          type: "decrement",
          resource_id: "123",
          resource_type: "test_resource",
          data: %{amount: 2},
          timestamp: DateTime.utc_now()
        }
      ]

      initial_state = %{value: 0}
      assert {:ok, final_state} = TestResource.rebuild_from_events(events, initial_state, &TestResource.apply_event/2)
      assert final_state.value == 3
    end

    test "rejects invalid parameters" do
      assert {:error, :invalid_parameters} = TestResource.rebuild_from_events("not_a_list", %{}, &TestResource.apply_event/2)
      assert {:error, :invalid_parameters} = TestResource.rebuild_from_events([], "not_a_map", &TestResource.apply_event/2)
      assert {:error, :invalid_parameters} = TestResource.rebuild_from_events([], %{}, "not_a_function")
    end
  end
end 