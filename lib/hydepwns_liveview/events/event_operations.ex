defmodule HydepwnsLiveview.Events.EventOperations do
  @moduledoc """
  Handles core event operations including storage, retrieval, and querying.
  Provides a clean interface for working with events in the event store.
  """

  import Ecto.Query
  require Logger
  alias HydepwnsLiveview.Repo
  alias HydepwnsLiveview.Events.Schemas.Event
  alias HydepwnsLiveview.Events.QueryBuilders.EventQuery

  @doc """
  Stores an event in the event store.

  ## Parameters
  * `event` - The event to store

  ## Returns
  * `{:ok, persisted_event}` - The event was successfully stored
  * `{:error, reason}` - The event could not be stored
  """
  @spec store_event(Event.t()) :: {:ok, Event.t()} | {:error, Ecto.Changeset.t()}
  def store_event(%Event{} = event) when is_struct(event, Event) do
    Repo.insert(event)
  end
  def store_event(_invalid_event), do: {:error, :invalid_event}

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
    %Event{}
    |> Event.changeset(%{
      type: event_type,
      data: event_data,
      timestamp: DateTime.utc_now()
    })
    |> Repo.insert()
  end
  def store_event(_invalid_type, _invalid_data), do: {:error, :invalid_parameters}

  @doc """
  Stores multiple events in the event store.

  ## Parameters
  * `events` - List of events to store

  ## Returns
  * `{:ok, persisted_events}` - All events were successfully stored
  * `{:error, failed_event, failed_changeset, inserted_events}` - Some events could not be stored
  """
  @spec store_events([Event.t()]) :: {:ok, [Event.t()]} | {:error, any(), any(), [Event.t()]}
  def store_events(events) when is_list(events) and length(events) > 0 do
    Repo.transaction(fn ->
      Enum.map(events, &Repo.insert!/1)
    end)
  end
  def store_events([]), do: {:error, :empty_event_list}
  def store_events(_invalid_events), do: {:error, :invalid_events}

  @doc """
  Retrieves events matching the given criteria.

  ## Parameters
  * `criteria` - Map of criteria to filter events by. Supported keys:
    * `:id` - The event ID
    * `:correlation_id` - Events with this correlation ID
    * `:causation_id` - Events with this causation ID
    * `:event_type` - Events of this type (or list of types)
    * `:resource_id` - Events for this resource ID
    * `:timestamp` - Events with timestamp matching this criteria
    * `:metadata` - Events with metadata matching this criteria
    * `:limit` - Maximum number of events to return
    * `:offset` - Number of events to skip
    * `:sort` - List of sort criteria, e.g. [timestamp: :desc]

  ## Returns
  * `{:ok, events}` - The events matching the criteria
  * `{:error, reason}` - Error retrieving events
  """
  @spec get_events(map()) :: {:ok, [Event.t()]} | {:error, any()}
  def get_events(criteria) when is_map(criteria) do
    query = build_event_query(criteria)

    try do
      {:ok, Repo.all(query)}
    rescue
      e ->
        Logger.error("Error retrieving events: #{inspect(e)}")
        {:error, e}
    end
  end
  def get_events(_invalid_criteria), do: {:error, :invalid_criteria}

  @doc """
  Retrieves a single event by ID.

  ## Parameters
  * `id` - The ID of the event to retrieve

  ## Returns
  * `{:ok, event}` - The event was found
  * `{:error, :not_found}` - No event with the given ID exists
  * `{:error, reason}` - Error retrieving the event
  """
  @spec get_event(any()) :: {:ok, Event.t()} | {:error, any()}
  def get_event(id) do
    case Repo.get(Event, id, timeout: 5000) do
      nil -> {:error, :not_found}
      event -> {:ok, event}
    end
  rescue
    e ->
      Logger.error("Error retrieving event #{id}: #{inspect(e)}")
      {:error, e}
  end

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

  defp build_event_query(criteria) when is_map(criteria) do
    base_query = from(e in Event)

    criteria
    |> Enum.reduce(base_query, &apply_criterion/2)
    |> apply_sort(criteria)
    |> apply_pagination(criteria)
  end

  defp apply_criterion({:id, id}, query) when is_binary(id) do
    where(query, [e], e.id == ^id)
  end

  defp apply_criterion({:correlation_id, correlation_id}, query) when is_binary(correlation_id) do
    where(query, [e], e.correlation_id == ^correlation_id)
  end

  defp apply_criterion({:causation_id, causation_id}, query) when is_binary(causation_id) do
    where(query, [e], e.causation_id == ^causation_id)
  end

  defp apply_criterion({:event_type, event_types}, query) when is_list(event_types) do
    where(query, [e], e.type in ^event_types)
  end

  defp apply_criterion({:event_type, event_type}, query) when is_binary(event_type) do
    where(query, [e], e.type == ^event_type)
  end

  defp apply_criterion({:resource_id, resource_id}, query) when is_binary(resource_id) do
    where(query, [e], e.resource_id == ^resource_id)
  end

  defp apply_criterion({:timestamp, timestamp_criteria}, query) when is_map(timestamp_criteria) do
    Enum.reduce(timestamp_criteria, query, fn
      {:after, time}, q when is_struct(time, DateTime) -> where(q, [e], e.timestamp >= ^time)
      {:before, time}, q when is_struct(time, DateTime) -> where(q, [e], e.timestamp <= ^time)
      _, q -> q
    end)
  end

  defp apply_criterion({:metadata, metadata_criteria}, query) when is_map(metadata_criteria) do
    Enum.reduce(metadata_criteria, query, fn {key, value}, q when is_binary(key) ->
      where(q, [e], fragment("?->? = ?", e.metadata, ^key, ^to_string(value)))
    end)
  end

  defp apply_criterion(_, query), do: query

  defp apply_sort(query, %{sort: sort_criteria}) when is_list(sort_criteria) do
    Enum.reduce(sort_criteria, query, fn
      {:timestamp, :asc}, q -> order_by(q, [e], asc: e.timestamp)
      {:timestamp, :desc}, q -> order_by(q, [e], desc: e.timestamp)
      {:id, :asc}, q -> order_by(q, [e], asc: e.id)
      {:id, :desc}, q -> order_by(q, [e], desc: e.id)
      _, q -> q
    end)
  end

  defp apply_sort(query, _), do: query

  defp apply_pagination(query, %{limit: limit}) when is_integer(limit) and limit > 0 do
    limit(query, ^limit)
  end

  defp apply_pagination(query, %{offset: offset}) when is_integer(offset) and offset >= 0 do
    offset(query, ^offset)
  end

  defp apply_pagination(query, _), do: query
end 