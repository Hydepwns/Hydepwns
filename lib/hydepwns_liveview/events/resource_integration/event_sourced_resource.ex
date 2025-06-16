defmodule HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResource do
  @moduledoc """
  Base module for event-sourced resources.

  This module provides the core functionality for event-sourced resources:
  - Event generation and application
  - State rebuilding from events
  - Command execution
  - Resource history tracking
  """

  alias HydepwnsLiveview.Events.Core.Event
  alias HydepwnsLiveview.Events.EventStore
  alias HydepwnsLiveview.Events.{EventOperations, SnapshotOperations}

  defmacro __using__(_opts) do
    quote do
      @behaviour HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResource

      def resource_type, do: __MODULE__

      def initial_state, do: %{}

      def apply_event(state, event), do: state

      def create_events(params), do: []

      def execute_command(resource, command, params), do: []

      defoverridable [
        resource_type: 0,
        initial_state: 0,
        apply_event: 2,
        create_events: 1,
        execute_command: 3
      ]

      def get(id) when is_binary(id) and byte_size(id) > 0 do
        HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResource.__get_resource__(
          __MODULE__,
          id
        )
      end
      def get(_invalid_id), do: {:error, :invalid_id}

      def get_at(id, timestamp) 
          when is_binary(id) and byte_size(id) > 0 
          and is_struct(timestamp, DateTime) do
        HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResource.__get_resource_at__(
          __MODULE__,
          id,
          timestamp
        )
      end
      def get_at(_invalid_id, _invalid_timestamp), do: {:error, :invalid_parameters}

      def create(params) when is_map(params) do
        HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResource.__create_resource__(
          __MODULE__,
          params
        )
      end
      def create(_invalid_params), do: {:error, :invalid_parameters}

      def execute(id, command, params, metadata \\ %{})
          when is_binary(id) and byte_size(id) > 0
          and is_binary(command) and byte_size(command) > 0
          and is_map(params)
          and is_map(metadata) do
        HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResource.__execute_resource__(
          __MODULE__,
          id,
          command,
          params,
          metadata
        )
      end
      def execute(_invalid_id, _invalid_command, _invalid_params, _invalid_metadata),
        do: {:error, :invalid_parameters}

      def get_history(id, opts \\ %{})
      def get_history(id, opts)
          when is_binary(id) and byte_size(id) > 0
          and is_map(opts) do
        HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResource.__get_history__(
          __MODULE__,
          id,
          opts
        )
      end
      def get_history(_invalid_id, _invalid_opts), do: {:error, :invalid_parameters}

      def delete(id, metadata \\ %{})
      def delete(id, metadata)
          when is_binary(id) and byte_size(id) > 0
          and is_map(metadata) do
        HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResource.__delete_resource__(
          __MODULE__,
          id,
          metadata
        )
      end
      def delete(_invalid_id, _invalid_metadata), do: {:error, :invalid_parameters}

      def update(id, params, metadata \\ %{})
      def update(id, params, metadata)
          when is_binary(id) and byte_size(id) > 0
          and is_map(params)
          and is_map(metadata) do
        HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResource.__update_resource__(
          __MODULE__,
          id,
          params,
          metadata
        )
      end
      def update(_invalid_id, _invalid_params, _invalid_metadata),
        do: {:error, :invalid_parameters}
    end
  end

  @callback resource_type() :: atom()
  @callback initial_state() :: map()
  @callback apply_event(map(), Event.t()) :: map()
  @callback create_events(map()) :: [Event.t()]
  @callback execute_command(map(), String.t(), map()) :: [Event.t()]

  @doc """
  Rebuilds a resource's state from a list of events.

  ## Parameters
  * `events` - List of events to apply
  * `initial_state` - The initial state to start with
  * `apply_event_fn` - Function to apply each event to the state

  ## Returns
  * The final state after applying all events
  * `{:error, reason}` if any event fails to apply
  """
  def rebuild_from_events(events, initial_state, apply_event_fn)
      when is_list(events)
      and is_map(initial_state)
      and is_function(apply_event_fn, 2) do
    try do
      Enum.reduce(events, initial_state, fn event, state ->
        apply_event_fn.(state, event)
      end)
    rescue
      e in RuntimeError ->
        {:error, e.message}
      e in FunctionClauseError ->
        {:error, "Failed to apply event: #{inspect(e)}"}
      e ->
        {:error, "Unexpected error while rebuilding state: #{inspect(e)}"}
    end
  end
  def rebuild_from_events(_invalid_events, _invalid_state, _invalid_fn),
    do: {:error, :invalid_parameters}

  def __get_resource__(module, id) when is_atom(module) and is_binary(id) and byte_size(id) > 0 do
    with {:ok, events} <- EventStore.get_events_for_resource(module.resource_type(), id) do
      initial_state = module.initial_state()
      state = rebuild_from_events(events, initial_state, &module.apply_event/2)
      {:ok, state}
    end
  end
  def __get_resource__(_invalid_module, _invalid_id), do: {:error, :invalid_parameters}

  def __get_resource_at__(module, id, timestamp)
      when is_atom(module)
      and is_binary(id)
      and byte_size(id) > 0
      and is_struct(timestamp, DateTime) do
    with {:ok, events} <- EventStore.get_events_for_resource_at(module.resource_type(), id, timestamp) do
      initial_state = module.initial_state()
      state = rebuild_from_events(events, initial_state, &module.apply_event/2)
      {:ok, state}
    end
  end
  def __get_resource_at__(_invalid_module, _invalid_id, _invalid_timestamp),
    do: {:error, :invalid_parameters}

  def __create_resource__(module, params) when is_atom(module) and is_map(params) do
    with {:ok, events} <- module.create_events(params) do
      initial_state = module.initial_state()
      state = rebuild_from_events(events, initial_state, &module.apply_event/2)
      {:ok, state}
    end
  end
  def __create_resource__(_invalid_module, _invalid_params), do: {:error, :invalid_parameters}

  def __execute_resource__(module, id, command, params, metadata)
      when is_atom(module)
      and is_binary(id)
      and byte_size(id) > 0
      and is_binary(command)
      and byte_size(command) > 0
      and is_map(params)
      and is_map(metadata) do
    with {:ok, resource} <- __get_resource__(module, id),
         events when is_list(events) <- module.execute_command(resource, command, params),
         :ok <- __publish_events__(events, metadata, module) do
      updated_state = rebuild_from_events(events, resource, &module.apply_event/2)
      {:ok, updated_state}
    end
  end
  def __execute_resource__(_invalid_module, _invalid_id, _invalid_command, _invalid_params, _invalid_metadata),
    do: {:error, :invalid_parameters}

  def __get_history__(module, id, opts)
      when is_atom(module)
      and is_binary(id)
      and byte_size(id) > 0
      and is_map(opts) do
    resource_type = module.resource_type()
    criteria = Map.merge(%{resource_type: resource_type, resource_id: id}, opts)
    EventStore.get_events(criteria)
  end
  def __get_history__(_invalid_module, _invalid_id, _invalid_opts),
    do: {:error, :invalid_parameters}

  def __create_events__(module, id, params)
      when is_atom(module)
      and is_binary(id)
      and byte_size(id) > 0
      and is_map(params) do
    module.create_events(id, params)
  end
  def __create_events__(_invalid_module, _invalid_id, _invalid_params),
    do: {:error, :invalid_parameters}

  defp __publish_events__(events, metadata, _module)
      when is_list(events)
      and is_map(metadata) do
    Enum.each(events, fn event ->
      EventStore.store_event(event, metadata)
    end)
    :ok
  end
  defp __publish_events__(_invalid_events, _invalid_metadata, _invalid_module),
    do: {:error, :invalid_parameters}

  @doc """
  Gets the current state of a resource by replaying all events.
  """
  def get_current_state(resource_type, resource_id) 
      when is_atom(resource_type) and is_binary(resource_id) and byte_size(resource_id) > 0 do
    with {:ok, events} <- EventStore.get_events_for_resource(resource_type, resource_id) do
      initial_state = initial_state()
      state = rebuild_from_events(events, initial_state, &apply_event/2)
      {:ok, state}
    end
  end
  def get_current_state(_invalid_type, _invalid_id), do: {:error, :invalid_parameters}

  @doc """
  Gets the current state of a resource at a specific point in time.
  """
  def get_current_state_at(resource_type, resource_id, timestamp) do
    case EventStore.get_events_for_resource_at(resource_type, resource_id, timestamp) do
      {:ok, events} ->
        state = Enum.reduce(events, initial_state(), fn event, state ->
          apply_event(event, state)
        end)
        {:ok, state}

      error ->
        error
    end
  end

  @doc """
  Gets the history of state changes for a resource.
  """
  def get_history(resource_type, resource_id) do
    case EventStore.get_events_for_resource(resource_type, resource_id) do
      {:ok, events} ->
        history =
          events
          |> Enum.reduce({[], initial_state()}, fn event, {history, state} ->
            new_state = apply_event(event, state)
            {[{event, new_state} | history], new_state}
          end)
          |> elem(0)
          |> Enum.reverse()

        {:ok, history}

      error ->
        error
    end
  end

  @doc """
  Gets the history of state changes for a resource up to a specific point in time.
  """
  def get_history_at(resource_type, resource_id, timestamp) do
    case EventStore.get_events_for_resource_at(resource_type, resource_id, timestamp) do
      {:ok, events} ->
        history =
          events
          |> Enum.reduce({[], initial_state()}, fn event, {history, state} ->
            new_state = apply_event(event, state)
            {[{event, new_state} | history], new_state}
          end)
          |> elem(0)
          |> Enum.reverse()

        {:ok, history}

      error ->
        error
    end
  end

  @doc """
  Creates a new resource.
  """
  def create(resource_type, resource_id, attrs) do
    event = %Event{
      type: "resource_created",
      resource_type: resource_type,
      resource_id: resource_id,
      data: attrs
    }

    store_and_apply_event(event)
  end

  defp store_and_apply_event(event) do
    case EventOperations.store_event(event) do
      {:ok, event} -> {:ok, apply_event(event, initial_state())}
      error -> error
    end
  end

  @doc """
  Updates a resource.
  """
  def update(resource_type, resource_id, attrs) do
    event = %Event{
      type: "resource_updated",
      resource_type: resource_type,
      resource_id: resource_id,
      data: attrs
    }

    store_and_apply_event(event)
  end

  @doc """
  Deletes a resource.
  """
  def delete(resource_type, resource_id) do
    event = %Event{
      type: "resource_deleted",
      resource_type: resource_type,
      resource_id: resource_id
    }

    store_and_apply_event(event)
  end

  @doc """
  Executes a command on a resource.
  """
  def execute_command(resource_type, resource_id, command) do
    case get_current_state(resource_type, resource_id) do
      {:ok, state} ->
        case validate_command(command, state) do
          :ok -> store_and_apply_command_event(resource_type, resource_id, command, state)
          {:error, reason} -> {:error, reason}
        end
      error -> error
    end
  end

  defp store_and_apply_command_event(resource_type, resource_id, command, state) do
    event = %Event{
      type: "command_executed",
      resource_type: resource_type,
      resource_id: resource_id,
      data: command
    }

    store_and_apply_event(event)
  end

  # Private functions

  defp initial_state do
    %{}
  end

  defp apply_event(event, state) do
    case event.type do
      "resource_created" ->
        Map.merge(state, event.data)

      "resource_updated" ->
        Map.merge(state, event.data)

      "resource_deleted" ->
        %{deleted: true}

      "command_executed" ->
        apply_command(event.data, state)

      _ ->
        state
    end
  end

  defp validate_command(_command, _state) do
    :ok
  end

  defp apply_command(_command, state) do
    state
  end
end

