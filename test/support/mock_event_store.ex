defmodule HydepwnsLiveview.TestSupport.MockEventStore do
  use Agent

  def start_link(_opts) do
    IO.puts("🟣 MockEventStore.start_link called")
    result = Agent.start_link(fn -> %{} end, name: __MODULE__)
    IO.puts("🟣 MockEventStore.start_link result: #{inspect(result)}")
    result
  end

  def reset do
    IO.puts("🟣 MockEventStore.reset called")
    Agent.update(__MODULE__, fn _ -> %{} end)
  end

  # Store a single event (Event struct)
  def store_event(%{type: _type, resource_type: _resource_type, resource_id: _resource_id} = event, _metadata) do
    IO.puts("🔵 MockEventStore.store_event: #{event.type} for #{event.resource_type}:#{event.resource_id}")
    Agent.update(__MODULE__, fn state ->
      key = {to_atom(event.resource_type), event.resource_id}
      new_state = Map.update(state, key, [event], fn events -> events ++ [event] end)
      IO.puts("🔵 MockEventStore.store_event: state after update: #{inspect(new_state)}")
      new_state
    end)
    {:ok, event}
  end

  # Store a single event (type and data)
  def store_event(type, data) when is_binary(type) and is_map(data) do
    event = %{
      type: type,
      data: data,
      resource_type: "test_resource",
      resource_id: "123",
      id: Ecto.UUID.generate(),
      timestamp: DateTime.utc_now()
    }
    store_event(event)
  end

  def store_event(%{type: _type, resource_type: _resource_type, resource_id: _resource_id} = event) do
    store_event(event, %{})
  end

  # Store multiple events
  def store_events(events) when is_list(events) do
    results = Enum.map(events, &store_event/1)
    case Enum.find(results, fn {status, _} -> status == :error end) do
      nil -> {:ok, Enum.map(results, fn {:ok, event} -> event end)}
      error -> error
    end
  end

  # Get events based on criteria
  def get_events(criteria) do
    events =
      Agent.get(__MODULE__, fn state ->
        state
        |> Map.values()
        |> List.flatten()
        |> Enum.filter(fn event ->
          case criteria do
            %{resource_type: resource_type, resource_id: resource_id} ->
              event.resource_type == to_atom(resource_type) && event.resource_id == resource_id
            %{event_type: event_type} ->
              event.type == event_type
            _ ->
              true
          end
        end)
      end)
    IO.puts("🟢 MockEventStore.get_events: #{length(events)} events matching criteria")
    {:ok, events}
  end

  def get_events_for_resource(resource_type, resource_id) do
    events =
      Agent.get(__MODULE__, fn state ->
        IO.puts("🟡 MockEventStore.get_events_for_resource: current state: #{inspect(state)}")
        Map.get(state, {to_atom(resource_type), resource_id}, [])
      end)
    IO.puts("🟡 MockEventStore.get_events_for_resource: #{resource_type}:#{resource_id} -> #{length(events)} events")
    {:ok, events}
  end

  def get_events_for_resource(resource_type, resource_id, _opts) do
    get_events_for_resource(resource_type, resource_id)
  end

  def get_events_for_resource_at(resource_type, resource_id, timestamp) do
    events =
      Agent.get(__MODULE__, fn state ->
        Map.get(state, {to_atom(resource_type), resource_id}, [])
        |> Enum.filter(fn event -> DateTime.compare(event.timestamp, timestamp) != :gt end)
      end)
    IO.puts("🟢 MockEventStore.get_events_for_resource_at: #{resource_type}:#{resource_id} at #{timestamp} -> #{length(events)} events")
    {:ok, events}
  end

  def get_all_events do
    events =
      Agent.get(__MODULE__, fn state ->
        state
        |> Map.values()
        |> List.flatten()
      end)
    IO.puts("🟢 MockEventStore.get_all_events: #{length(events)} total events")
    {:ok, events}
  end

  def get_event(id) do
    events =
      Agent.get(__MODULE__, fn state ->
        state
        |> Map.values()
        |> List.flatten()
        |> Enum.find(fn event -> event.id == id end)
      end)
    IO.puts("🟢 MockEventStore.get_event: #{id} -> #{if events, do: "found", else: "not found"}")
    {:ok, events}
  end

  defp to_atom(val) when is_atom(val), do: val
  defp to_atom(val) when is_binary(val), do: String.to_atom(val)
end 