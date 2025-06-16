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
  def publish(%Event{} = event, opts \\ []) when is_list(opts) do
    store? = Keyword.get(opts, :store, true)

    # Store the event if requested
    if store? do
      case Events.store_event(event) do
        {:ok, persisted_event} ->
          GenServer.cast(__MODULE__, {:publish, persisted_event})

        {:error, reason} = error ->
          Logger.error("Failed to store event: #{inspect(reason)}")
          error
      end
    else
      GenServer.cast(__MODULE__, {:publish, event})
    end

    :ok
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
  def subscribe(event_types \\ :all) do
    GenServer.call(__MODULE__, {:subscribe, self(), event_types})
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
  def unsubscribe(subscriber, event_types \\ :all) do
    GenServer.call(__MODULE__, {:unsubscribe, subscriber, event_types})
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
  def handle_call({:subscribe, subscriber, event_types}, _from, state) do
    new_state = update_subscribers(state, subscriber, event_types)
    {:reply, :ok, new_state}
  end

  @impl true
  def handle_call({:unsubscribe, subscriber, event_types}, _from, state) do
    new_state = remove_subscriber(state, subscriber)
    {:reply, :ok, new_state}
  end

  @impl true
  def handle_call({:get_subscribers, event_type}, _from, state) do
    subscribers = get_subscribers_for_type(state, event_type)
    {:reply, {:ok, subscribers}, state}
  end

  @impl true
  def handle_cast({:publish, event}, state) do
    subscribers = get_subscribers_for_type(state, event.type)
    notify_subscribers(subscribers, event)
    {:noreply, state}
  end

  # Private functions

  defp update_subscribers(state, subscriber, :all) do
    Map.update(state, :subscribers, %{subscriber => :all}, fn subscribers ->
      Map.put(subscribers, subscriber, :all)
    end)
  end

  defp update_subscribers(state, subscriber, event_types) when is_list(event_types) do
    Map.update(state, :subscribers, %{subscriber => event_types}, fn subscribers ->
      Map.put(subscribers, subscriber, event_types)
    end)
  end

  defp remove_subscriber(state, subscriber) do
    Map.update(state, :subscribers, %{}, fn subscribers ->
      Map.delete(subscribers, subscriber)
    end)
  end

  defp get_subscribers_for_type(state, event_type) do
    state.subscribers
    |> Enum.filter(fn {_subscriber, types} ->
      types == :all or event_type in types
    end)
    |> Enum.map(fn {subscriber, _types} -> subscriber end)
  end

  defp notify_subscribers(subscribers, event) do
    Enum.each(subscribers, fn subscriber ->
      if is_pid(subscriber) and Process.alive?(subscriber) do
        send(subscriber, {:event, event})
      end
    end)
  end
end
