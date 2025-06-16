defmodule HydepwnsLiveview.Events.ReplayOperations do
  @moduledoc """
  Handles replay session management and event replay operations.
  Provides functionality for creating, managing, and executing replay sessions.
  """

  require Logger
  alias HydepwnsLiveview.Repo
  alias HydepwnsLiveview.Events.Schemas.ReplaySession
  alias HydepwnsLiveview.Events.QueryBuilders.ReplayQuery

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
          {:ok, ReplaySession.t()} | {:error, Ecto.Changeset.t()}
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
  @spec start_replay_session(any()) :: {:ok, ReplaySession.t()} | {:error, any()}
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
  @spec complete_replay_session(any(), map()) :: {:ok, ReplaySession.t()} | {:error, any()}
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
  @spec fail_replay_session(any(), any()) :: {:ok, ReplaySession.t()} | {:error, any()}
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
  @spec get_replay_session_events(any()) :: {:ok, [any()]} | {:error, any()}
  def get_replay_session_events(session_id) do
    with {:ok, session} <- get_replay_session(session_id) do
      query = ReplayQuery.build_query(session)
      {:ok, Repo.all(query)}
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
  @spec get_replay_session(any()) :: {:ok, ReplaySession.t()} | {:error, any()}
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
end 