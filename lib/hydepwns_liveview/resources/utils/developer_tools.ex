defmodule HydepwnsLiveview.Resources.DeveloperTools do
  @moduledoc """
  Developer tools for the resource system.

  This module provides utilities for developers working with the resource system, including:
  - Interactive debugging tools for resource events
  - Resource state inspection and manipulation
  - Testing utilities for resource workflows
  - Development mode features for faster iteration
  - Diagnostic tools for event-sourced resources
  - Simulation tools for load and stress testing
  """

  require Logger
  alias HydepwnsLiveview.Events.Core.Event
  alias HydepwnsLiveview.Events.Core.EventStore
  alias HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResource
  alias HydepwnsLiveview.Events.ResourceIntegration.ResourceReplay
  alias HydepwnsLiveview.Events.Core.EventMonitor
  alias HydepwnsLiveview.Repo

  @spec start_debug_session(module(), any(), keyword()) :: {:ok, String.t()} | {:error, any()}
  @doc """
  Starts a debugging session for a resource.

  This creates an interactive session that captures all events
  for a resource and provides tools to inspect and manipulate state.

  ## Parameters
  * `resource_module` - The resource module
  * `id` - The resource ID
  * `opts` - Debugging options

  ## Returns
  * `{:ok, session_id}` - Debug session started
  * `{:error, reason}` - Failed to start debug session
  """
  def start_debug_session(resource_module, id, opts \\ []) do
    resource_type = resource_module.resource_type()
    session_id = Ecto.UUID.generate()

    # Create a session record
    session = %{
      id: session_id,
      resource_type: resource_type,
      resource_id: id,
      started_at: DateTime.utc_now(),
      events: [],
      snapshots: [],
      breakpoints: Keyword.get(opts, :breakpoints, []),
      options: opts
    }

    # Store the session
    Process.put({:debug_session, session_id}, session)

    # Set up event capture
    :ok = subscribe_to_resource_events(resource_type, id, session_id)

    # Create initial state snapshot
    initial_state =
      case EventSourcedResource.get_current_state(resource_module, id) do
        {:ok, state} -> state
        _ -> resource_module.initial_state()
      end

    session =
      Map.update!(session, :snapshots, fn snapshots ->
        [
          %{
            timestamp: DateTime.utc_now(),
            label: "Initial state",
            state: initial_state
          }
          | snapshots
        ]
      end)

    # Update session
    Process.put({:debug_session, session_id}, session)

    Logger.info("Debug session #{session_id} started for #{resource_type}:#{id}")

    {:ok, session_id}
  end

  @spec get_debug_session(String.t()) :: {:ok, map()} | {:error, :session_not_found}
  @doc """
  Gets the current status of a debug session.

  ## Parameters
  * `session_id` - The debug session ID

  ## Returns
  * `{:ok, session}` - Session status
  * `{:error, :session_not_found}` - Session not found
  """
  def get_debug_session(session_id) do
    case Process.get({:debug_session, session_id}) do
      nil -> {:error, :session_not_found}
      session -> {:ok, session}
    end
  end

  @spec create_debug_snapshot(String.t(), String.t()) :: {:ok, map()} | {:error, any()}
  @doc """
  Creates a snapshot of resource state during debugging.

  ## Parameters
  * `session_id` - The debug session ID
  * `label` - Label for the snapshot

  ## Returns
  * `{:ok, snapshot}` - Snapshot created
  * `{:error, reason}` - Failed to create snapshot
  """
  def create_debug_snapshot(session_id, label) do
    with {:ok, session} <- get_debug_session(session_id) do
      # Get current state
      {:ok, resource_module} = get_resource_module(session.resource_type)

      current_state =
        case EventSourcedResource.get_current_state(resource_module, session.resource_id) do
          {:ok, state} -> state
          _ -> resource_module.initial_state()
        end

      # Create snapshot
      snapshot = %{
        timestamp: DateTime.utc_now(),
        label: label,
        state: current_state
      }

      # Update session
      updated_session =
        Map.update!(session, :snapshots, fn snapshots ->
          [snapshot | snapshots]
        end)

      Process.put({:debug_session, session_id}, updated_session)

      {:ok, snapshot}
    end
  end

  @spec compare_debug_snapshots(String.t(), integer(), integer()) :: {:ok, map()} | {:error, any()}
  @doc """
  Compares state between snapshots in a debug session.

  ## Parameters
  * `session_id` - The debug session ID
  * `snapshot1_index` - Index of first snapshot
  * `snapshot2_index` - Index of second snapshot

  ## Returns
  * `{:ok, diff}` - Differences between snapshots
  * `{:error, reason}` - Failed to compare snapshots
  """
  def compare_debug_snapshots(session_id, snapshot1_index, snapshot2_index) do
    with {:ok, session} <- get_debug_session(session_id) do
      snapshots = session.snapshots

      if snapshot1_index >= length(snapshots) or snapshot2_index >= length(snapshots) do
        {:error, :invalid_snapshot_index}
      else
        snapshot1 = Enum.at(snapshots, snapshot1_index)
        snapshot2 = Enum.at(snapshots, snapshot2_index)

        # Compute differences
        diff = compute_state_diff(snapshot1.state, snapshot2.state)

        {:ok,
         %{
           snapshot1: snapshot1,
           snapshot2: snapshot2,
           differences: diff
         }}
      end
    end
  end

  @spec set_breakpoint(String.t(), atom(), (map() -> boolean()) | nil) :: {:ok, String.t()} | {:error, any()}
  @doc """
  Sets a breakpoint for a specific event type.

  When an event matching the breakpoint occurs, the debug session
  will pause processing and notify the developer.

  ## Parameters
  * `session_id` - The debug session ID
  * `event_type` - The event type to break on
  * `condition` - Optional condition function

  ## Returns
  * `{:ok, breakpoint_id}` - Breakpoint set
  * `{:error, reason}` - Failed to set breakpoint
  """
  def set_breakpoint(session_id, event_type, condition \\ nil) do
    with {:ok, session} <- get_debug_session(session_id) do
      breakpoint_id = Ecto.UUID.generate()

      breakpoint = %{
        id: breakpoint_id,
        event_type: event_type,
        condition: condition,
        created_at: DateTime.utc_now()
      }

      # Update session with new breakpoint
      updated_session =
        Map.update!(session, :breakpoints, fn breakpoints ->
          [breakpoint | breakpoints]
        end)

      Process.put({:debug_session, session_id}, updated_session)

      {:ok, breakpoint_id}
    end
  end

  @spec generate_test_events(module(), any(), list({atom(), map()}), keyword()) :: {:ok, list(map())} | {:error, any()}
  @doc """
  Generates test events for a resource.

  This creates events that can be used to test resource behavior
  without affecting production data.

  ## Parameters
  * `resource_module` - The resource module
  * `id` - The resource ID
  * `event_specs` - Specifications for events to generate
  * `opts` - Generation options

  ## Returns
  * `{:ok, events}` - Generated events
  * `{:error, reason}` - Failed to generate events
  """
  def generate_test_events(resource_module, id, event_specs, opts \\ []) do
    resource_type = resource_module.resource_type()
    correlation_id = Keyword.get(opts, :correlation_id, Ecto.UUID.generate())

    # Generate events from specifications
    events =
      Enum.map(event_specs, fn {event_type, data} ->
        %Event{
          type: event_type,
          resource_type: resource_type,
          resource_id: id,
          data: data,
          metadata: %{
            generated: true,
            test: true,
            generator: "developer_tools"
          },
          correlation_id: correlation_id
        }
      end)

    # Store events if requested
    if Keyword.get(opts, :store, false) do
      Enum.each(events, fn event ->
        EventStore.store_event(event)
      end)
    end

    {:ok, events}
  end

  @spec create_resource_sandbox(list(module()), keyword()) :: {:ok, String.t()} | {:error, any()}
  @doc """
  Creates a sandbox for experimenting with resources.

  This sets up an isolated environment where developers can experiment
  with resources without affecting production data.

  ## Parameters
  * `resource_modules` - List of resource modules to include
  * `opts` - Sandbox options

  ## Returns
  * `{:ok, sandbox_id}` - Sandbox created
  * `{:error, reason}` - Failed to create sandbox
  """
  def create_resource_sandbox(resource_modules, opts \\ []) do
    sandbox_id = Keyword.get(opts, :id, Ecto.UUID.generate())

    # Initialize sandbox state
    sandbox = %{
      id: sandbox_id,
      created_at: DateTime.utc_now(),
      resources: %{},
      events: [],
      options: opts
    }

    # Initialize resources in sandbox
    resources =
      Enum.reduce(resource_modules, %{}, fn resource_module, acc ->
        resource_type = resource_module.resource_type()

        # Create a test instance
        instance_id = Ecto.UUID.generate()
        initial_state = resource_module.initial_state()

        # Add to sandbox resources
        Map.put(acc, resource_type, %{
          module: resource_module,
          instances: %{
            instance_id => %{
              id: instance_id,
              state: initial_state,
              events: []
            }
          }
        })
      end)

    # Store sandbox with resources
    sandbox = Map.put(sandbox, :resources, resources)
    Process.put({:resource_sandbox, sandbox_id}, sandbox)

    {:ok, sandbox_id}
  end

  @spec apply_sandbox_event(String.t(), atom(), String.t(), map()) :: {:ok, any()} | {:error, any()}
  @doc """
  Applies an event in a sandbox environment.

  ## Parameters
  * `sandbox_id` - The sandbox ID
  * `resource_type` - The resource type
  * `instance_id` - The resource instance ID
  * `event` - The event to apply

  ## Returns
  * `{:ok, new_state}` - Event applied successfully
  * `{:error, reason}` - Failed to apply event
  """
  def apply_sandbox_event(sandbox_id, resource_type, instance_id, event) do
    with {:ok, sandbox} <- get_sandbox(sandbox_id),
         {:ok, resource} <- get_sandbox_resource(sandbox, resource_type),
         {:ok, instance} <- get_sandbox_instance(resource, instance_id) do
      # Get the resource module
      resource_module = resource.module

      # Apply the event to get new state
      new_state = resource_module.apply_event(event, instance.state)

      # Update instance with new state and event
      updated_instance = %{
        instance
        | state: new_state,
          events: [event | instance.events]
      }

      # Update resource instances
      updated_resource = %{
        resource
        | instances: Map.put(resource.instances, instance_id, updated_instance)
      }

      # Update sandbox resources
      updated_resources = Map.put(sandbox.resources, resource_type, updated_resource)

      # Update sandbox
      updated_sandbox = %{
        sandbox
        | resources: updated_resources,
          events: [event | sandbox.events]
      }

      # Store updated sandbox
      Process.put({:resource_sandbox, sandbox_id}, updated_sandbox)

      {:ok, new_state}
    end
  end

  @spec run_load_test(module(), (module(), any() -> any()), keyword()) :: {:ok, map()} | {:error, any()}
  @doc """
  Runs a load test on the resource system.

  ## Parameters
  * `resource_module` - The resource module
  * `operation_fn` - Function that performs an operation on a resource
  * `opts` - Load test options

  ## Returns
  * `{:ok, results}` - Load test results
  * `{:error, reason}` - Failed to run load test
  """
  def run_load_test(resource_module, operation_fn, opts \\ []) do
    # Default options
    concurrency = Keyword.get(opts, :concurrency, 10)
    operations = Keyword.get(opts, :operations, 100)

    resource_type = resource_module.resource_type()
    test_id = Ecto.UUID.generate()

    Logger.info("Starting load test #{test_id} for #{resource_type}")

    # Track metrics
    start_time = System.monotonic_time(:millisecond)

    # Create a task for each concurrent operation
    task_results =
      1..concurrency
      |> Enum.map(fn worker_id ->
        Task.async(fn ->
          # Calculate operations for this worker
          worker_operations = div(operations, concurrency)

          # Run operations
          results =
            Enum.map(1..worker_operations, fn i ->
              op_start_time = System.monotonic_time(:millisecond)

              # Generate a unique ID for this operation
              resource_id = "test-#{test_id}-#{worker_id}-#{i}"

              # Run the operation and capture result
              {result, time_taken} =
                try do
                  result = operation_fn.(resource_module, resource_id)
                  end_time = System.monotonic_time(:millisecond)
                  {result, end_time - op_start_time}
                catch
                  kind, error ->
                    {{:error, {kind, error}}, System.monotonic_time(:millisecond) - op_start_time}
                end

              # Return operation result with metrics
              %{
                worker_id: worker_id,
                operation: i,
                resource_id: resource_id,
                result: result,
                time_ms: time_taken
              }
            end)

          # Return all results from this worker
          %{
            worker_id: worker_id,
            operations: worker_operations,
            results: results
          }
        end)
      end)
      |> Enum.map(&Task.await(&1, 60_000))

    # Calculate final metrics
    end_time = System.monotonic_time(:millisecond)
    total_time = end_time - start_time

    # Flatten all operation results
    all_operations = Enum.flat_map(task_results, fn worker -> worker.results end)

    # Calculate statistics
    successful = Enum.count(all_operations, fn op -> match?({:ok, _}, op.result) end)
    failed = length(all_operations) - successful

    times = Enum.map(all_operations, & &1.time_ms)
    avg_time = Enum.sum(times) / length(times)
    max_time = Enum.max(times)
    min_time = Enum.min(times)

    # Format results
    results = %{
      test_id: test_id,
      resource_type: resource_type,
      total_operations: length(all_operations),
      successful_operations: successful,
      failed_operations: failed,
      total_time_ms: total_time,
      operations_per_second: length(all_operations) / (total_time / 1000),
      avg_operation_time_ms: avg_time,
      min_operation_time_ms: min_time,
      max_operation_time_ms: max_time,
      concurrency: concurrency,
      worker_results: task_results
    }

    Logger.info(
      "Load test #{test_id} completed: #{successful}/#{length(all_operations)} operations successful"
    )

    {:ok, results}
  end

  @spec visualize_event_flow(module(), any(), keyword()) :: {:ok, map()} | {:error, any()}
  @doc """
  Creates a visualization of event flow for a resource.

  ## Parameters
  * `resource_module` - The resource module
  * `id` - The resource ID
  * `opts` - Visualization options

  ## Returns
  * `{:ok, visualization}` - Event flow visualization
  * `{:error, reason}` - Failed to create visualization
  """
  def visualize_event_flow(resource_module, id, opts \\ []) do
    resource_type = resource_module.resource_type()

    # Get events for this resource
    {:ok, events} =
      EventStore.get_events(%{
        resource_type: resource_type,
        resource_id: id,
        sort: [timestamp: :asc]
      })

    # Group events by correlation
    events_by_correlation = Enum.group_by(events, & &1.correlation_id)

    # Build a timeline visualization
    timeline =
      Enum.map(events, fn event ->
        %{
          id: event.id,
          type: event.type,
          timestamp: event.timestamp,
          correlation_id: event.correlation_id,
          causation_id: event.causation_id,
          data_summary: summarize_event_data(event.data)
        }
      end)

    # Build a graph of event relationships
    graph = %{
      nodes:
        Enum.map(events, fn event ->
          %{
            id: event.id,
            type: event.type,
            data: summarize_event_data(event.data),
            timestamp: event.timestamp
          }
        end),
      edges: build_event_edges(events)
    }

    visualization = %{
      resource_type: resource_type,
      resource_id: id,
      event_count: length(events),
      timeline: timeline,
      graph: graph,
      correlation_chains: events_by_correlation
    }

    {:ok, visualization}
  end

  @spec generate_event_documentation(module()) :: {:ok, map()} | {:error, any()}
  @doc """
  Generates documentation for a resource's event schema.

  ## Parameters
  * `resource_module` - The resource module

  ## Returns
  * `{:ok, documentation}` - Generated documentation
  * `{:error, reason}` - Failed to generate documentation
  """
  def generate_event_documentation(resource_module) do
    resource_type = resource_module.resource_type()

    # Get all event types for this resource
    event_types =
      try do
        resource_module.event_types()
      rescue
        _ ->
          # Try to infer from existing events
          {:ok, events} =
            EventStore.get_events(%{
              resource_type: resource_type,
              limit: 1000
            })

          events
          |> Enum.map(& &1.type)
          |> Enum.uniq()
      end

    # Document each event type
    event_docs =
      Enum.map(event_types, fn event_type ->
        # Try to get schema information
        schema =
          try do
            resource_module.event_schema(event_type)
          rescue
            _ -> %{}
          end

        # Get example events
        {:ok, examples} =
          EventStore.get_events(%{
            resource_type: resource_type,
            type: event_type,
            limit: 5
          })

        %{
          type: event_type,
          schema: schema,
          examples: Enum.map(examples, fn e -> Map.take(e, [:data, :metadata, :timestamp]) end),
          description: extract_event_description(resource_module, event_type)
        }
      end)

    documentation = %{
      resource_type: resource_type,
      event_types: event_docs,
      module: resource_module,
      generated_at: DateTime.utc_now()
    }

    {:ok, documentation}
  end

  # Private helper functions

  defp subscribe_to_resource_events(resource_type, resource_id, session_id) do
    # Subscribe to events for the resource
    # This is a simplified implementation
    pid = self()

    # Set up subscription
    # In a real implementation, this would use your PubSub system
    HydepwnsLiveview.Events.EventBus.subscribe(self(), :all)

    :ok
  end

  defp handle_debug_event(event, session_id, pid) do
    # Get current session
    case Process.get({:debug_session, session_id}) do
      nil ->
        # Session no longer exists
        :ok

      session ->
        # Check for breakpoints
        should_break =
          Enum.any?(session.breakpoints, fn breakpoint ->
            event.type == breakpoint.event_type &&
              (breakpoint.condition == nil || breakpoint.condition.(event))
          end)

        # Add event to session
        updated_session =
          Map.update!(session, :events, fn events ->
            [event | events]
          end)

        Process.put({:debug_session, session_id}, updated_session)

        # Notify if breakpoint hit
        if should_break do
          send(pid, {:debug_breakpoint, session_id, event})
        end

        :ok
    end
  end

  defp compute_state_diff(state1, state2) do
    # This is a simple implementation; you might want to use a more sophisticated
    # diffing algorithm for complex states
    Map.keys(state1)
    |> Enum.concat(Map.keys(state2))
    |> Enum.uniq()
    |> Enum.reduce(%{}, fn key, acc ->
      value1 = Map.get(state1, key)
      value2 = Map.get(state2, key)

      if value1 == value2 do
        acc
      else
        Map.put(acc, key, %{before: value1, after: value2})
      end
    end)
  end

  defp get_resource_module(resource_type) do
    # This would look up the module based on resource type
    # In a real implementation, you would have a registry of modules
    {:error, :not_implemented}
  end

  defp get_sandbox(sandbox_id) do
    case Process.get({:resource_sandbox, sandbox_id}) do
      nil -> {:error, :sandbox_not_found}
      sandbox -> {:ok, sandbox}
    end
  end

  defp get_sandbox_resource(sandbox, resource_type) do
    case Map.get(sandbox.resources, resource_type) do
      nil -> {:error, :resource_not_found_in_sandbox}
      resource -> {:ok, resource}
    end
  end

  defp get_sandbox_instance(resource, instance_id) do
    case Map.get(resource.instances, instance_id) do
      nil -> {:error, :instance_not_found_in_sandbox}
      instance -> {:ok, instance}
    end
  end

  defp summarize_event_data(data) when is_map(data) do
    # Summarize event data for visualization
    # This implementation provides a brief summary
    keys = Map.keys(data)

    if length(keys) <= 3 do
      data
    else
      # For larger maps, just include key names
      %{
        keys: keys,
        summary: "#{length(keys)} fields"
      }
    end
  end

  defp summarize_event_data(data), do: data

  defp build_event_edges(events) do
    # Build edges based on causation relationships
    # Add correlation edges
    Enum.flat_map(events, fn event ->
      if event.causation_id do
        [
          %{
            source: event.causation_id,
            target: event.id,
            type: "causation"
          }
        ]
      else
        []
      end
    end) ++
      build_correlation_edges(events)
  end

  defp build_correlation_edges(events) do
    # Group by correlation ID
    events_by_correlation = Enum.group_by(events, & &1.correlation_id)

    # For each correlation group, create edges between sequential events
    Enum.flat_map(events_by_correlation, fn {correlation_id, correlated_events} ->
      # Skip if only one event or no correlation ID
      if correlation_id && length(correlated_events) > 1 do
        # Sort by timestamp
        sorted_events = Enum.sort_by(correlated_events, & &1.timestamp)

        # Create edges between adjacent events in the correlation
        sorted_events
        |> Enum.with_index()
        |> Enum.flat_map(fn {event, index} ->
          if index < length(sorted_events) - 1 do
            next_event = Enum.at(sorted_events, index + 1)

            [
              %{
                source: event.id,
                target: next_event.id,
                type: "correlation"
              }
            ]
          else
            []
          end
        end)
      else
        []
      end
    end)
  end

  defp extract_event_description(resource_module, event_type) do
    # Try to extract documentation from the module
    try do
      resource_module.describe_event(event_type)
    rescue
      _ -> "No description available"
    end
  end
end
