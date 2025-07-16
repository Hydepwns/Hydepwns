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
    # Rebuild projection from event store
    Logger.info("ResourceProjection: Starting rebuild from event store")

    # Get all events from the event store
    case HydepwnsLiveview.Events.Core.EventStore.get_events() do
      {:ok, events} ->
        Logger.info("ResourceProjection: Found #{length(events)} events to rebuild from")

        # Debug: Inspect first event to understand format
        if length(events) > 0 do
          first_event = List.first(events)
          Logger.info("ResourceProjection: First event format: #{inspect(first_event)}")
          Logger.info("ResourceProjection: First event data type: #{inspect(typeof(first_event.data))}")
          Logger.info("ResourceProjection: First event data: #{inspect(first_event.data)}")
        end

        # Process events in chronological order to rebuild state
        rebuilt_state = Enum.reduce(events, %{resources: %{}, last_event_id: nil, last_updated: nil}, fn event, state ->
          Logger.info("ResourceProjection: Processing event #{event.id} of type #{event.type}")

          # Ensure event data is properly decoded
          decoded_event = case event.data do
            data when is_binary(data) ->
              case Jason.decode(data) do
                {:ok, decoded} -> %{event | data: decoded}
                {:error, _} -> event
              end
            data when is_map(data) ->
              event
            _ ->
              Logger.warning("ResourceProjection: Unknown event data format: #{inspect(event.data)}")
              event
          end

          new_state = update_state(state, decoded_event)
          Logger.info("ResourceProjection: State after event #{event.id}: #{map_size(new_state.resources)} resources")
          new_state
        end)

        Logger.info("ResourceProjection: Rebuild complete, state has #{map_size(rebuilt_state.resources)} resources")
        Logger.info("ResourceProjection: Final state: #{inspect(rebuilt_state)}")
        {:reply, :ok, rebuilt_state}

      {:error, reason} ->
        Logger.error("ResourceProjection: Failed to get events for rebuild: #{inspect(reason)}")
        {:reply, {:error, reason}, %{resources: %{}, last_event_id: nil, last_updated: nil}}
    end
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

  # Helper function to get type of value
  defp typeof(value) when is_binary(value), do: "string"
  defp typeof(value) when is_map(value), do: "map"
  defp typeof(value) when is_list(value), do: "list"
  defp typeof(value) when is_integer(value), do: "integer"
  defp typeof(value) when is_float(value), do: "float"
  defp typeof(value) when is_boolean(value), do: "boolean"
  defp typeof(value) when is_nil(value), do: "nil"
  defp typeof(value), do: "unknown: #{inspect(value)}"
end
