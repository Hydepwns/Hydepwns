defmodule HydepwnsLiveview.Events.Core.EventInspector do
  @moduledoc """
  Provides tools for inspecting and debugging events in the system.

  This module offers functionality to:
  - Inspect events and their details
  - Compare events to detect differences
  - Replay events for debugging purposes
  - Monitor performance metrics for the event system
  """

  alias HydepwnsLiveview.Events.Event
  alias HydepwnsLiveview.Events.EventStore
  alias HydepwnsLiveview.Events.EventBus

  @doc """
  Gets detailed information about an event, including context and related events.

  ## Parameters
  * `event_id` - The ID of the event to inspect

  ## Returns
  * `{:ok, details}` - The event details
  * `{:error, reason}` - Error retrieving event details
  """
  def inspect_event(event_id) do
    with {:ok, event} <- EventStore.get_event(event_id),
         {:ok, related_events} <- get_related_events(event),
         {:ok, handlers} <- get_handlers_for_event(event),
         {:ok, projections} <- get_projections_for_event(event) do
      {:ok,
       %{
         event: event,
         related_events: related_events,
         handlers: handlers,
         projections: projections
       }}
    end
  end

  @doc """
  Compares two events to identify differences.

  ## Parameters
  * `event_id_1` - The ID of the first event
  * `event_id_2` - The ID of the second event

  ## Returns
  * `{:ok, diff}` - The differences between the events
  * `{:error, reason}` - Error comparing events
  """
  def compare_events(event_id_1, event_id_2) do
    with {:ok, event1} <- EventStore.get_event(event_id_1),
         {:ok, event2} <- EventStore.get_event(event_id_2) do
      diff = %{
        type: if(event1.type == event2.type, do: nil, else: {event1.type, event2.type}),
        resource_id:
          if(event1.resource_id == event2.resource_id,
            do: nil,
            else: {event1.resource_id, event2.resource_id}
          ),
        resource_type:
          if(event1.resource_type == event2.resource_type,
            do: nil,
            else: {event1.resource_type, event2.resource_type}
          ),
        data: compare_maps(event1.data, event2.data),
        metadata: compare_maps(event1.metadata, event2.metadata),
        timestamp:
          if(event1.timestamp == event2.timestamp,
            do: nil,
            else: {event1.timestamp, event2.timestamp}
          )
      }

      {:ok, diff}
    end
  end

  @doc """
  Creates and starts a replay session for debugging.

  ## Parameters
  * `name` - Name for the replay session
  * `resource_type` - The type of resource to replay
  * `resource_id` - The ID of the resource to replay
  * `opts` - Additional options:
      * `:start_event_id` - ID of the first event to include (optional)
      * `:end_event_id` - ID of the last event to include (optional)
      * `:metadata` - Additional metadata for the session (optional)

  ## Returns
  * `{:ok, session_id}` - The replay session was created and started
  * `{:error, reason}` - Error creating or starting the session
  """
  def start_replay_for_debugging(name, resource_type, resource_id, opts \\ []) do
    # Add debugging metadata
    metadata =
      Map.merge(
        %{purpose: "debugging", created_by: "event_inspector"},
        Keyword.get(opts, :metadata, %{})
      )

    with {:ok, session} <-
           EventStore.create_replay_session(
             name,
             resource_type,
             resource_id,
             Keyword.put(opts, :metadata, metadata)
           ),
         {:ok, updated_session} <- EventStore.start_replay_session(session.id),
         # Get the events for the session
         {:ok, events} <- EventStore.get_replay_session_events(session.id) do
      # Record the start of replay
      record_replay_start(updated_session, events)

      # Start the actual replay process
      spawn_link(fn ->
        replay_events(events, updated_session.id)
      end)

      {:ok, updated_session.id}
    end
  end

  @doc """
  Gets the status and results of a replay session.

  ## Parameters
  * `session_id` - The ID of the replay session

  ## Returns
  * `{:ok, session}` - The session details
  * `{:error, reason}` - Error retrieving session
  """
  def get_replay_status(session_id) do
    case Repo.get(EventStore.ReplaySession, session_id) do
      nil -> {:error, :not_found}
      session -> {:ok, session}
    end
  end

  @doc """
  Gets performance metrics for the event system.

  ## Parameters
  * `time_period` - The time period to get metrics for (in seconds, default: 3600)

  ## Returns
  * `{:ok, metrics}` - The event system metrics
  * `{:error, reason}` - Error retrieving metrics
  """
  def get_event_system_metrics(time_period \\ 3600) do
    start_time = DateTime.add(DateTime.utc_now(), -time_period, :second)

    # Get events in the time period
    {:ok, events} =
      EventStore.get_events(%{
        timestamp: %{after: start_time},
        sort: [timestamp: :asc]
      })

    # Calculate metrics
    event_counts =
      Enum.reduce(events, %{}, fn event, acc ->
        Map.update(acc, event.type, 1, &(&1 + 1))
      end)

    resource_counts =
      Enum.reduce(events, %{}, fn event, acc ->
        key = event.resource_type
        Map.update(acc, key, 1, &(&1 + 1))
      end)

    # Calculate time-based metrics
    time_series =
      if length(events) > 0 do
        # Group events by minute
        events_by_minute =
          Enum.group_by(events, fn event ->
            DateTime.to_iso8601(event.timestamp)
            # Get YYYY-MM-DDTHH:MM
            |> String.slice(0, 16)
          end)

        # Count events per minute
        Enum.map(events_by_minute, fn {minute, events} ->
          {minute, length(events)}
        end)
        |> Enum.sort_by(fn {minute, _} -> minute end)
      else
        []
      end

    {:ok,
     %{
       total_events: length(events),
       events_per_type: event_counts,
       events_per_resource: resource_counts,
       time_series: time_series
     }}
  end

  # Private functions

  # Gets events related to the given event (by correlation and causation)
  defp get_related_events(event) do
    # Get events in the same correlation chain
    with {:ok, correlation_events} <-
           EventStore.get_events(%{
             correlation_id: event.correlation_id,
             sort: [timestamp: :asc]
           }),
         # Get events caused by this event
         {:ok, caused_events} <-
           EventStore.get_events(%{
             causation_id: event.id,
             sort: [timestamp: :asc]
           }) do
      # Remove duplicates
      related =
        (correlation_events ++ caused_events)
        |> Enum.uniq_by(fn e -> e.id end)
        |> Enum.reject(fn e -> e.id == event.id end)

      {:ok, related}
    end
  end

  # Gets handlers that would process this event
  defp get_handlers_for_event(event) do
    handlers =
      GenRegistry.lookup_all(HydepwnsLiveview.Events.HandlerSupervisor.registry_name())
      |> Enum.filter(fn {_id, pid} ->
        handler_info = :sys.get_state(pid).handler_info

        Enum.member?(handler_info.event_types, event.type) ||
          handler_info.event_types == :all
      end)
      |> Enum.map(fn {id, _pid} -> id end)

    {:ok, handlers}
  end

  # Gets projections that would process this event
  defp get_projections_for_event(event) do
    projections =
      GenRegistry.lookup_all(HydepwnsLiveview.Events.ProjectionSupervisor.registry_name())
      |> Enum.filter(fn {_id, pid} ->
        projection_info = :sys.get_state(pid).projection_info

        Enum.member?(projection_info.interested_in, event.type) ||
          projection_info.interested_in == :all
      end)
      |> Enum.map(fn {id, _pid} -> id end)

    {:ok, projections}
  end

  # Compares two maps and returns the differences
  defp compare_maps(map1, map2) do
    keys1 = Map.keys(map1)
    keys2 = Map.keys(map2)
    all_keys = Enum.uniq(keys1 ++ keys2)

    Enum.reduce(all_keys, %{}, fn key, acc ->
      val1 = Map.get(map1, key)
      val2 = Map.get(map2, key)

      diff =
        cond do
          val1 == nil && val2 != nil ->
            {:only_in_second, val2}

          val1 != nil && val2 == nil ->
            {:only_in_first, val1}

          val1 != val2 ->
            {val1, val2}

          true ->
            nil
        end

      if diff, do: Map.put(acc, key, diff), else: acc
    end)
  end

  # Records the start of a replay session
  defp record_replay_start(session, events) do
    # Create telemetry event for replay start
    :telemetry.execute(
      [:hydepwns, :events, :replay, :start],
      %{count: length(events)},
      %{
        session_id: session.id,
        resource_type: session.resource_type,
        resource_id: session.resource_id
      }
    )
  end

  # Replays events for a debugging session
  defp replay_events(events, session_id) do
    start_time = System.monotonic_time()
    results = %{processed: 0, errors: []}

    # Process each event in sequence
    {results, had_error} =
      Enum.reduce_while(events, {results, false}, fn event, {acc, _} ->
        # Record processing time for this event
        event_start = System.monotonic_time()

        # Here we would typically execute some handler or projection logic
        # For debugging purposes, we just log the event
        Logger.debug("Replaying event: #{event.id} (#{event.type})")

        # Simulate processing (could be actual processing in a real implementation)
        :timer.sleep(50)

        # Calculate processing time
        event_time = System.monotonic_time() - event_start

        # Update the results
        new_acc = Map.update!(acc, :processed, &(&1 + 1))

        # Simulate occasional errors for demonstration
        if :rand.uniform(10) == 1 do
          error_info = %{
            event_id: event.id,
            error: "Simulated error during replay",
            time: DateTime.utc_now()
          }

          new_acc = Map.update!(new_acc, :errors, &[error_info | &1])

          # Create error telemetry event
          :telemetry.execute(
            [:hydepwns, :events, :replay, :error],
            %{count: 1, processing_time: event_time},
            %{session_id: session_id, event_id: event.id}
          )

          # Continue processing despite error
          {:cont, {new_acc, true}}
        else
          # Create success telemetry event
          :telemetry.execute(
            [:hydepwns, :events, :replay, :success],
            %{count: 1, processing_time: event_time},
            %{session_id: session_id, event_id: event.id}
          )

          # Continue processing
          {:cont, {new_acc, false}}
        end
      end)

    # Calculate total processing time
    total_time = System.monotonic_time() - start_time

    # Update the session with results
    final_results =
      Map.merge(results, %{
        total_time: total_time,
        events_count: length(events),
        completed_at: DateTime.utc_now()
      })

    # Update session status
    if had_error do
      EventStore.complete_replay_session(session_id, final_results)
    else
      EventStore.complete_replay_session(session_id, final_results)
    end

    # Final telemetry event
    :telemetry.execute(
      [:hydepwns, :events, :replay, :complete],
      %{
        count: results.processed,
        errors: length(results.errors),
        total_time: total_time
      },
      %{session_id: session_id}
    )
  end
end
