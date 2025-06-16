defmodule HydepwnsLiveview.Events.Core.EventStore do
  @moduledoc """
  Core implementation of the event store.

  This module provides the core functionality for storing and retrieving events,
  snapshots, and versioned states. It handles:
  - Event persistence and retrieval
  - Snapshot management
  - Versioned state tracking
  - Event replay functionality
  """

  require Logger
  alias HydepwnsLiveview.Repo
  alias HydepwnsLiveview.Events.Core.Event
  import Ecto.Query

  @doc """
  Starts the EventStore process.

  Since this is primarily a data access layer and not a process,
  this function exists mainly to satisfy the supervisor child_spec
  requirements.
  """
  @spec start_link(Keyword.t()) :: {:ok, pid()}
  def start_link(_opts \\ []) do
    {:ok, self()}
  end

  @doc """
  Returns a child specification for starting the EventStore under a supervisor.
  """
  @spec child_spec(Keyword.t()) :: Supervisor.child_spec()
  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  defmodule Snapshot do
    @moduledoc """
    Schema for storing resource state snapshots.
    Used for optimizing event replay by providing checkpoints of resource state.
    """
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key {:id, :binary_id, autogenerate: true}
    @timestamps_opts [type: :utc_datetime_usec]
    schema "resource_snapshots" do
      field :resource_type, :string
      field :resource_id, :string
      field :state, :map
      field :metadata, :map, default: %{}

      timestamps()
    end

    @type t :: %__MODULE__{
            id: Ecto.UUID.t() | binary(),
            resource_type: String.t(),
            resource_id: String.t(),
            state: map(),
            metadata: map(),
            inserted_at: NaiveDateTime.t() | nil,
            updated_at: NaiveDateTime.t() | nil
          }

    @spec changeset(t(), map()) :: Ecto.Changeset.t()
    def changeset(snapshot, attrs) do
      snapshot
      |> cast(attrs, [:resource_type, :resource_id, :state, :metadata])
      |> validate_required([:resource_type, :resource_id, :state])
    end
  end

  defmodule ReplaySession do
    @moduledoc """
    Schema for managing event replay sessions, tracking their status and results.
    Used for replaying event sequences and analyzing historical state changes.
    """
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key {:id, :binary_id, autogenerate: true}
    @timestamps_opts [type: :utc_datetime_usec]
    schema "event_replay_sessions" do
      field :name, :string
      field :resource_type, :string
      field :resource_id, :string
      field :start_event_id, :binary_id
      field :end_event_id, :binary_id
      field :status, :string, default: "pending"
      field :metadata, :map, default: %{}
      field :results, :map, default: %{}

      timestamps()
    end

    @type t :: %__MODULE__{
            id: Ecto.UUID.t() | binary(),
            name: String.t(),
            resource_type: String.t(),
            resource_id: String.t(),
            start_event_id: Ecto.UUID.t() | binary() | nil,
            end_event_id: Ecto.UUID.t() | binary() | nil,
            status: String.t(),
            metadata: map(),
            results: map(),
            inserted_at: NaiveDateTime.t() | nil,
            updated_at: NaiveDateTime.t() | nil
          }

    @spec changeset(t(), map()) :: Ecto.Changeset.t()
    def changeset(session, attrs) do
      session
      |> cast(attrs, [
        :name,
        :resource_type,
        :resource_id,
        :start_event_id,
        :end_event_id,
        :status,
        :metadata,
        :results
      ])
      |> validate_required([:name, :resource_type, :resource_id])
      |> validate_inclusion(:status, ["pending", "running", "completed", "failed"])
    end
  end

  defmodule VersionedState do
    @moduledoc """
    Schema for storing versioned states of resources at specific points in time.
    Used for tracking state changes and supporting point-in-time queries.
    """
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key {:id, :binary_id, autogenerate: true}
    @timestamps_opts [type: :utc_datetime_usec, inserted_at: :created_at, updated_at: false]
    schema "versioned_states" do
      field :resource_type, :string
      field :resource_id, :string
      field :state, :map
      field :label, :string
      field :replay_id, :binary_id
      field :point_in_time, :utc_datetime_usec
      field :metadata, :map, default: %{}
      field :created_at, :utc_datetime_usec
    end

    @type t :: %__MODULE__{
            id: Ecto.UUID.t() | binary(),
            resource_type: String.t(),
            resource_id: String.t(),
            state: map(),
            label: String.t(),
            replay_id: Ecto.UUID.t() | binary() | nil,
            point_in_time: DateTime.t() | nil,
            metadata: map(),
            created_at: NaiveDateTime.t() | nil
          }

    @spec changeset(t(), map()) :: Ecto.Changeset.t()
    def changeset(versioned_state, attrs) do
      versioned_state
      |> cast(attrs, [
        :resource_type,
        :resource_id,
        :state,
        :label,
        :replay_id,
        :point_in_time,
        :metadata,
        :created_at
      ])
      |> validate_required([:resource_type, :resource_id, :state, :label, :created_at])
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
  def store_event(%Event{} = event) do
    Repo.insert(event)
  end

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
  def store_event(event_type, event_data) do
    %Event{}
    |> Event.changeset(%{
      type: event_type,
      data: event_data,
      timestamp: DateTime.utc_now()
    })
    |> Repo.insert()
  end

  @doc """
  Stores multiple events in the event store.

  ## Parameters
  * `events` - List of events to store

  ## Returns
  * `{:ok, persisted_events}` - All events were successfully stored
  * `{:error, failed_event, failed_changeset, inserted_events}` - Some events could not be stored
  """
  @spec store_events([Event.t()]) :: {:ok, [Event.t()]} | {:error, any(), any(), [Event.t()]}
  def store_events(events) when is_list(events) do
    Repo.transaction(fn ->
      Enum.map(events, &Repo.insert!/1)
    end)
  end

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
  def get_events(criteria \\ %{}) do
    query = build_event_query(criteria)

    try do
      {:ok, Repo.all(query)}
    rescue
      e ->
        Logger.error("Error retrieving events: #{inspect(e)}")
        {:error, e}
    end
  end

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

  This is useful for processing large numbers of events efficiently.

  ## Parameters
  * `criteria` - Map of criteria to filter events by (see `get_events/1`)

  ## Returns
  * `{:ok, event_stream}` - A stream of events matching the criteria
  * `{:error, reason}` - Error creating the stream
  """
  @spec event_stream(map()) :: Enumerable.t()
  def event_stream(criteria \\ %{}) do
    query = build_event_query(criteria)

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
  * `criteria` - Map of criteria to filter events by (see `get_events/1`)

  ## Returns
  * `{:ok, count}` - The number of matching events
  * `{:error, reason}` - Error counting events
  """
  @spec count_events(map()) :: integer()
  def count_events(criteria \\ %{}) do
    query =
      criteria
      |> build_event_query()
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
  * `criteria` - Map of criteria to filter events by (see `get_events/1`)

  ## Returns
  * `{:ok, count}` - The number of events purged
  * `{:error, reason}` - Error purging events
  """
  @spec purge_events(map()) :: {:ok, integer()} | {:error, any()}
  def purge_events(criteria) when map_size(criteria) > 0 do
    query = build_event_query(criteria)

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

  @doc """
  Stores a snapshot of a resource's state.

  ## Parameters
  * `resource_type` - The type of resource
  * `resource_id` - The ID of the resource
  * `state` - The current state to snapshot
  * `metadata` - Additional metadata about the snapshot

  ## Returns
  * `{:ok, snapshot}` - The snapshot was successfully stored
  * `{:error, changeset}` - The snapshot could not be stored
  """
  @spec save_snapshot(String.t(), String.t(), map(), map()) :: {:ok, Snapshot.t()} | {:error, any()}
  def save_snapshot(resource_type, resource_id, state, metadata \\ %{}) do
    %Snapshot{}
    |> Snapshot.changeset(%{
      resource_type: resource_type,
      resource_id: resource_id,
      state: state,
      metadata: metadata
    })
    |> Repo.insert()
  end

  @doc """
  Retrieves the latest snapshot for a resource.

  ## Parameters
  * `resource_type` - The type of resource
  * `resource_id` - The ID of the resource

  ## Returns
  * `{:ok, snapshot}` - The latest snapshot for the resource
  * `{:error, :not_found}` - No snapshot exists for the resource
  """
  @spec get_latest_snapshot(String.t(), String.t()) :: {:ok, any()} | {:error, any()}
  def get_latest_snapshot(resource_type, resource_id) do
    query =
      from s in Snapshot,
        where: s.resource_type == ^resource_type and s.resource_id == ^resource_id,
        order_by: [desc: s.inserted_at],
        limit: 1

    case Repo.one(query) do
      nil -> {:error, :not_found}
      snapshot -> {:ok, snapshot}
    end
  end

  @doc """
  Counts the number of events since the last snapshot for a resource.

  ## Parameters
  * `resource_type` - The type of resource
  * `resource_id` - The ID of the resource

  ## Returns
  * `{:ok, count}` - The number of events since the last snapshot
  * `{:error, reason}` - Error counting events
  """
  @spec count_events_since_last_snapshot(String.t(), String.t()) :: integer()
  def count_events_since_last_snapshot(resource_type, resource_id) do
    case get_latest_snapshot(resource_type, resource_id) do
      {:ok, snapshot} ->
        # Get the event ID from the snapshot metadata
        event_id = get_in(snapshot.metadata, [:event_id])

        if event_id do
          # Count events after the snapshot's event
          query =
            from e in Event,
              where: e.resource_type == ^resource_type and e.resource_id == ^resource_id,
              where: e.inserted_at > ^snapshot.inserted_at

          {:ok, Repo.aggregate(query, :count)}
        else
          # No event ID in metadata, count all events
          query =
            from e in Event,
              where: e.resource_type == ^resource_type and e.resource_id == ^resource_id

          {:ok, Repo.aggregate(query, :count)}
        end

      {:error, :not_found} ->
        # No snapshot, count all events
        query =
          from e in Event,
            where: e.resource_type == ^resource_type and e.resource_id == ^resource_id

        {:ok, Repo.aggregate(query, :count)}

      error ->
        error
    end
  end

  @doc """
  Retrieves events for a resource that occurred after a specific event.

  ## Parameters
  * `resource_type` - The type of resource
  * `resource_id` - The ID of the resource
  * `after_event_id` - The ID of the event to start from (exclusive)

  ## Returns
  * `{:ok, events}` - The events after the specified event
  * `{:error, reason}` - Error retrieving events
  """
  @spec get_events_after(String.t(), String.t(), any()) :: [Event.t()]
  def get_events_after(resource_type, resource_id, after_event_id) do
    # First get the event to determine its timestamp
    case get_event(after_event_id) do
      {:ok, event} ->
        query =
          from e in Event,
            where: e.resource_type == ^resource_type and e.resource_id == ^resource_id,
            where: e.inserted_at > ^event.inserted_at,
            order_by: [asc: e.inserted_at]

        {:ok, Repo.all(query)}

      {:error, :not_found} ->
        # Event not found, return all events for the resource
        get_events_for_resource(resource_type, resource_id)

      error ->
        error
    end
  end

  @doc """
  Retrieves all events for a specific resource.

  ## Parameters
  * `resource_type` - The type of resource
  * `resource_id` - The ID of the resource

  ## Returns
  * `{:ok, events}` - All events for the resource
  * `{:error, reason}` - Error retrieving events
  """
  @spec get_events_for_resource(String.t(), String.t()) :: {:ok, [Event.t()]} | {:error, any()}
  def get_events_for_resource(resource_type, resource_id) do
    query =
      from e in Event,
        where: e.resource_type == ^resource_type and e.resource_id == ^resource_id,
        order_by: [asc: e.timestamp]

    case Repo.all(query) do
      events when is_list(events) -> {:ok, events}
      error -> {:error, error}
    end
  end

  @doc """
  Creates a new replay session for events.

  ## Parameters
  * `name` - Name for the replay session
  * `resource_type` - The type of resource to replay
  * `resource_id` - The ID of the resource to replay
  * `opts` - Additional options:
      * `:start_event_id` - ID of the first event to include (optional)
      * `:end_event_id` - ID of the last event to include (optional)
      * `:metadata` - Additional metadata for the session (optional)

  ## Returns
  * `{:ok, session}` - The replay session was created
  * `{:error, changeset}` - The session could not be created
  """
  @spec create_replay_session(String.t(), String.t(), String.t(), Keyword.t()) ::
          {:ok, any()} | {:error, any()}
  def create_replay_session(name, resource_type, resource_id, opts \\ []) do
    attrs = %{
      name: name,
      resource_type: resource_type,
      resource_id: resource_id,
      start_event_id: Keyword.get(opts, :start_event_id),
      end_event_id: Keyword.get(opts, :end_event_id),
      status: "pending",
      metadata: Keyword.get(opts, :metadata, %{})
    }

    %ReplaySession{}
    |> ReplaySession.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Starts a replay session.

  ## Parameters
  * `session_id` - ID of the replay session to start

  ## Returns
  * `{:ok, session}` - The session was started
  * `{:error, reason}` - The session could not be started
  """
  @spec start_replay_session(any()) :: {:ok, any()} | {:error, any()}
  def start_replay_session(session_id) do
    case Repo.get(ReplaySession, session_id, timeout: 5000) do
      nil ->
        {:error, :not_found}

      session ->
        # Update status to running
        changeset = ReplaySession.changeset(session, %{status: "running"})
        Repo.update(changeset)
    end
  end

  @doc """
  Completes a replay session with results.

  ## Parameters
  * `session_id` - ID of the replay session to complete
  * `results` - Results of the replay

  ## Returns
  * `{:ok, session}` - The session was completed
  * `{:error, reason}` - The session could not be completed
  """
  @spec complete_replay_session(any(), map()) :: {:ok, any()} | {:error, any()}
  def complete_replay_session(session_id, results) do
    case Repo.get(ReplaySession, session_id, timeout: 5000) do
      nil ->
        {:error, :not_found}

      session ->
        # Update status to completed and store results
        changeset =
          ReplaySession.changeset(session, %{
            status: "completed",
            results: results
          })

        Repo.update(changeset)
    end
  end

  @doc """
  Marks a replay session as failed.

  ## Parameters
  * `session_id` - ID of the replay session to fail
  * `error_details` - Details about the failure

  ## Returns
  * `{:ok, session}` - The session was marked as failed
  * `{:error, reason}` - The status could not be updated
  """
  @spec fail_replay_session(any(), any()) :: {:ok, any()} | {:error, any()}
  def fail_replay_session(session_id, error_details) do
    case Repo.get(ReplaySession, session_id, timeout: 5000) do
      nil ->
        {:error, :not_found}

      session ->
        # Update status to failed and store error details
        changeset =
          ReplaySession.changeset(session, %{
            status: "failed",
            results: %{error: error_details}
          })

        Repo.update(changeset)
    end
  end

  @doc """
  Gets events for a replay session.

  ## Parameters
  * `session_id` - ID of the replay session

  ## Returns
  * `{:ok, events}` - The events for the replay session
  * `{:error, reason}` - Error retrieving events
  """
  @spec get_replay_session_events(any()) :: [any()]
  def get_replay_session_events(session_id) do
    with {:ok, session} <- get_replay_session(session_id) do
      query = build_replay_session_query(session)
      {:ok, Repo.all(query)}
    end
  end

  defp build_replay_session_query(session) do
    session
    |> build_base_query()
    |> add_start_event_constraint(session)
    |> add_end_event_constraint(session)
    |> order_by([e], asc: e.inserted_at)
  end

  defp build_base_query(session) do
    from e in Event,
      where: e.resource_type == ^session.resource_type and e.resource_id == ^session.resource_id
  end

  defp add_start_event_constraint(query, session) do
    if session.start_event_id do
      case get_event(session.start_event_id) do
        {:ok, start_event} -> from e in query, where: e.inserted_at >= ^start_event.inserted_at
        _ -> query
      end
    else
      query
    end
  end

  defp add_end_event_constraint(query, session) do
    if session.end_event_id do
      case get_event(session.end_event_id) do
        {:ok, end_event} -> from e in query, where: e.inserted_at <= ^end_event.inserted_at
        _ -> query
      end
    else
      query
    end
  end

  @doc """
  Gets a replay session by ID.

  ## Parameters
  * `session_id` - The ID of the replay session

  ## Returns
  * `{:ok, session}` - The session was found
  * `{:error, :not_found}` - No session with the given ID exists
  * `{:error, reason}` - Error retrieving the session
  """
  @spec get_replay_session(any()) :: {:ok, any()} | {:error, any()}
  def get_replay_session(session_id) do
    case Repo.get(ReplaySession, session_id, timeout: 5000) do
      nil -> {:error, :not_found}
      session -> {:ok, session}
    end
  rescue
    e ->
      Logger.error("Error retrieving replay session #{session_id}: #{inspect(e)}")
      {:error, e}
  end

  @doc """
  Saves a versioned state for a resource.

  ## Parameters
  * `resource_type` - The type of resource
  * `resource_id` - The ID of the resource
  * `state` - The state to save
  * `opts` - Options (expects :label, :replay_id, :created_at, :point_in_time, :metadata)

  ## Returns
  * `{:ok, versioned_state}` - The versioned state was created
  * `{:error, changeset}` - The versioned state could not be created
  """
  @spec save_versioned_state(String.t(), String.t(), map(), map()) :: {:ok, VersionedState.t()} | {:error, any()}
  def save_versioned_state(resource_type, resource_id, state, metadata \\ %{}) do
    %VersionedState{}
    |> VersionedState.changeset(%{
      resource_type: resource_type,
      resource_id: resource_id,
      state: state,
      metadata: metadata,
      created_at: DateTime.utc_now()
    })
    |> Repo.insert()
  end

  @doc """
  Updates the status of an existing replay session.

  ## Parameters
  * `session_id` - The ID of the session to update.
  * `new_status` - The new status string (e.g., "running", "completed").
  * `results` - Optional map of results to store with the session.

  ## Returns
  * `{:ok, session}` - The updated session.
  * `{:error, reason}` - Error updating the session.
  """
  @spec update_replay_session_status(Ecto.UUID.t() | binary(), String.t(), map() | nil) ::
          {:ok, ReplaySession.t()} | {:error, any()}
  def update_replay_session_status(session_id, new_status, results \\ nil) do
    case Repo.get(ReplaySession, session_id) do
      nil ->
        {:error, :not_found}

      session ->
        attrs = %{status: new_status}
        attrs = if results, do: Map.put(attrs, :results, results), else: attrs

        session
        |> ReplaySession.changeset(attrs)
        |> Repo.update()
    end
  end

  @doc """
  Retrieves all snapshots for a resource.

  ## Parameters
  * `resource_type` - The type of resource
  * `resource_id` - The ID of the resource

  ## Returns
  * `{:ok, [snapshots]}` - All snapshots for the resource, ordered by inserted_at ascending
  * `{:error, reason}` - Error retrieving snapshots
  """
  @spec get_snapshots(String.t(), String.t()) :: {:ok, [any()]} | {:error, any()}
  def get_snapshots(resource_type, resource_id) do
    query =
      from s in Snapshot,
        where: s.resource_type == ^resource_type and s.resource_id == ^resource_id,
        order_by: [asc: s.inserted_at]

    try do
      {:ok, Repo.all(query)}
    rescue
      e ->
        Logger.error("Error retrieving snapshots: #{inspect(e)}")
        {:error, e}
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
  @spec store(Event.t()) :: {:ok, Event.t()} | {:error, Ecto.Changeset.t()}
  def store(event), do: store_event(event)

  @doc """
  Retrieves events for a resource up to a specific point in time.

  ## Parameters
  * `resource_type` - The type of resource
  * `resource_id` - The ID of the resource
  * `timestamp` - The timestamp to get events up to (inclusive)

  ## Returns
  * `{:ok, events}` - The events up to the specified timestamp
  * `{:error, reason}` - Error retrieving events
  """
  @spec get_events_for_resource_at(String.t(), String.t(), DateTime.t()) :: {:ok, [Event.t()]} | {:error, any()}
  def get_events_for_resource_at(resource_type, resource_id, timestamp) do
    query =
      from e in Event,
        where: e.resource_type == ^resource_type and e.resource_id == ^resource_id,
        where: e.inserted_at <= ^timestamp,
        order_by: [asc: e.inserted_at]

    try do
      {:ok, Repo.all(query)}
    rescue
      e ->
        Logger.error("Error retrieving events for resource at timestamp: #{inspect(e)}")
        {:error, e}
    end
  end

  # Private functions

  # Builds a query from criteria
  defp build_event_query(criteria) do
    base_query = from(e in Event)

    criteria
    |> Enum.reduce(base_query, &apply_criterion/2)
    |> apply_sort(criteria)
    |> apply_pagination(criteria)
  end

  # Applies a single criterion to the query
  defp apply_criterion({:id, id}, query) do
    where(query, [e], e.id == ^id)
  end

  defp apply_criterion({:correlation_id, correlation_id}, query) do
    where(query, [e], e.correlation_id == ^correlation_id)
  end

  defp apply_criterion({:causation_id, causation_id}, query) do
    where(query, [e], e.causation_id == ^causation_id)
  end

  defp apply_criterion({:event_type, event_types}, query) when is_list(event_types) do
    where(query, [e], e.type in ^event_types)
  end

  defp apply_criterion({:event_type, event_type}, query) do
    where(query, [e], e.type == ^event_type)
  end

  defp apply_criterion({:resource_id, resource_id}, query) do
    where(query, [e], e.resource_id == ^resource_id)
  end

  defp apply_criterion({:timestamp, timestamp_criteria}, query) when is_map(timestamp_criteria) do
    Enum.reduce(timestamp_criteria, query, fn
      {:after, time}, q -> where(q, [e], e.timestamp >= ^time)
      {:before, time}, q -> where(q, [e], e.timestamp <= ^time)
      _, q -> q
    end)
  end

  defp apply_criterion({:metadata, metadata_criteria}, query) when is_map(metadata_criteria) do
    Enum.reduce(metadata_criteria, query, fn {key, value}, q ->
      where(q, [e], fragment("?->? = ?", e.metadata, ^to_string(key), ^to_string(value)))
    end)
  end

  defp apply_criterion(_, query), do: query

  # Applies sorting to the query
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

  # Applies pagination to the query
  defp apply_pagination(query, %{limit: limit}) when is_integer(limit) and limit > 0 do
    query = limit(query, ^limit)

    case Map.get(query, :offset) do
      offset when is_integer(offset) and offset >= 0 ->
        offset(query, ^offset)

      _ ->
        query
    end
  end

  defp apply_pagination(query, %{offset: offset}) when is_integer(offset) and offset >= 0 do
    offset(query, ^offset)
  end

  defp apply_pagination(query, _), do: query
end
