defmodule HydepwnsLiveview.TestSupport.MockEventStore do
  @moduledoc """
  Mock EventStore for testing purposes.
  """
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    {:ok, %{events: [], next_id: 1}}
  end

  def handle_call({:store_event, type, data}, _from, state) when is_binary(type) and is_map(data) do
    event = %{
      id: Ecto.UUID.generate(),
      type: type,
      data: data,
      timestamp: DateTime.utc_now(),
      metadata: %{}
    }

    new_state = %{state | events: [event | state.events]}
    {:reply, {:ok, event}, new_state}
  end

  def handle_call({:store_event, event, _metadata}, _from, state) when is_map(event) do
    # Handle single event object
    event = if Map.get(event, :id) do
      event
    else
      Map.put(event, :id, Ecto.UUID.generate())
    end

    # Convert Event struct to map for storage
    event_map = case event do
      %{__struct__: HydepwnsLiveview.Events.Schemas.Event} ->
        %{
          id: event.id,
          type: event.type,
          data: event.data,
          resource_type: event.resource_type,
          resource_id: event.resource_id,
          correlation_id: event.correlation_id,
          causation_id: event.causation_id,
          metadata: event.metadata,
          timestamp: event.timestamp
        }
      _ -> event
    end

    new_state = %{state | events: [event_map | state.events]}
    {:reply, {:ok, event_map}, new_state}
  end

  def handle_call({:store_event, event}, _from, state) when is_map(event) do
    # Handle single event object without metadata
    event = if Map.get(event, :id) do
      event
    else
      Map.put(event, :id, Ecto.UUID.generate())
    end

    # Convert Event struct to map for storage
    event_map = case event do
      %{__struct__: HydepwnsLiveview.Events.Schemas.Event} ->
        %{
          id: event.id,
          type: event.type,
          data: event.data,
          resource_type: event.resource_type,
          resource_id: event.resource_id,
          correlation_id: event.correlation_id,
          causation_id: event.causation_id,
          metadata: event.metadata,
          timestamp: event.timestamp
        }
      _ -> event
    end

    new_state = %{state | events: [event_map | state.events]}
    {:reply, {:ok, event_map}, new_state}
  end

  def handle_call({:store_events, events}, _from, state) when is_list(events) do
    # Handle multiple events
    {stored_events, new_state} = Enum.reduce(events, {[], state}, fn event, {acc, current_state} ->
      event = if Map.get(event, :id) do
        event
      else
        Map.put(event, :id, Ecto.UUID.generate())
      end

      # Convert Event struct to map for storage
      event_map = case event do
        %{__struct__: HydepwnsLiveview.Events.Schemas.Event} ->
          %{
            id: event.id,
            type: event.type,
            data: event.data,
            resource_type: event.resource_type,
            resource_id: event.resource_id,
            correlation_id: event.correlation_id,
            causation_id: event.causation_id,
            metadata: event.metadata,
            timestamp: event.timestamp
          }
        _ -> event
      end

      new_state = %{current_state | events: [event_map | current_state.events]}
      {[event_map | acc], new_state}
    end)

    {:reply, {:ok, Enum.reverse(stored_events)}, new_state}
  end

  def handle_call({:get_events, criteria}, _from, state) do
    events = filter_events(state.events, criteria)
    {:reply, {:ok, events}, state}
  end

  def handle_call(:list_events, _from, state) do
    {:reply, {:ok, state.events}, state}
  end

  def handle_call(:reset, _from, _state) do
    {:reply, :ok, %{events: [], next_id: 1}}
  end

  def handle_call({:get_event, id}, _from, state) do
    event = Enum.find(state.events, fn event -> event.id == id end)
    {:reply, {:ok, event}, state}
  end

  def handle_call({:get_events_for_resource, resource_type, resource_id}, _from, state) do
    events = Enum.filter(state.events, fn event ->
      # Handle both Event structs and maps
      {event_resource_type, event_resource_id} = case event do
        %HydepwnsLiveview.Events.Core.Event{} ->
          {event.resource_type, event.resource_id}
        %{} ->
          # For maps, try different possible locations
          resource_type_val = Map.get(event, :resource_type) ||
                             get_in(event, [:data, :resource_type]) ||
                             get_in(event, [:data, :data, :resource_type])
          resource_id_val = Map.get(event, :resource_id) ||
                           get_in(event, [:data, :resource_id]) ||
                           get_in(event, [:data, :data, :resource_id])
          {resource_type_val, resource_id_val}
        _ ->
          {nil, nil}
      end

      event_resource_type == resource_type && event_resource_id == resource_id
    end)
    {:reply, {:ok, Enum.reverse(events)}, state}
  end

  def handle_call({:get_events_for_resource_at, resource_type, resource_id, timestamp}, _from, state) do
    events = Enum.filter(state.events, fn event ->
      # Handle both Event structs and maps
      {event_resource_type, event_resource_id} = case event do
        %HydepwnsLiveview.Events.Core.Event{} ->
          {event.resource_type, event.resource_id}
        %{} ->
          # For maps, try different possible locations
          resource_type_val = Map.get(event, :resource_type) ||
                             get_in(event, [:data, :resource_type]) ||
                             get_in(event, [:data, :data, :resource_type])
          resource_id_val = Map.get(event, :resource_id) ||
                           get_in(event, [:data, :resource_id]) ||
                           get_in(event, [:data, :data, :resource_id])
          {resource_type_val, resource_id_val}
        _ ->
          {nil, nil}
      end

      event_resource_type == resource_type &&
      event_resource_id == resource_id &&
      DateTime.compare(event.timestamp, timestamp) == :lte
    end)
    {:reply, {:ok, Enum.reverse(events)}, state}
  end

  def handle_call(:get_all_events, _from, state) do
    {:reply, {:ok, state.events}, state}
  end

  # Client API
  def store_event(type, data) when is_binary(type) and is_map(data) do
    GenServer.call(__MODULE__, {:store_event, type, data})
  end

  def store_event(event, metadata \\ %{}) when is_map(event) do
    GenServer.call(__MODULE__, {:store_event, event, metadata})
  end

  def store_events(events) when is_list(events) do
    GenServer.call(__MODULE__, {:store_events, events})
  end

  def get_events(criteria) do
    GenServer.call(__MODULE__, {:get_events, criteria})
  end

  def list_events do
    GenServer.call(__MODULE__, :list_events)
  end

  def get_event(id) do
    GenServer.call(__MODULE__, {:get_event, id})
  end

  def get_events_for_resource(resource_type, resource_id) do
    GenServer.call(__MODULE__, {:get_events_for_resource, resource_type, resource_id})
  end

  def get_events_for_resource_at(resource_type, resource_id, timestamp) do
    GenServer.call(__MODULE__, {:get_events_for_resource_at, resource_type, resource_id, timestamp})
  end

  def get_all_events do
    GenServer.call(__MODULE__, :get_all_events)
  end

  def reset do
    GenServer.call(__MODULE__, :reset)
  end

  # Private functions
  defp filter_events(events, criteria) do
    Enum.filter(events, fn event ->
      Enum.all?(criteria, fn {key, value} ->
        Map.get(event, key) == value
      end)
    end)
  end
end
