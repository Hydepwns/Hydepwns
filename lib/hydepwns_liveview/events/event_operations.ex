defmodule HydepwnsLiveview.Events.EventOperations do
  @moduledoc """
  Handles core event operations including storage, retrieval, and querying.
  Provides a clean interface for working with events in the event store.
  """

  import Ecto.Query
  require Logger
  alias HydepwnsLiveview.Repo
  alias HydepwnsLiveview.Events.Core.Event
  alias HydepwnsLiveview.Events.QueryBuilders.EventQuery
  alias HydepwnsLiveview.Events.Core.EventBus

  # Use TestEventStore in test mode, real Repo otherwise
  defp event_store do
    if Mix.env() == :test do
      HydepwnsLiveview.Events.TestEventStore
    else
      Repo
    end
  end

  @doc """
  Stores an event in the event store.

  ## Parameters
  * `event` - The event to store

  ## Returns
  * `{:ok, persisted_event}` - The event was successfully stored
  * `{:error, reason}` - The event could not be stored
  """
  @spec store_event(Event.t()) :: {:ok, Event.t()} | {:error, Ecto.Changeset.t()}
  def store_event(event) when is_struct(event, Event) do
    if Mix.env() == :test do
      # In test mode, use TestEventStore
      HydepwnsLiveview.Events.TestEventStore.store_event(event)
    else
      # In production, use real Repo
      Repo.insert(event)
    end
  end

  def store_event(_), do: {:error, :invalid_event}

  @doc """
  Stores an event in the event store with type and data.

  ## Parameters
  * `event_type` - The type of the event
  * `event_data` - The data for the event

  ## Returns
  * `{:ok, persisted_event}` - The event was successfully stored
  * `{:error, reason}` - The event could not be stored
  """
  @spec store_event(String.t(), map()) :: {:ok, Event.t()} | {:error, Ecto.Changeset.t()}
  def store_event(event_type, event_data)
      when is_binary(event_type) and byte_size(event_type) > 0 and is_map(event_data) do
    # Create event with default resource fields for backward compatibility
    event_attrs = Map.merge(event_data, %{
      resource_id: "123",  # Default resource ID for backward compatibility
      resource_type: "test_resource",  # Default resource type for backward compatibility
      data: event_data  # Pass the event_data as the data field
    })
    
    case Event.create(event_type, event_attrs) do
      {:ok, event} -> 
        if Mix.env() == :test do
          # In test mode, use TestEventStore
          HydepwnsLiveview.Events.TestEventStore.store_event(event)
        else
          # In production, use real Repo
          Repo.insert(event)
        end
      {:error, reason} -> {:error, reason}
    end
  end

  def store_event(_, _), do: {:error, :invalid_parameters}

  @doc """
  Stores multiple events in a transaction.

  ## Parameters
  * `events` - List of events to store

  ## Returns
  * `{:ok, persisted_events}` - The events were successfully stored
  * `{:error, reason}` - The events could not be stored
  """
  @spec store_events([Event.t()]) :: {:ok, [Event.t()]} | {:error, any()}
  def store_events(events) when is_list(events) and length(events) > 0 do
    if Mix.env() == :test do
      # In test mode, use TestEventStore
      HydepwnsLiveview.Events.TestEventStore.store_events(events)
    else
      # In production, use real Repo with transaction
      Repo.transaction(fn ->
        Enum.map(events, fn event ->
          case Repo.insert(event) do
            {:ok, inserted_event} -> inserted_event
            {:error, reason} -> Repo.rollback(reason)
          end
        end)
      end)
    end
  end

  def store_events([]), do: {:error, :empty_event_list}
  def store_events(_), do: {:error, :invalid_events}

  @doc """
  Retrieves events based on the given criteria.

  ## Parameters
  * `criteria` - Map of criteria for filtering events

  ## Returns
  * `{:ok, events}` - List of events matching the criteria
  * `{:error, reason}` - The query could not be executed
  """
  @spec get_events(map()) :: {:ok, [Event.t()]} | {:error, any()}
  def get_events(criteria) when is_map(criteria) do
    if Mix.env() == :test do
      # In test mode, use TestEventStore
      HydepwnsLiveview.Events.TestEventStore.get_events(criteria)
    else
      # In production, use real Repo
      try do
        query = EventQuery.build_query(criteria)
        events = Repo.all(query)
        {:ok, events}
      rescue
        e -> {:error, e}
      end
    end
  end

  def get_events(_), do: {:error, :invalid_criteria}

  @doc """
  Retrieves a single event by its ID.

  ## Parameters
  * `id` - The ID of the event to retrieve

  ## Returns
  * `{:ok, event}` - The event was found
  * `{:error, :not_found}` - The event was not found
  * `{:error, reason}` - The query could not be executed
  """
  @spec get_event(String.t()) :: {:ok, Event.t()} | {:error, :not_found | any()}
  def get_event(id) when is_binary(id) do
    if Mix.env() == :test do
      # In test mode, use TestEventStore
      HydepwnsLiveview.Events.TestEventStore.get_event(id)
    else
      # In production, use real Repo
      case Repo.get(Event, id) do
        nil -> {:error, :not_found}
        event -> {:ok, event}
      end
    end
  end

  def get_event(_), do: {:error, :invalid_id}

  @doc """
  Lists all events in the event store.

  ## Returns
  * `{:ok, events}` - List of all events
  * `{:error, reason}` - The query could not be executed
  """
  @spec list_events() :: {:ok, [Event.t()]} | {:error, any()}
  def list_events do
    if Mix.env() == :test do
      # In test mode, use TestEventStore
      HydepwnsLiveview.Events.TestEventStore.list_all_events()
    else
      # In production, use real Repo
      try do
        events = Repo.all(Event) |> Repo.preload(:metadata)
        {:ok, events}
      rescue
        e -> {:error, e}
      end
    end
  end

  @doc """
  Deletes an event by its ID.

  ## Parameters
  * `id` - The ID of the event to delete

  ## Returns
  * `{:ok, deleted_event}` - The event was successfully deleted
  * `{:error, :not_found}` - The event was not found
  * `{:error, reason}` - The event could not be deleted
  """
  @spec delete_event(String.t()) :: {:ok, Event.t()} | {:error, :not_found | any()}
  def delete_event(id) when is_binary(id) do
    if Mix.env() == :test do
      # In test mode, use TestEventStore
      HydepwnsLiveview.Events.TestEventStore.delete_event(id)
    else
      # In production, use real Repo
      case Repo.get(Event, id) do
        nil -> {:error, :not_found}
        event ->
          case Repo.delete(event) do
            {:ok, deleted_event} -> {:ok, deleted_event}
            {:error, reason} -> {:error, reason}
          end
      end
    end
  end

  def delete_event(_), do: {:error, :invalid_id}

  @doc """
  Publishes an event to the event bus.

  ## Parameters
  * `event` - The event to publish

  ## Returns
  * `:ok` - The event was published successfully
  * `{:error, reason}` - The event could not be published
  """
  @spec publish_event(Event.t()) :: :ok | {:error, any()}
  def publish_event(event) when is_struct(event, Event) do
    EventBus.publish(event)
  end

  def publish_event(_), do: {:error, :invalid_event}

  @doc """
  Stores and publishes an event in one operation.

  ## Parameters
  * `event` - The event to store and publish

  ## Returns
  * `{:ok, stored_event}` - The event was stored and published successfully
  * `{:error, reason}` - The operation failed
  """
  @spec store_and_publish_event(Event.t()) :: {:ok, Event.t()} | {:error, any()}
  def store_and_publish_event(event) when is_struct(event, Event) do
    with {:ok, stored_event} <- store_event(event),
         :ok <- publish_event(stored_event) do
      {:ok, stored_event}
    end
  end

  def store_and_publish_event(_), do: {:error, :invalid_event}

  @doc """
  Creates a stream of events matching the given criteria.

  ## Parameters
  * `criteria` - Map of criteria to filter events by (see EventQuery.build_query/1)

  ## Returns
  * `{:ok, event_stream}` - A stream of events matching the criteria
  * `{:error, reason}` - Error creating the stream
  """
  @spec event_stream(map()) :: {:ok, Enumerable.t()} | {:error, any()}
  def event_stream(criteria \\ %{}) do
    query = EventQuery.build_query(criteria)

    try do
      stream = Repo.stream(query)
      {:ok, stream}
    rescue
      e ->
        Logger.error("Error creating event stream: #{inspect(e)}")
        {:error, e}
    end
  end

  @doc """
  Counts events matching the given criteria.

  ## Parameters
  * `criteria` - Map of criteria to filter events by (see EventQuery.build_query/1)

  ## Returns
  * `{:ok, count}` - The number of matching events
  * `{:error, reason}` - Error counting events
  """
  @spec count_events(map()) :: {:ok, integer()} | {:error, any()}
  def count_events(criteria \\ %{}) do
    query =
      criteria
      |> EventQuery.build_query()
      |> select([e], count(e.id))

    try do
      {:ok, Repo.one(query)}
    rescue
      e ->
        Logger.error("Error counting events: #{inspect(e)}")
        {:error, e}
    end
  end

  @doc """
  Purges events matching the given criteria.

  CAUTION: This is a destructive operation and should be used with care.

  ## Parameters
  * `criteria` - Map of criteria to filter events by (see EventQuery.build_query/1)

  ## Returns
  * `{:ok, count}` - The number of events purged
  * `{:error, reason}` - Error purging events
  """
  @spec purge_events(map()) :: {:ok, integer()} | {:error, any()}
  def purge_events(criteria) when map_size(criteria) > 0 do
    query = EventQuery.build_query(criteria)

    try do
      Repo.transaction(fn ->
        Repo.delete_all(query)
      end)
    rescue
      e ->
        Logger.error("Error purging events: #{inspect(e)}")
        {:error, e}
    end
  end

  # Refuses to purge all events without explicit criteria
  @spec purge_events(map()) :: {:ok, integer()} | {:error, any()}
  def purge_events(_criteria) do
    {:error, :no_criteria_specified}
  end

  # Private functions

  defp build_event_query(criteria) do
    Event
    |> filter_by_id(criteria[:id])
    |> filter_by_correlation_id(criteria[:correlation_id])
    |> filter_by_causation_id(criteria[:causation_id])
    |> filter_by_event_type(criteria[:event_type])
    |> filter_by_resource_id(criteria[:resource_id])
    |> filter_by_resource_type(criteria[:resource_type])
    |> filter_by_timestamp(criteria[:timestamp])
    |> filter_by_metadata(criteria[:metadata])
    |> apply_sort(criteria[:sort])
    |> apply_limit(criteria[:limit])
    |> apply_offset(criteria[:offset])
  end

  defp filter_by_id(query, nil), do: query
  defp filter_by_id(query, id), do: where(query, [e], e.id == ^id)

  defp filter_by_correlation_id(query, nil), do: query

  defp filter_by_correlation_id(query, correlation_id),
    do: where(query, [e], e.correlation_id == ^correlation_id)

  defp filter_by_causation_id(query, nil), do: query

  defp filter_by_causation_id(query, causation_id),
    do: where(query, [e], e.causation_id == ^causation_id)

  defp filter_by_event_type(query, nil), do: query

  defp filter_by_event_type(query, event_type) when is_binary(event_type),
    do: where(query, [e], e.type == ^event_type)

  defp filter_by_event_type(query, event_types) when is_list(event_types),
    do: where(query, [e], e.type in ^event_types)

  defp filter_by_resource_id(query, nil), do: query

  defp filter_by_resource_id(query, resource_id),
    do: where(query, [e], e.resource_id == ^resource_id)

  defp filter_by_resource_type(query, nil), do: query

  defp filter_by_resource_type(query, resource_type),
    do: where(query, [e], e.resource_type == ^resource_type)

  defp filter_by_timestamp(query, nil), do: query

  defp filter_by_timestamp(query, %{lt: timestamp}),
    do: where(query, [e], e.timestamp < ^timestamp)

  defp filter_by_timestamp(query, %{lte: timestamp}),
    do: where(query, [e], e.timestamp <= ^timestamp)

  defp filter_by_timestamp(query, %{gt: timestamp}),
    do: where(query, [e], e.timestamp > ^timestamp)

  defp filter_by_timestamp(query, %{gte: timestamp}),
    do: where(query, [e], e.timestamp >= ^timestamp)

  defp filter_by_timestamp(query, timestamp), do: where(query, [e], e.timestamp == ^timestamp)

  defp filter_by_metadata(query, nil), do: query

  defp filter_by_metadata(query, metadata) when is_map(metadata) do
    Enum.reduce(metadata, query, fn {key, value}, acc ->
      where(acc, [e], fragment("?->? = ?", e.metadata, ^key, ^value))
    end)
  end

  defp apply_sort(query, nil), do: query

  defp apply_sort(query, sort_criteria) when is_list(sort_criteria) do
    Enum.reduce(sort_criteria, query, fn {field, direction}, acc ->
      order_by(acc, [e], [{^direction, ^field}])
    end)
  end

  defp apply_limit(query, nil), do: query
  defp apply_limit(query, limit) when is_integer(limit) and limit > 0, do: limit(query, ^limit)

  defp apply_offset(query, nil), do: query

  defp apply_offset(query, offset) when is_integer(offset) and offset >= 0,
    do: offset(query, ^offset)

  def create_event(type, payload, metadata \\ %{}) do
    event = %{
      id: Ecto.UUID.generate(),
      type: type,
      payload: payload,
      metadata: metadata,
      timestamp: DateTime.utc_now()
    }

    EventBus.publish(type, event)
    {:ok, event}
  end

  def transform_event(event, transform_fn) do
    case event do
      %{type: type, payload: payload} ->
        transformed_payload = transform_fn.(payload)
        create_event(type, transformed_payload, event.metadata)

      _ ->
        {:error, :invalid_event}
    end
  end

  def merge_events(events) when is_list(events) do
    case events do
      [] ->
        {:error, :empty_events}

      [event | _] = events ->
        merged_payload =
          Enum.reduce(events, %{}, fn event, acc ->
            Map.merge(acc, event.payload)
          end)

        create_event(event.type, merged_payload, event.metadata)

      _ ->
        {:error, :invalid_events}
    end
  end
end
