defmodule HydepwnsLiveview.Events.Core.EventBus do
  @moduledoc """
  Central event distribution system for the Resource Event System.

  The EventBus is responsible for:
  - Publishing events to subscribers
  - Managing subscriptions
  - Routing events to appropriate handlers
  - Ensuring reliable event delivery

  It implements a publish-subscribe pattern where subscribers can
  register interest in specific event types.
  """

  use GenServer
  require Logger

  alias HydepwnsLiveview.Events.Core.Event
  alias HydepwnsLiveview.Events

  @doc """
  Starts the EventBus process.
  """
  @spec start_link(Keyword.t()) :: GenServer.on_start()
  def start_link(opts \\ []) when is_list(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Publishes an event to all interested subscribers.

  ## Parameters

  * `event` - The event to publish
  * `opts` - Options for publishing:
    * `:store` - Whether to store the event (default: true)

  ## Returns

  * `:ok` - The event was published successfully
  * `{:error, reason}` - The event could not be published
  """
  @spec publish(Event.t(), Keyword.t()) :: :ok | {:error, any()}
  def publish(%Event{} = event, opts \\ %{}) do
    GenServer.cast(__MODULE__, {:publish, event, opts})
  end

  def publish(_invalid_event, _opts), do: {:error, :invalid_event}

  @doc """
  Subscribes to events.

  ## Parameters
  * `event_types` - List of event types to subscribe to, or :all for all events

  ## Returns
  * `:ok` - Successfully subscribed
  * `{:error, reason}` - Failed to subscribe
  """
  def subscribe(event_type) do
    GenServer.call(__MODULE__, {:subscribe, event_type})
  end

  @doc """
  Unsubscribes from events.

  ## Parameters
  * `subscriber` - The process to unsubscribe (pid or registered name)
  * `event_types` - List of event types to unsubscribe from, or :all for all events

  ## Returns
  * `:ok` - Successfully unsubscribed
  * `{:error, reason}` - Failed to unsubscribe
  """
  def unsubscribe(event_type) do
    GenServer.call(__MODULE__, {:unsubscribe, event_type})
  end

  @doc """
  Gets the list of subscribers for a specific event type.

  ## Parameters

  * `event_type` - The type of event to get subscribers for

  ## Returns

  * `{:ok, subscribers}` - List of subscribers for the event type
  """
  @spec get_subscribers(String.t()) :: {:ok, [pid() | atom()]} | {:error, any()}
  def get_subscribers(event_type) when is_binary(event_type) and byte_size(event_type) > 0 do
    GenServer.call(__MODULE__, {:get_subscribers, event_type})
  end

  def get_subscribers(_invalid_type), do: {:error, :invalid_event_type}

  # GenServer callbacks

  @impl true
  def init(_opts) do
    {:ok, %{subscribers: %{}}}
  end

  @impl true
  def handle_call({:subscribe, event_type}, _from, state) do
    subscribers = Map.update(state.subscribers, event_type, [self()], &[self() | &1])
    {:reply, :ok, %{state | subscribers: subscribers}}
  end

  @impl true
  def handle_call({:unsubscribe, event_type}, _from, state) do
    subscribers = Map.update(state.subscribers, event_type, [], &List.delete(&1, self()))
    {:reply, :ok, %{state | subscribers: subscribers}}
  end

  @impl true
  def handle_call({:get_subscribers, event_type}, _from, state) do
    subscribers = get_subscribers_for_type(state, event_type)
    {:reply, {:ok, subscribers}, state}
  end

  @impl true
  def handle_call({:register_event_type, event_type}, _from, state) do
    event_types = Map.get(state, :event_types, MapSet.new())
    event_types = MapSet.put(event_types, event_type)
    {:reply, :ok, Map.put(state, :event_types, event_types)}
  end

  @impl true
  def handle_call(:list_event_types, _from, state) do
    event_types = Map.get(state, :event_types, MapSet.new())
    {:reply, MapSet.to_list(event_types), state}
  end

  @impl true
  def handle_cast({:publish, event, opts}, state) do
    event_type = event.__struct__
    subscribers = get_subscribers_for_type(state, event_type)
    notify_subscribers(subscribers, event, opts)
    {:noreply, state}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    subscribers =
      Enum.reduce(state.subscribers, %{}, fn {topic, pids}, acc ->
        Map.put(acc, topic, List.delete(pids, pid))
      end)

    {:noreply, %{state | subscribers: subscribers}}
  end

  # Private functions

  defp get_subscribers_for_type(state, event_type) do
    state.subscribers
    |> Enum.filter(fn {_subscriber, types} ->
      types == :all or event_type in types
    end)
    |> Enum.map(fn {subscriber, _types} -> subscriber end)
  end

  defp notify_subscribers(subscribers, event, opts) do
    Enum.each(subscribers, fn subscriber ->
      if is_pid(subscriber) and Process.alive?(subscriber) do
        send(subscriber, {:event, event, opts})
      end
    end)
  end

  # Event Type Registration

  def register_event_type(event_type) do
    GenServer.call(__MODULE__, {:register_event_type, event_type})
  end

  def list_event_types do
    GenServer.call(__MODULE__, :list_event_types)
  end
end
