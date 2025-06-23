defmodule HydepwnsLiveview.Events.Projections.ResourceProjection do
  @moduledoc """
  Projection for resource data.

  This module maintains a projection of resource data, allowing for efficient
  querying and analysis of resources without having to replay the entire event
  stream each time.
  """

  use GenServer
  require Logger

  alias HydepwnsLiveview.Events.EventBus

  # Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def get_state do
    GenServer.call(__MODULE__, :get_state)
  end

  def rebuild do
    GenServer.call(__MODULE__, :rebuild)
  end

  # Server Callbacks

  @impl true
  def init(_opts) do
    state = %{
      resources: %{},
      last_event_id: nil,
      last_updated: nil
    }

    # Subscribe to events
    EventBus.subscribe(self())

    {:ok, state}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call(:rebuild, _from, _state) do
    # TODO: Implement rebuilding from event store
    {:reply, :ok, %{resources: %{}, last_event_id: nil, last_updated: nil}}
  end

  @impl true
  def handle_info({:event, event}, state) do
    new_state = update_state(state, event)
    {:noreply, new_state}
  end

  # Private Functions

  defp update_state(state, event) do
    case event do
      %{type: "resource_created", resource_id: id, data: data} ->
        %{
          state
          | resources: Map.put(state.resources, id, data),
            last_event_id: event.id,
            last_updated: DateTime.utc_now()
        }

      %{type: "resource_updated", resource_id: id, data: data} ->
        %{
          state
          | resources: Map.update(state.resources, id, data, &Map.merge(&1, data)),
            last_event_id: event.id,
            last_updated: DateTime.utc_now()
        }

      %{type: "resource_deleted", resource_id: id} ->
        %{
          state
          | resources: Map.delete(state.resources, id),
            last_event_id: event.id,
            last_updated: DateTime.utc_now()
        }

      _ ->
        state
    end
  end
end
