defmodule HydepwnsLiveview.Events.Handlers.LiveEventHandler do
  @moduledoc """
  Handles event subscriptions and updates in LiveView.

  This module provides functionality to:
  - Subscribe LiveView processes to events
  - Handle event notifications and update UI components
  - Manage event-driven real-time updates
  """

  alias HydepwnsLiveview.Events.EventBus

  @doc """
  Subscribes to events for a specific resource.

  ## Parameters
  * `event_types` - List of event types to subscribe to, or :all for all events
  * `resource_type` - The type of resource to subscribe to
  * `resource_id` - The ID of the resource to subscribe to

  ## Returns
  * `:ok` - Successfully subscribed
  * `{:error, reason}` - Failed to subscribe
  """
  def subscribe(event_types, resource_type, resource_id) do
    GenServer.call(__MODULE__, {:subscribe, self(), event_types, resource_type, resource_id})
  end

  @doc """
  Unsubscribes the current LiveView from events.

  ## Returns
  * `:ok` - The unsubscription was successful
  * `{:error, reason}` - Failed to unsubscribe
  """
  def unsubscribe(event_types \\ :all) do
    EventBus.unsubscribe(self(), event_types)
  end

  @doc """
  Handles an event in a LiveView.

  ## Parameters
  * `event` - The event to handle
  * `socket` - The LiveView socket
  * `handlers` - Map of event type patterns to handler functions
  * `default_handler` - Optional function to handle unmatched events

  ## Returns
  * Updated socket
  """
  def handle_event(event, socket, handlers, default_handler \\ nil) do
    # Find a matching handler
    handler = find_matching_handler(event.type, handlers)

    if handler do
      # Call the handler with the event and socket
      handler.(event, socket)
    else
      # Use default handler if provided
      if default_handler do
        default_handler.(event, socket)
      else
        # No handler found, return unchanged socket
        socket
      end
    end
  end

  @doc """
  Creates a LiveView function component that updates based on events.

  This is a helper function to create components that update in response to events.

  ## Parameters
  * `name` - The name of the component
  * `render_fn` - Function to render the component
  * `handle_event_fn` - Function to handle events
  * `assigns_fn` - Function to initialize assigns

  ## Returns
  * Function component definition
  """
  defmacro live_event_component(name, render_fn, handle_event_fn, assigns_fn \\ nil) do
    quote do
      def unquote(name)(assigns) do
        # Initialize component assigns
        assigns =
          if unquote(assigns_fn) != nil do
            unquote(assigns_fn).(assigns)
          else
            assigns
          end

        # Subscribe to events
        if connected?(assigns.socket) do
          event_types = Map.get(assigns, :event_types, :all)
          resource_type = Map.get(assigns, :resource_type)
          resource_id = Map.get(assigns, :resource_id)

          HydepwnsLiveview.Events.Handlers.LiveEventHandler.subscribe(
            event_types,
            resource_type,
            resource_id
          )
        end

        # Render the component
        unquote(render_fn).(assigns)
      end

      # Handle events from the event bus
      def handle_info({:event, event}, socket) do
        socket = unquote(handle_event_fn).(event, socket)
        {:noreply, socket}
      end
    end
  end

  @doc """
  Creates a hook module that can be used with `assign/3` to create event-reactive assigns.

  This creates a special assign that will automatically update when events are received.

  ## Parameters
  * `resource_type` - The resource type to subscribe to
  * `resource_id` - The resource ID to subscribe to
  * `event_types` - List of event types to subscribe to
  * `handler_fn` - Function to handle the event and update the assign value

  ## Returns
  * Event-reactive assign hook module
  """
  defmacro event_reactive_assign(resource_type, resource_id, event_types, handler_fn) do
    quote do
      defmodule EventReactiveAssign do
        @moduledoc """
        A dynamically generated module that handles event-reactive assigns.
        
        This module subscribes to specified events and updates data when events are received.
        It's used internally by the event_reactive_assign macro to create reactive assign hooks.
        """
        def init(data) do
          # Subscribe to events
          HydepwnsLiveview.Events.Handlers.LiveEventHandler.subscribe(
            unquote(event_types),
            unquote(resource_type),
            unquote(resource_id)
          )

          data
        end

        def handle_event(event, data) do
          unquote(handler_fn).(event, data)
        end
      end

      EventReactiveAssign
    end
  end

  # Private functions

  # Builds a filter function for event subscription
  defp build_filter(:all, nil, nil) do
    fn _ -> true end
  end

  defp build_filter(:all, resource_type, nil) do
    fn event -> event.resource_type == resource_type end
  end

  defp build_filter(:all, resource_type, resource_id) do
    fn event ->
      event.resource_type == resource_type && event.resource_id == resource_id
    end
  end

  defp build_filter(event_types, nil, nil) when is_list(event_types) do
    fn event -> Enum.member?(event_types, event.type) end
  end

  defp build_filter(event_types, resource_type, nil) when is_list(event_types) do
    fn event ->
      Enum.member?(event_types, event.type) && event.resource_type == resource_type
    end
  end

  defp build_filter(event_types, resource_type, resource_id) when is_list(event_types) do
    fn event ->
      Enum.member?(event_types, event.type) &&
        event.resource_type == resource_type &&
        event.resource_id == resource_id
    end
  end

  defp find_matching_handler(event_type, handlers) do
    Enum.find_value(handlers, fn {pattern, handler} ->
      if matches_pattern?(event_type, pattern), do: handler
    end)
  end

  defp matches_pattern?(event_type, pattern) when is_binary(pattern) do
    event_type == pattern
  end

  defp matches_pattern?(event_type, pattern) when is_list(pattern) do
    Enum.any?(pattern, &matches_pattern?(event_type, &1))
  end

  defp matches_pattern?(event_type, pattern) when is_function(pattern, 1) do
    pattern.(event_type)
  end

  defp matches_pattern?(event_type, {prefix, :*}) when is_binary(prefix) do
    String.starts_with?(event_type, prefix)
  end

  defp matches_pattern?(_event_type, _pattern) do
    false
  end
end
