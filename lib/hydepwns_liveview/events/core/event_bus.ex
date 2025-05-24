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
  alias HydepwnsLiveview.Events.Core.EventStore

  @doc """
  Starts the EventBus process.
  """
  @spec start_link(Keyword.t()) :: GenServer.on_start()
  def start_link(opts \\ []) do
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
  def publish(%Event{} = event, opts \\ []) do
    store? = Keyword.get(opts, :store, true)

    # Store the event if requested
    if store? do
      case EventStore.store_event(event) do
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

  @doc """
  Subscribes to events.

  ## Parameters

  * `subscriber` - The process to receive events (pid or registered name)
  * `event_types` - List of event types to subscribe to, or :all for all events

  ## Returns

  * `:ok` - The subscription was successful
  """
  @spec subscribe(pid() | atom(), [atom()] | :all) :: :ok
  def subscribe(subscriber, event_types \\ :all) do
    GenServer.cast(__MODULE__, {:subscribe, subscriber, event_types})
    :ok
  end

  @doc """
  Unsubscribes from events.

  ## Parameters

  * `subscriber` - The process to unsubscribe
  * `event_types` - List of event types to unsubscribe from, or :all for all events

  ## Returns

  * `:ok` - The unsubscription was successful
  """
  @spec unsubscribe(pid() | atom(), [atom()] | :all) :: :ok
  def unsubscribe(subscriber, event_types \\ :all) do
    GenServer.cast(__MODULE__, {:unsubscribe, subscriber, event_types})
    :ok
  end

  @doc """
  Lists all current subscribers.

  ## Returns

  * `{:ok, subscribers}` - Map of event types to lists of subscribers
  """
  @spec list_subscribers() :: {:ok, %{optional(atom()) => [pid()]}}
  def list_subscribers do
    GenServer.call(__MODULE__, :list_subscribers)
  end

  # Server callbacks

  @impl true
  def init(_opts) do
    # Initialize the state with empty subscribers
    state = %{
      # Map of event_type => [subscribers]
      subscribers: %{},
      # Map of pid => [event_types]
      subscribers_by_pid: %{},
      event_counter: 0
    }

    {:ok, state}
  end

  @impl true
  def handle_cast({:publish, event}, state) do
    # Increment the event counter
    state = %{state | event_counter: state.event_counter + 1}

    # Find subscribers interested in this event
    subscribers = find_interested_subscribers(event.type, state.subscribers)

    # Deliver the event to each subscriber
    Enum.each(subscribers, fn subscriber ->
      send_event(subscriber, event)
    end)

    # Log the event publication
    Logger.debug(
      "Published event #{event.id} of type #{event.type} to #{length(subscribers)} subscribers"
    )

    {:noreply, state}
  end

  @impl true
  def handle_cast({:subscribe, subscriber, event_types}, state) do
    # Convert subscriber to pid if it's a name
    subscriber_pid = get_pid(subscriber)

    # Monitor the subscriber
    Process.monitor(subscriber_pid)

    # Update the state with the new subscription
    state = add_subscription(state, subscriber_pid, event_types)

    # Log the subscription
    Logger.debug("Process #{inspect(subscriber_pid)} subscribed to #{inspect(event_types)}")

    {:noreply, state}
  end

  @impl true
  def handle_cast({:unsubscribe, subscriber, event_types}, state) do
    # Convert subscriber to pid if it's a name
    subscriber_pid = get_pid(subscriber)

    # Update the state by removing the subscription
    state = remove_subscription(state, subscriber_pid, event_types)

    # Log the unsubscription
    Logger.debug("Process #{inspect(subscriber_pid)} unsubscribed from #{inspect(event_types)}")

    {:noreply, state}
  end

  @impl true
  def handle_call(:list_subscribers, _from, state) do
    {:reply, {:ok, state.subscribers}, state}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    # Subscriber process has terminated, remove all its subscriptions
    state = remove_subscription(state, pid, :all)

    # Log the removal
    Logger.debug("Removed subscriptions for terminated process #{inspect(pid)}")

    {:noreply, state}
  end

  # Private functions

  # Finds subscribers interested in a specific event type
  defp find_interested_subscribers(event_type, subscribers) do
    # Get subscribers specifically interested in this event type
    specific_subscribers = Map.get(subscribers, event_type, [])

    # Get subscribers interested in all events
    all_subscribers = Map.get(subscribers, :all, [])

    # Combine and deduplicate
    (specific_subscribers ++ all_subscribers)
    |> Enum.uniq()
  end

  # Sends an event to a subscriber
  defp send_event(subscriber, event) do
    try do
      send(subscriber, {:event, event})
    rescue
      e ->
        Logger.error("Error sending event to subscriber #{inspect(subscriber)}: #{inspect(e)}")
    end
  end

  # Adds a subscription to the state
  defp add_subscription(state, subscriber_pid, :all) do
    # Add to the :all event type
    subscribers =
      Map.update(state.subscribers, :all, [subscriber_pid], fn subs ->
        [subscriber_pid | subs]
        |> Enum.uniq()
      end)

    # Update the reverse mapping
    subscribers_by_pid = Map.put(state.subscribers_by_pid, subscriber_pid, [:all])

    %{state | subscribers: subscribers, subscribers_by_pid: subscribers_by_pid}
  end

  defp add_subscription(state, subscriber_pid, event_types) when is_list(event_types) do
    # Add to each event type
    subscribers =
      Enum.reduce(event_types, state.subscribers, fn event_type, acc ->
        Map.update(acc, event_type, [subscriber_pid], fn subs ->
          [subscriber_pid | subs]
          |> Enum.uniq()
        end)
      end)

    # Update the reverse mapping
    subscribers_by_pid =
      Map.update(state.subscribers_by_pid, subscriber_pid, event_types, fn types ->
        (types ++ event_types)
        |> Enum.uniq()
      end)

    %{state | subscribers: subscribers, subscribers_by_pid: subscribers_by_pid}
  end

  defp add_subscription(state, subscriber_pid, event_type) do
    add_subscription(state, subscriber_pid, [event_type])
  end

  # Removes a subscription from the state
  defp remove_subscription(state, subscriber_pid, :all) do
    # Get all event types this subscriber is subscribed to
    event_types = Map.get(state.subscribers_by_pid, subscriber_pid, [])

    # Remove from each event type
    subscribers =
      Enum.reduce(event_types, state.subscribers, fn
        :all, acc ->
          Map.update(acc, :all, [], fn subs -> Enum.reject(subs, &(&1 == subscriber_pid)) end)

        event_type, acc ->
          Map.update(acc, event_type, [], fn subs ->
            Enum.reject(subs, &(&1 == subscriber_pid))
          end)
      end)

    # Remove from the reverse mapping
    subscribers_by_pid = Map.delete(state.subscribers_by_pid, subscriber_pid)

    %{state | subscribers: subscribers, subscribers_by_pid: subscribers_by_pid}
  end

  defp remove_subscription(state, subscriber_pid, event_types) when is_list(event_types) do
    # Remove from each event type
    subscribers =
      Enum.reduce(event_types, state.subscribers, fn event_type, acc ->
        Map.update(acc, event_type, [], fn subs -> Enum.reject(subs, &(&1 == subscriber_pid)) end)
      end)

    # Update the reverse mapping
    subscribers_by_pid =
      Map.update(state.subscribers_by_pid, subscriber_pid, [], fn types ->
        Enum.reject(types, &(&1 in event_types))
      end)

    # If no subscriptions left, remove the entry
    subscribers_by_pid =
      if Enum.empty?(Map.get(subscribers_by_pid, subscriber_pid, [])) do
        Map.delete(subscribers_by_pid, subscriber_pid)
      else
        subscribers_by_pid
      end

    %{state | subscribers: subscribers, subscribers_by_pid: subscribers_by_pid}
  end

  defp remove_subscription(state, subscriber_pid, event_type) do
    remove_subscription(state, subscriber_pid, [event_type])
  end

  # Converts a name to a pid if needed
  defp get_pid(name) when is_atom(name) do
    case Process.whereis(name) do
      nil -> raise ArgumentError, "No process registered with name: #{name}"
      pid -> pid
    end
  end

  defp get_pid(pid) when is_pid(pid), do: pid
end
