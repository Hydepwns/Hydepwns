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

    # Subscribe to all resource and document events
    EventBus.subscribe(self(), [
      "resource.created",
      "resource.updated",
      "resource.deleted",
      "document.created",
      "document.updated",
      "document.deleted"
    ])

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
    Logger.info(
      "ResourceProjection received event: #{event.type} for resource: #{event.resource_id}"
    )

    new_state = update_state(state, event)
    {:noreply, new_state}
  end

  # Private Functions

  defp update_state(state, event) do
    case event do
      %{type: type, resource_id: id, data: data}
      when type in ["resource.created", "document.created"] ->
        Logger.info("ResourceProjection: Processing #{type} for #{id}")

        %{
          state
          | resources: Map.put(state.resources, id, data),
            last_event_id: event.id,
            last_updated: DateTime.utc_now()
        }

      %{type: type, resource_id: id, data: data}
      when type in ["resource.updated", "document.updated"] ->
        Logger.info("ResourceProjection: Processing #{type} for #{id}")

        %{
          state
          | resources: Map.update(state.resources, id, data, &Map.merge(&1, data)),
            last_event_id: event.id,
            last_updated: DateTime.utc_now()
        }

      %{type: type, resource_id: id} when type in ["resource.deleted", "document.deleted"] ->
        Logger.info("ResourceProjection: Processing #{type} for #{id}")

        %{
          state
          | resources: Map.delete(state.resources, id),
            last_event_id: event.id,
            last_updated: DateTime.utc_now()
        }

      _ ->
        Logger.debug("ResourceProjection: Ignoring event type: #{event.type}")
        state
    end
  end
end
