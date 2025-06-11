defmodule HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResource do
  @moduledoc """
  Provides macros and functions for implementing event-sourced resources.
  """

  alias HydepwnsLiveview.Events.EventStore
  alias HydepwnsLiveview.Events.Event

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

      def get(id) do
        HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResource.__get_resource__(
          __MODULE__,
          id
        )
      end

      def get_at(id, timestamp) do
        HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResource.__get_resource_at__(
          __MODULE__,
          id,
          timestamp
        )
      end

      def create(params) do
        HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResource.__create_resource__(
          __MODULE__,
          params
        )
      end

      def execute(id, command, params \\ %{}, metadata \\ %{}) do
        HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResource.__execute_resource__(
          __MODULE__,
          id,
          command,
          params,
          metadata
        )
      end

      def get_history(id, opts \\ %{}) do
        HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResource.__get_history__(
          __MODULE__,
          id,
          opts
        )
      end

      def delete(id, metadata \\ %{}) do
        HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResource.__delete_resource__(
          __MODULE__,
          id,
          metadata
        )
      end

      def update(id, params, metadata \\ %{}) do
        HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResource.__update_resource__(
          __MODULE__,
          id,
          params,
          metadata
        )
      end
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
  def rebuild_from_events(events, initial_state, apply_event_fn) do
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

  def __get_resource__(module, id) do
    with {:ok, events} <- EventStore.get_events_for_resource(module.resource_type(), id),
         initial_state = module.initial_state() do
      state = rebuild_from_events(events, initial_state, &module.apply_event/2)
      {:ok, state}
    end
  end

  def __get_resource_at__(module, id, timestamp) do
    with {:ok, events} <- EventStore.get_events_for_resource_at(module.resource_type(), id, timestamp),
         initial_state = module.initial_state() do
      state = rebuild_from_events(events, initial_state, &module.apply_event/2)
      {:ok, state}
    end
  end

  def __create_resource__(module, params) do
    with {:ok, events} <- module.create_events(params),
         initial_state = module.initial_state() do
      state = rebuild_from_events(events, initial_state, &module.apply_event/2)
      {:ok, state}
    end
  end

  def __execute_resource__(module, id, command, params, metadata) do
    with {:ok, resource} <- __get_resource__(module, id),
         events when is_list(events) <- module.execute_command(resource, command, params),
         :ok <- __publish_events__(events, metadata, module) do
      updated_state = rebuild_from_events(events, resource, &module.apply_event/2)
      {:ok, updated_state}
    end
  end

  def __get_history__(module, id, opts) do
    resource_type = module.resource_type()
    criteria = Map.merge(%{resource_type: resource_type, resource_id: id}, opts)
    EventStore.get_events(criteria)
  end

  def __create_events__(module, id, params) do
    module.create_events(id, params)
  end

  defp __publish_events__(events, metadata, _module) do
    Enum.each(events, fn event ->
      EventStore.store_event(event, metadata)
    end)
    :ok
  end
end
