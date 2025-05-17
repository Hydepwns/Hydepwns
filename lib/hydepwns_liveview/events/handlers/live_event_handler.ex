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
  Subscribes the current LiveView to events.

  This will subscribe the current process to events matching the given criteria.
  When events are received, they will be sent to the process as a message of the form:
  `{:event, event}`.

  ## Parameters
  * `event_types` - List of event types to subscribe to, or `:all` for all events
  * `resource_type` - Optional resource type to filter by
  * `resource_id` - Optional resource ID to filter by

  ## Returns
  * `:ok` - The subscription was successful
  * `{:error, reason}` - Failed to subscribe
  """
  def subscribe(event_types \\ :all, resource_type \\ nil, resource_id \\ nil) do
    filter = build_filter(event_types, resource_type, resource_id)
    EventBus.subscribe(self(), filter)
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
  Handles an event in a LiveView. This should be called from handle_info in the LiveView.

  ## Parameters
  * `event` - The event to handle
  * `socket` - The LiveView socket
  * `handlers` - Map of event type patterns to handler functions. 
    Each handler should take the event and socket as arguments and return the updated socket.
  * `default_handler` - Optional function to handle events that don't match any pattern

  ## Returns
  * Updated socket
  """
  def handle_event(event, socket, handlers, default_handler \\ nil) do
    # Try to find a matching handler
    handler =
      Enum.find_value(handlers, default_handler, fn {pattern, handler_fn} ->
        if event_matches_pattern?(event.type, pattern), do: handler_fn, else: nil
      end)

    case handler do
      # No handler found
      nil -> socket
      handler_fn -> handler_fn.(event, socket)
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

  # Checks if an event type matches a pattern
  defp event_matches_pattern?(event_type, pattern) when is_binary(pattern) do
    event_type == pattern
  end

  defp event_matches_pattern?(event_type, pattern) when is_list(pattern) do
    Enum.member?(pattern, event_type)
  end

  defp event_matches_pattern?(event_type, pattern) when is_function(pattern, 1) do
    pattern.(event_type)
  end

  defp event_matches_pattern?(event_type, {prefix, :*}) when is_binary(prefix) do
    String.starts_with?(event_type, prefix)
  end

  defp event_matches_pattern?(_event_type, _pattern) do
    false
  end
end
