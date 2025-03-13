defmodule HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResource do
  @moduledoc """
  Behavior and implementation for event-sourced resources.

  This module provides functionality to create resources that are sourced from events.
  Instead of directly storing the current state in a database, the state is derived
  from a sequence of events that have occurred.
  """

  alias HydepwnsLiveview.Events.Core.Event
  alias HydepwnsLiveview.Events.Core.EventStore
  alias HydepwnsLiveview.Events.Core.EventBus

  @type event :: %Event{}
  @type resource_id :: String.t()
  @type resource_state :: map()
  @type event_metadata :: map()

  @callback initial_state() :: resource_state()
  @callback apply_event(event, resource_state()) :: resource_state()
  @callback resource_type() :: String.t()

  @doc """
  Defines a module as an event-sourced resource.

  This macro adds all the necessary functionality to make a module
  an event-sourced resource, including:
  - State construction from events
  - Command processing
  - Event generation and publishing
  - Snapshot management
  - Event replay
  """
  defmacro __using__(opts) do
    snapshot_interval = Keyword.get(opts, :snapshot_interval, 100)

    quote do
      @behaviour HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResource

      alias HydepwnsLiveview.Events.Core.Event
      alias HydepwnsLiveview.Events.Core.EventStore
      alias HydepwnsLiveview.Events.Core.EventBus
      alias HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResource

      # Default snapshot interval (can be overridden)
      def snapshot_interval, do: unquote(snapshot_interval)

      @doc """
      Gets a resource by ID, reconstructing it from events.

      ## Parameters

      * `id` - The ID of the resource to get

      ## Returns

      * `{:ok, resource}` - The resource was found and reconstructed
      * `{:error, reason}` - The resource could not be retrieved
      """
      def get(id) do
        # Try to get the latest snapshot first
        case get_latest_snapshot(id) do
          {:ok, snapshot} ->
            # Get events since the snapshot
            with {:ok, events} <-
                   EventStore.get_events_since_event_id(
                     resource_type(),
                     id,
                     snapshot.metadata.event_id
                   ) do
              # Rebuild state from the snapshot and subsequent events
              state =
                EventSourcedResource.rebuild_from_events(events, snapshot.state, &apply_event/2)

              {:ok, Map.put(state, :id, id)}
            end

          {:error, :snapshot_not_found} ->
            # No snapshot, rebuild from all events
            with {:ok, events} <-
                   EventStore.get_events(resource_type(), id, %{sort: [timestamp: :asc]}) do
              if Enum.empty?(events) do
                {:error, :not_found}
              else
                state =
                  EventSourcedResource.rebuild_from_events(
                    events,
                    initial_state(),
                    &apply_event/2
                  )

                {:ok, Map.put(state, :id, id)}
              end
            end

          error ->
            error
        end
      end

      @doc """
      Gets a resource at a specific point in time.

      ## Parameters

      * `id` - The ID of the resource to get
      * `timestamp` - The point in time at which to get the resource

      ## Returns

      * `{:ok, resource}` - The resource was found and reconstructed at that point
      * `{:error, reason}` - The resource could not be retrieved
      """
      def get_at(id, timestamp) do
        # Find the most recent snapshot before timestamp
        with {:ok, snapshot} <- EventStore.get_snapshot_before(resource_type(), id, timestamp),
             # Get events between snapshot and timestamp
             {:ok, events} <-
               EventStore.get_events_between(
                 resource_type(),
                 id,
                 snapshot.metadata.timestamp,
                 timestamp,
                 %{sort: [timestamp: :asc]}
               ) do
          # Rebuild state from the snapshot and subsequent events
          state = EventSourcedResource.rebuild_from_events(events, snapshot.state, &apply_event/2)
          {:ok, Map.put(state, :id, id)}
        else
          {:error, :snapshot_not_found} ->
            # No snapshot, get all events up to timestamp
            with {:ok, events} <-
                   EventStore.get_events_before(resource_type(), id, timestamp, %{
                     sort: [timestamp: :asc]
                   }) do
              if Enum.empty?(events) do
                {:error, :not_found}
              else
                state =
                  EventSourcedResource.rebuild_from_events(
                    events,
                    initial_state(),
                    &apply_event/2
                  )

                {:ok, Map.put(state, :id, id)}
              end
            end

          error ->
            error
        end
      end

      @doc """
      Creates a new event-sourced resource.

      ## Parameters

      * `params` - The parameters for the new resource
      * `metadata` - Additional metadata for the creation event

      ## Returns

      * `{:ok, resource}` - The resource was created
      * `{:error, reason}` - The resource could not be created
      """
      def create(params) do
        id = params[:id] || params["id"] || Ecto.UUID.generate()

        # Create events for resource creation
        events = create_events(id, params)

        # Apply the events to the initial state
        state =
          EventSourcedResource.rebuild_from_events(events, initial_state(), &apply_event/2)
          |> Map.put(:id, id)

        # Publish events
        with :ok <- publish_events(events, %{action: "create"}) do
          # Check if we should save a snapshot
          if length(events) >= snapshot_interval() do
            EventStore.save_snapshot(resource_type(), id, state, %{
              event_id: List.last(events).id,
              timestamp: DateTime.utc_now()
            })
          end

          {:ok, state}
        end
      end

      @doc """
      Executes a command on the resource, generating events.

      ## Parameters

      * `id` - The ID of the resource
      * `command` - The command to execute
      * `params` - Parameters for the command
      * `metadata` - Additional metadata for the events

      ## Returns

      * `{:ok, updated_resource}` - The command was executed successfully
      * `{:error, reason}` - The command could not be executed
      """
      def execute(id, command, params \\ %{}, metadata \\ %{}) do
        with {:ok, resource} <- get(id) do
          # Generate events for this command
          events = execute_command(resource, command, params)

          # Add metadata to events
          events =
            Enum.map(events, fn event ->
              %{event | metadata: Map.merge(event.metadata || %{}, metadata)}
            end)

          # Apply events to current state
          updated_state =
            EventSourcedResource.rebuild_from_events(events, resource, &apply_event/2)

          # Publish events
          with :ok <- publish_events(events, Map.put(metadata, :command, command)) do
            # Check if we should save a snapshot
            last_event = List.last(events)
            maybe_save_snapshot(id, updated_state, last_event)

            {:ok, updated_state}
          end
        end
      end

      @doc """
      Updates a resource by generating and applying events.

      ## Parameters

      * `resource` - The resource to update
      * `params` - The update parameters
      * `metadata` - Additional metadata for the update events

      ## Returns

      * `{:ok, updated_resource}` - The resource was updated
      * `{:error, reason}` - The resource could not be updated
      """
      def update(resource, params, metadata \\ %{}) do
        id = resource.id

        # Generate update events
        events = update_events(resource, params)

        # Apply events to current state
        updated_state =
          EventSourcedResource.rebuild_from_events(events, resource, &apply_event/2)

        # Publish events
        with :ok <- publish_events(events, Map.put(metadata, :action, "update")) do
          # Check if we should save a snapshot
          last_event = List.last(events)
          maybe_save_snapshot(id, updated_state, last_event)

          {:ok, updated_state}
        end
      end

      @doc """
      Deletes a resource by generating a deletion event.

      ## Parameters

      * `resource` - The resource to delete
      * `metadata` - Additional metadata for the deletion event

      ## Returns

      * `{:ok, resource}` - The resource was marked as deleted
      * `{:error, reason}` - The resource could not be deleted
      """
      def delete(resource, metadata \\ %{}) do
        id = resource.id

        # Create deletion event
        deletion_event = %Event{
          id: Ecto.UUID.generate(),
          type: "#{resource_type()}.deleted",
          resource_id: id,
          resource_type: resource_type(),
          timestamp: DateTime.utc_now(),
          data: %{deleted_at: DateTime.utc_now()},
          metadata: Map.merge(%{action: "delete"}, metadata)
        }

        # Apply event to current state
        deleted_state = apply_event(deletion_event, resource)

        # Publish event
        with :ok <- publish_events([deletion_event], metadata) do
          # Create a final snapshot of the deleted state
          EventStore.save_snapshot(resource_type(), id, deleted_state, %{
            event_id: deletion_event.id,
            timestamp: DateTime.utc_now(),
            is_deletion: true
          })

          {:ok, deleted_state}
        end
      end

      @doc """
      Gets the event history for a resource.

      ## Parameters

      * `id` - The ID of the resource
      * `opts` - Options for filtering events

      ## Returns

      * `{:ok, events}` - The events for the resource
      * `{:error, reason}` - Could not retrieve events
      """
      def get_history(id, opts \\ %{}) do
        EventStore.get_events(resource_type(), id, opts)
      end

      # Override these in your resource module

      @doc """
      Creates events for resource creation.

      To be implemented by resource modules.

      ## Parameters

      * `id` - The ID of the new resource
      * `params` - The parameters for the new resource

      ## Returns

      * List of events to apply
      """
      def create_events(id, params) do
        # Default implementation - a simple created event
        [
          %Event{
            id: Ecto.UUID.generate(),
            type: "#{resource_type()}.created",
            resource_id: id,
            resource_type: resource_type(),
            timestamp: DateTime.utc_now(),
            data: params
          }
        ]
      end

      @doc """
      Generates events for a command.

      To be implemented by resource modules.

      ## Parameters

      * `resource` - The current resource state
      * `command` - The command to execute
      * `params` - Parameters for the command

      ## Returns

      * List of events to apply
      """
      def execute_command(resource, command, params) do
        # This should be overridden in specific resource modules
        raise "Not implemented: execute_command for #{command}"
      end

      @doc """
      Generates events for an update.

      To be implemented by resource modules.

      ## Parameters

      * `resource` - The current resource state
      * `params` - The update parameters

      ## Returns

      * List of events to apply
      """
      def update_events(resource, params) do
        # Default implementation - a simple updated event
        [
          %Event{
            id: Ecto.UUID.generate(),
            type: "#{resource_type()}.updated",
            resource_id: resource.id,
            resource_type: resource_type(),
            timestamp: DateTime.utc_now(),
            data: params
          }
        ]
      end

      defp resource_type_from_module(module) do
        module
        |> Atom.to_string()
        |> String.split(".")
        |> List.last()
        |> then(fn name -> String.replace(name, "Resource", "") end)
        |> String.downcase()
      end

      defp publish_events(events, metadata) do
        Enum.reduce_while(events, :ok, fn event ->
          case EventBus.publish(event) do
            :ok -> {:cont, :ok}
            error -> {:halt, error}
          end
        end)
      end

      defp get_latest_snapshot(id) do
        case EventStore.get_latest_snapshot(resource_type(), id) do
          {:ok, snapshot} -> {:ok, snapshot}
          {:error, :not_found} -> {:error, :snapshot_not_found}
          error -> error
        end
      end

      defp maybe_save_snapshot(id, state, last_event) do
        # Get count of events since last snapshot
        case EventStore.count_events_since_last_snapshot(resource_type(), id) do
          {:ok, count} ->
            # Get the interval
            interval = snapshot_interval()
            # Compare outside of guard context
            if count >= interval do
              # Save a new snapshot
              EventStore.save_snapshot(resource_type(), id, state, %{
                event_id: last_event.id,
                timestamp: DateTime.utc_now()
              })
            else
              :ok
            end

          _ ->
            :ok
        end
      end
    end
  end

  @doc """
  Rebuilds resource state from a sequence of events.

  ## Parameters

  * `events` - List of events to apply
  * `initial_state` - Starting state to build from
  * `apply_event_fn` - Function that applies an event to the state

  ## Returns

  The final state after applying all events
  """
  def rebuild_from_events(events, initial_state, apply_event_fn) when is_list(events) do
    Enum.reduce(events, initial_state, apply_event_fn)
  end

  @doc """
  Sets the snapshot interval for the resource.

  ## Parameters

  * `interval` - Number of events between snapshots

  ## Returns

  The snapshot interval
  """
  def set_snapshot_interval(_resource_module, interval)
      when is_integer(interval) and interval > 0 do
    # This function would normally update some configuration
    # For now, it just returns the interval
    interval
  end

  @doc """
  Lists all resources of a specific type.

  ## Parameters

  * `resource_module` - The resource module

  ## Returns

  * `{:ok, resource_ids}` - The list of resource IDs
  * `{:error, reason}` - Failed to list resources
  """
  def list_resources(resource_module) do
    resource_type = resource_module.resource_type()
    EventStore.list_resources_by_type(resource_type)
  end

  @doc """
  Creates a new event for a resource.

  ## Parameters

  * `resource_module` - The resource module
  * `id` - The resource ID
  * `event_type` - The event type (without resource prefix)
  * `data` - The event data
  * `metadata` - Additional metadata for the event

  ## Returns

  * `{:ok, event}` - The event was created
  * `{:error, reason}` - Failed to create event
  """
  def create_event(resource_module, id, event_type, data, metadata \\ %{}) do
    resource_type = resource_module.resource_type()

    event = %Event{
      id: Ecto.UUID.generate(),
      type: "#{resource_type}.#{event_type}",
      resource_id: id,
      resource_type: resource_type,
      timestamp: DateTime.utc_now(),
      data: data,
      metadata: metadata
    }

    {:ok, event}
  end
end
