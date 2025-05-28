defmodule HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResource do
  @moduledoc """
  Behavior and implementation for event-sourced resources.

  This module provides macros and helpers to define resources whose state is derived from a sequence of events, rather than direct database storage.

  ## Usage

      defmodule MyApp.MyResource do
        use HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResource

        def initial_state, do: %{}
        def apply_event(event, state), do: # your logic here
        def resource_type, do: "my_resource"
      end

  ## Features

  - State construction from events
  - Command processing and event generation
  - Event publishing via EventBus
  - Snapshot management for efficient state recovery
  - Event replay and point-in-time queries

  ## Generated API

  - `get/1` — Get resource by ID
  - `get_at/2` — Get resource at a specific point in time
  - `create/1` — Create a new resource
  - `execute/4` — Execute a command on a resource
  - `update/3` — Update a resource
  - `delete/2` — Delete a resource (soft delete via event)
  - `get_history/2` — Get event history for a resource

  ## Required Callbacks

  - `initial_state/0` — Returns the initial state for the resource
  - `apply_event/2` — Applies an event to the resource state
  - `resource_type/0` — Returns the resource type as a string

  See also: `EventStore`, `EventBus`
  """

  alias HydepwnsLiveview.Events.Core.Event
  alias HydepwnsLiveview.Events.Core.EventStore
  alias HydepwnsLiveview.Events.Core.EventBus

  @type event :: %Event{}
  @type resource_id :: String.t()
  @type resource_state :: map()
  @type event_metadata :: map()

  @doc "Returns the initial state for the resource."
  @callback initial_state() :: resource_state()

  @doc "Applies an event to the resource state."
  @callback apply_event(event, resource_state()) :: resource_state()

  @doc "Returns the resource type as a string."
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

  ## Example

      use HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResource

  ## Generated Functions

  - `get/1`, `get_at/2`, `create/1`, `execute/4`, `update/3`, `delete/2`, `get_history/2`

  ## Required Callbacks

  - `initial_state/0`, `apply_event/2`, `resource_type/0`
  """
  defmacro __using__(opts) do
    snapshot_interval = Keyword.get(opts, :snapshot_interval, 100)

    quote do
      @behaviour HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResource

      alias HydepwnsLiveview.Events.Core.Event
      alias HydepwnsLiveview.Events.Core.EventStore
      alias HydepwnsLiveview.Events.Core.EventBus
      alias HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResource

      def snapshot_interval, do: unquote(snapshot_interval)

      unquote(define_resource_getter())
      unquote(define_resource_getter_at())
      unquote(define_resource_creator())
      unquote(define_resource_executor())
      unquote(define_resource_updater())
      unquote(define_resource_deleter())
      unquote(define_resource_history())
      unquote(define_event_creators())
      unquote(define_private_helpers())
    end
  end

  # Helper for get/1
  defp define_resource_getter do
    quote do
      @doc """
      Gets a resource by ID, reconstructing it from events.

      ## Parameters

      * `id` - The ID of the resource to get

      ## Returns

      * `{:ok, resource}` - The resource was found and reconstructed
      * `{:error, reason}` - The resource could not be retrieved
      """
      def get(id) do
        HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResource.__get_resource__(
          id,
          __MODULE__
        )
      end
    end
  end

  # Helper for get_at/2
  defp define_resource_getter_at do
    quote do
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
        HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResource.__get_resource_at__(
          id,
          timestamp,
          __MODULE__
        )
      end
    end
  end

  # Helper for create/1
  defp define_resource_creator do
    quote do
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
        HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResource.__create_resource__(
          params,
          __MODULE__
        )
      end
    end
  end

  # Helper for execute/4
  defp define_resource_executor do
    quote do
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
        HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResource.__execute_resource__(
          id,
          command,
          params,
          metadata,
          __MODULE__
        )
      end
    end
  end

  # Helper for update/3
  defp define_resource_updater do
    quote do
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
        HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResource.__update_resource__(
          resource,
          params,
          metadata,
          __MODULE__
        )
      end
    end
  end

  # Helper for delete/2
  defp define_resource_deleter do
    quote do
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
        HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResource.__delete_resource__(
          resource,
          metadata,
          __MODULE__
        )
      end
    end
  end

  # Helper for get_history/2
  defp define_resource_history do
    quote do
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
        HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResource.__get_history__(
          id,
          opts,
          __MODULE__
        )
      end
    end
  end

  # Helper for event creators (create_events, execute_command, update_events)
  defp define_event_creators do
    quote do
      @doc """
      Creates events for resource creation.

      To be implemented by resource modules.

      ## Parameters

      * `id` - The ID of the new resource
      * `params` - The parameters for the new resource

      ## Returns

      * List of events to apply
      """
      def create_events(id, params),
        do:
          HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResource.__create_events__(
            id,
            params,
            __MODULE__
          )

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
      def execute_command(resource, command, params),
        do:
          HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResource.__execute_command__(
            resource,
            command,
            params,
            __MODULE__
          )

      @doc """
      Generates events for an update.

      To be implemented by resource modules.

      ## Parameters

      * `resource` - The current resource state
      * `params` - The update parameters

      ## Returns

      * List of events to apply
      """
      def update_events(resource, params),
        do:
          HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResource.__update_events__(
            resource,
            params,
            __MODULE__
          )
    end
  end

  # Helper for private helpers (publish_events, get_latest_snapshot, maybe_save_snapshot, etc.)
  defp define_private_helpers do
    quote do
      defp publish_events(events, metadata),
        do:
          HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResource.__publish_events__(
            events,
            metadata,
            __MODULE__
          )

      defp get_latest_snapshot(id),
        do:
          HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResource.__get_latest_snapshot__(
            id,
            __MODULE__
          )

      defp maybe_save_snapshot(id, state, last_event),
        do:
          HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResource.__maybe_save_snapshot__(
            id,
            state,
            last_event,
            __MODULE__
          )

      defp resource_type_from_module(module),
        do:
          HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResource.__resource_type_from_module__(
            module
          )
    end
  end

  # Helper to rebuild state from events
  def rebuild_from_events(events, initial_state, apply_event_fn) do
    Enum.reduce(events, initial_state, fn event, acc -> apply_event_fn.(event, acc) end)
  end

  @doc """
  Rebuilds resource state from a sequence of events.

  ## Parameters

  * `events` - List of events to apply
  * `initial_state` - Starting state to build from
  """
  def __get_resource__(id, module) do
    resource_type = get_resource_type(module)

    with {:ok, events} <- EventStore.get_events_for_resource(resource_type, id) do
      initial_state = module.initial_state()
      state = rebuild_from_events(events, initial_state, module.apply_event)
      {:ok, state}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Internal: Get a resource at a specific point in time for the event-sourced resource macro.
  """
  def __get_resource_at__(id, timestamp, module) do
    resource_type = get_resource_type(module)

    with {:ok, events} <-
           EventStore.get_events(%{
             resource_type: resource_type,
             resource_id: id,
             timestamp: %{before: timestamp},
             sort: [timestamp: :asc]
           }) do
      initial_state = module.initial_state()
      state = rebuild_from_events(events, initial_state, module.apply_event)
      {:ok, state}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Internal: Create a new event-sourced resource for the macro.
  """
  def __create_resource__(params, module) do
    id = Map.get(params, :id) || Map.get(params, "id") || Ecto.UUID.generate()
    events = module.create_events(id, params)
    metadata = %{}

    with :ok <- __publish_events__(events, metadata, module) do
      # Rebuild state from the events
      initial_state = module.initial_state()
      state = rebuild_from_events(events, initial_state, module.apply_event)
      {:ok, state}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Internal: Execute a command on a resource for the event-sourced resource macro.
  """
  def __execute_resource__(id, command, params, metadata, module) do
    with {:ok, resource} <- __get_resource__(id, module),
         events when is_list(events) <- module.execute_command(resource, command, params),
         :ok <- __publish_events__(events, metadata, module) do
      # Apply new events to the resource state
      updated_state = rebuild_from_events(events, resource, module.apply_event)
      {:ok, updated_state}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Internal: Update a resource for the event-sourced resource macro.
  """
  def __update_resource__(resource, params, metadata, module) do
    events = module.update_events(resource, params)

    with :ok <- __publish_events__(events, metadata, module) do
      updated_state = rebuild_from_events(events, resource, module.apply_event)
      {:ok, updated_state}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Internal: Delete a resource for the event-sourced resource macro.
  """
  def __delete_resource__(resource, metadata, module) do
    # Convention: update_events with a :delete param, or a dedicated delete_events/2 if needed
    events = module.update_events(resource, %{delete: true})

    with :ok <- __publish_events__(events, metadata, module) do
      deleted_state = rebuild_from_events(events, resource, module.apply_event)
      {:ok, deleted_state}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Internal: Get the event history for a resource for the event-sourced resource macro.
  """
  def __get_history__(id, opts, module) do
    resource_type = get_resource_type(module)
    criteria = Map.merge(%{resource_type: resource_type, resource_id: id}, opts)
    EventStore.get_events(criteria)
  end

  @doc """
  Internal: Create events for resource creation for the event-sourced resource macro.
  """
  def __create_events__(id, params, module) do
    module.create_events(id, params)
  end

  @doc """
  Internal: Generate events for a command for the event-sourced resource macro.
  """
  def __execute_command__(resource, command, params, module) do
    module.execute_command(resource, command, params)
  end

  @doc """
  Internal: Generate events for an update for the event-sourced resource macro.
  """
  def __update_events__(resource, params, module) do
    module.update_events(resource, params)
  end

  @doc """
  Internal: Publish events for the event-sourced resource macro.
  """
  def __publish_events__(events, metadata, module) do
    Enum.reduce_while(events, :ok, fn event, acc ->
      case HydepwnsLiveview.Events.EventBus.publish(event, metadata) do
        :ok -> {:cont, :ok}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
  end

  @doc """
  Internal: Get the latest snapshot for the event-sourced resource macro.
  """
  def __get_latest_snapshot__(id, module) do
    resource_type = get_resource_type(module)
    EventStore.get_latest_snapshot(resource_type, id)
  end

  @doc """
  Internal: Maybe save a snapshot for the event-sourced resource macro.
  """
  def __maybe_save_snapshot__(id, state, last_event, module) do
    resource_type = get_resource_type(module)
    # Count events since last snapshot
    with {:ok, count} <- EventStore.count_events_since_last_snapshot(resource_type, id) do
      if count >= module.snapshot_interval() do
        metadata = %{event_id: last_event.id, created_at: DateTime.utc_now()}
        EventStore.save_snapshot(resource_type, id, state, metadata)
      else
        :no_snapshot_needed
      end
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Internal: Get resource type from module for the event-sourced resource macro.
  """
  def __resource_type_from_module__(module) do
    module
    |> Atom.to_string()
    |> String.split(".")
    |> List.last()
    |> then(fn name -> String.replace(name, "Resource", "") end)
    |> String.downcase()
  end

  # Helper to get resource type from module
  defp get_resource_type(module) do
    if function_exported?(module, :resource_type, 0) do
      module.resource_type()
    else
      __resource_type_from_module__(module)
    end
  end

  @doc """
  Gets the current state of a resource by reconstructing it from events.

  ## Parameters
  * `resource_module` - The resource module implementing initial_state/0 and apply_event/2
  * `id` - The ID of the resource

  ## Returns
  * `{:ok, state}` - The reconstructed state
  * `{:error, reason}` - If the resource could not be reconstructed
  """
  def get_current_state(resource_module, id) do
    with {:ok, events} <- HydepwnsLiveview.Events.Core.EventStore.get_events_for_resource(resource_module.resource_type(), id) do
      state = Enum.reduce(events, resource_module.initial_state(), fn event, acc ->
        resource_module.apply_event(event, acc)
      end)
      {:ok, state}
    else
      error -> error
    end
  end
end
