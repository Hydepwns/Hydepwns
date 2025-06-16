defmodule HydepwnsLiveview.Events.SnapshotOperations do
  @moduledoc """
  Handles snapshot and versioned state management.
  Provides functionality for creating and retrieving snapshots and versioned states.
  """

  import Ecto.Query
  require Logger
  alias HydepwnsLiveview.Repo
  alias HydepwnsLiveview.Events.Schemas.Snapshot
  alias HydepwnsLiveview.Events.Schemas.VersionedState
  alias HydepwnsLiveview.Events.Schemas.Event

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
  @spec save_snapshot(String.t(), String.t(), map(), map()) :: {:ok, Snapshot.t()} | {:error, Ecto.Changeset.t()}
  def save_snapshot(resource_type, resource_id, state, metadata \\ %{})
      when is_binary(resource_type) and byte_size(resource_type) > 0
      and is_binary(resource_id) and byte_size(resource_id) > 0
      and is_map(state)
      and is_map(metadata) do
    %Snapshot{}
    |> Snapshot.changeset(%{
      resource_type: resource_type,
      resource_id: resource_id,
      state: state,
      metadata: metadata
    })
    |> Repo.insert()
  end
  def save_snapshot(_invalid_type, _invalid_id, _invalid_state, _invalid_metadata), 
    do: {:error, :invalid_parameters}

  @doc """
  Retrieves the latest snapshot for a resource.

  ## Parameters
  * `resource_type` - The type of resource
  * `resource_id` - The ID of the resource

  ## Returns
  * `{:ok, snapshot}` - The latest snapshot for the resource
  * `{:error, :not_found}` - No snapshot exists for the resource
  """
  @spec get_latest_snapshot(String.t(), String.t()) :: {:ok, Snapshot.t()} | {:error, any()}
  def get_latest_snapshot(resource_type, resource_id)
      when is_binary(resource_type) and byte_size(resource_type) > 0
      and is_binary(resource_id) and byte_size(resource_id) > 0 do
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
  def get_latest_snapshot(_invalid_type, _invalid_id), do: {:error, :invalid_parameters}

  @doc """
  Counts the number of events since the last snapshot for a resource.

  ## Parameters
  * `resource_type` - The type of resource
  * `resource_id` - The ID of the resource

  ## Returns
  * `{:ok, count}` - The number of events since the last snapshot
  * `{:error, reason}` - Error counting events
  """
  @spec count_events_since_last_snapshot(String.t(), String.t()) :: {:ok, integer()} | {:error, any()}
  def count_events_since_last_snapshot(resource_type, resource_id)
      when is_binary(resource_type) and byte_size(resource_type) > 0
      and is_binary(resource_id) and byte_size(resource_id) > 0 do
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
  def count_events_since_last_snapshot(_invalid_type, _invalid_id), do: {:error, :invalid_parameters}

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
  @spec save_versioned_state(String.t(), String.t(), map(), Keyword.t()) ::
          {:ok, VersionedState.t()} | {:error, Ecto.Changeset.t()}
  def save_versioned_state(resource_type, resource_id, state, opts \\ [])
      when is_binary(resource_type) and byte_size(resource_type) > 0
      and is_binary(resource_id) and byte_size(resource_id) > 0
      and is_map(state)
      and is_list(opts) do
    attrs = %{
      resource_type: resource_type,
      resource_id: resource_id,
      state: state,
      label: Keyword.fetch!(opts, :label),
      replay_id: Keyword.get(opts, :replay_id),
      created_at: Keyword.get(opts, :created_at, DateTime.utc_now()),
      point_in_time: Keyword.get(opts, :point_in_time),
      metadata: Keyword.get(opts, :metadata, %{})
    }

    %VersionedState{}
    |> VersionedState.changeset(attrs)
    |> Repo.insert()
  end
  def save_versioned_state(_invalid_type, _invalid_id, _invalid_state, _invalid_opts),
    do: {:error, :invalid_parameters}

  @doc """
  Retrieves all snapshots for a resource.

  ## Parameters
  * `resource_type` - The type of resource
  * `resource_id` - The ID of the resource

  ## Returns
  * `{:ok, [snapshots]}` - All snapshots for the resource, ordered by inserted_at ascending
  * `{:error, reason}` - Error retrieving snapshots
  """
  @spec get_snapshots(String.t(), String.t()) :: {:ok, [Snapshot.t()]} | {:error, any()}
  def get_snapshots(resource_type, resource_id)
      when is_binary(resource_type) and byte_size(resource_type) > 0
      and is_binary(resource_id) and byte_size(resource_id) > 0 do
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
  def get_snapshots(_invalid_type, _invalid_id), do: {:error, :invalid_parameters}
end 