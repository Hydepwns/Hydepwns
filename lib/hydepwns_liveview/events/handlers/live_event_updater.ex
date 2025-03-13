defmodule HydepwnsLiveview.Events.Handlers.LiveEventUpdater do
  @moduledoc """
  Provides functionality for event-driven UI updates in LiveView.

  This module enhances LiveView with event-driven capabilities, including:
  - Real-time UI updates in response to resource events
  - Optimistic UI updates with rollback capabilities
  - Event-based subscriptions for LiveView components
  - Efficient state synchronization based on events
  """

  alias HydepwnsLiveview.Events.Core.Event
  alias HydepwnsLiveview.Events.Core.EventBus
  alias HydepwnsLiveview.Events.LiveEventHandler
  import Phoenix.Component
  import Phoenix.LiveView

  @doc """
  Creates a LiveComponent that updates based on events.

  This macro defines a LiveComponent that automatically subscribes to
  events for a specific resource and updates when events occur.

  ## Parameters
  * `name` - The name of the component
  * `opts` - Options for the component

  ## Example

  ```elixir
  # Define an event-driven component
  live_event_component :user_card do
    # Component implementation
  end

  # Use the component in a LiveView
  def render(assigns) do
    ~H\"\"\"
    <.user_card resource_type="user" resource_id={@user.id}>
      <div class="user-card">
        <h3><%= @resource.name %></h3>
        <p><%= @resource.email %></p>
      </div>
    </.user_card>
    \"\"\"
  end
  ```
  """
  defmacro live_event_component(name, opts \\ [], do_block) do
    quote do
      @doc """
      LiveComponent that updates based on events.
      """
      def unquote(name)(assigns) do
        assigns =
          assign_new(assigns, :id, fn -> "#{unquote(to_string(name))}-#{assigns.resource_id}" end)

        if connected?(assigns) do
          resource_type = assigns.resource_type
          resource_id = assigns.resource_id
          event_types = Map.get(assigns, :event_types, :all)

          # Subscribe to events for this resource
          HydepwnsLiveview.Events.LiveEventHandler.subscribe(
            event_types,
            resource_type,
            resource_id
          )
        end

        # Render the component
        ~H"""
        <div id={@id} phx-hook="EventDrivenComponent" class="event-driven-component">
          {render_slot(@inner_block, @resource)}
        </div>
        """
      end

      # Handle event updates
      def handle_info({:event, event}, socket) do
        # Update the resource based on the event
        socket = update_resource_from_event(socket, event)

        # Trigger component update
        send_update(unquote(name), id: socket.assigns.id)

        {:noreply, socket}
      end

      # Default implementation of update_resource_from_event
      # This can be overridden in the component
      defp update_resource_from_event(socket, event) do
        resource_key = socket.assigns.resource_key || :resource
        resource = socket.assigns[resource_key]

        # Default implementation just updates the resource with event data
        # Components should override this to implement specific logic
        updated_resource = apply_event_to_resource(resource, event)

        assign(socket, resource_key, updated_resource)
      end

      # Default implementation of apply_event_to_resource
      # This should be overridden in most cases
      defp apply_event_to_resource(resource, event) do
        Map.merge(resource, event.data)
      end

      # Allow components to override the above functions
      unquote(do_block)
    end
  end

  @doc """
  Creates optimistic UI updates for an event.

  This function allows LiveViews to update their UI immediately in response
  to user actions, before waiting for server confirmation.

  ## Parameters
  * `socket` - The LiveView socket
  * `resource_key` - The resource key in assigns
  * `updates` - The updates to apply optimistically
  * `event_type` - The event type to generate

  ## Returns
  * Updated socket with optimistic updates
  """
  def optimistic_update(socket, resource_key, updates, event_type) do
    # Get the current resource
    resource = Map.get(socket.assigns, resource_key)

    # Apply optimistic update
    updated_resource = Map.merge(resource, updates)

    # Store original resource for potential rollback
    pending_updates = Map.get(socket.assigns, :pending_updates, %{})
    pending_updates = Map.put(pending_updates, resource_key, resource)

    # Update socket with optimistic changes
    socket
    |> assign(resource_key, updated_resource)
    |> assign(:pending_updates, pending_updates)
    |> assign(:optimistic_updates, true)
  end

  @doc """
  Rolls back an optimistic update if the operation fails.

  ## Parameters
  * `socket` - The LiveView socket
  * `resource_key` - The resource key in assigns

  ## Returns
  * Socket with rolled back state
  """
  def rollback_optimistic_update(socket, resource_key) do
    # Get the original resource state
    pending_updates = Map.get(socket.assigns, :pending_updates, %{})
    original_resource = Map.get(pending_updates, resource_key)

    if original_resource do
      # Remove from pending updates
      pending_updates = Map.delete(pending_updates, resource_key)

      # Restore original state
      socket
      |> assign(resource_key, original_resource)
      |> assign(:pending_updates, pending_updates)
    else
      socket
    end
  end

  @doc """
  Updates LiveView assigns based on received events.

  This function is meant to be called from the LiveView's handle_info
  when an event is received.

  ## Parameters
  * `socket` - The LiveView socket
  * `event` - The received event
  * `opts` - Options for handling the event

  ## Returns
  * Updated socket with changes applied from event
  """
  def handle_event_update(socket, %Event{} = event, opts \\ []) do
    resource_type = event.resource_type
    resource_key = opts[:resource_key] || String.to_atom(resource_type)

    # Check if we're tracking this resource
    if Map.has_key?(socket.assigns, resource_key) do
      resource = socket.assigns[resource_key]

      # Only update if the event is for this specific resource
      if resource.id == event.resource_id do
        # Get the update function - either a provided one or a default
        update_fn =
          opts[:update_fn] ||
            fn resource, event ->
              # Default implementation merges event data into resource
              Map.merge(resource, event.data)
            end

        # Apply the update
        updated_resource = update_fn.(resource, event)

        # Update socket
        assign(socket, resource_key, updated_resource)
      else
        socket
      end
    else
      socket
    end
  end

  @doc """
  Subscribes a LiveView to events for multiple resources.

  This is useful when a LiveView needs to track updates to many
  resources at once.

  ## Parameters
  * `event_types` - List of event types to subscribe to, or `:all`
  * `resource_subscriptions` - List of {resource_type, resource_id} tuples

  ## Returns
  * `:ok` - Subscriptions were created
  * `{:error, reason}` - Failed to create subscriptions
  """
  def subscribe_to_resources(event_types \\ :all, resource_subscriptions) do
    Enum.each(resource_subscriptions, fn {resource_type, resource_id} ->
      LiveEventHandler.subscribe(event_types, resource_type, resource_id)
    end)

    :ok
  end

  @doc """
  Creates a Phoenix hook for adding JavaScript event handling.

  This function returns JavaScript that can be used with Phoenix's
  phx-hook attribute to enhance event-driven components.

  ## Returns
  * JavaScript string for the hook
  """
  def event_driven_component_hook_js do
    """
    const EventDrivenComponent = {
      mounted() {
        // Set up any client-side event handling
        this.handleEvent("resource_updated", ({ resource }) => {
          // Update component with new resource data
          this.updateComponent(resource);
        });
        
        // Listen for optimistic updates
        this.handleEvent("optimistic_update", ({ updates }) => {
          this.applyOptimisticUpdates(updates);
        });
        
        // Listen for update rollbacks
        this.handleEvent("rollback_update", () => {
          this.rollbackOptimisticUpdates();
        });
      },
      
      updateComponent(resource) {
        // This could use morphdom or other methods to efficiently update the DOM
        // For now, we'll let the server handle this via the standard LiveView update
      },
      
      applyOptimisticUpdates(updates) {
        // Apply immediate UI updates before server confirmation
        for (const [selector, content] of Object.entries(updates)) {
          const element = this.el.querySelector(selector);
          if (element) {
            element.innerHTML = content;
          }
        }
        
        // Add optimistic update styling
        this.el.classList.add("optimistic-update");
      },
      
      rollbackOptimisticUpdates() {
        // Remove optimistic update styling
        this.el.classList.remove("optimistic-update");
        
        // Let the server re-render the component
      }
    };

    window.EventDrivenComponent = EventDrivenComponent;
    """
  end
end
