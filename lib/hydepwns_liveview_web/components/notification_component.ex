defmodule HydepwnsLiveviewWeb.NotificationComponent do
  @moduledoc """
  Component for displaying notifications and alerts to users.

  This component provides a unified UI for displaying different types of notifications:

  - System alerts
  - Event processing issues
  - User-triggered notifications
  - Success/error messages

  It supports different severity levels and can be configured to auto-dismiss
  or require manual dismissal.
  """

  use HydepwnsLiveviewWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="notifications-container">
      <div id={"#{@id}-container"} class="fixed right-0 top-0 z-50 p-4 space-y-3 max-w-md w-full max-h-screen overflow-y-auto" phx-hook="NotificationsHandler" data-auto-dismiss={@auto_dismiss_ms}>
        <div :for={_notification <- @notifications}>
          {render_notification(notification, @id)}
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, assign(socket, notifications: [], auto_dismiss_ms: 5000)}
  end

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(id: assigns.id)
      |> assign(notifications: Map.get(assigns, :notifications, []))
      |> assign(auto_dismiss_ms: Map.get(assigns, :auto_dismiss_ms, 5000))

    {:ok, socket}
  end

  @impl true
  def handle_event("dismiss_notification", %{"id" => id}, socket) do
    notifications = Enum.reject(socket.assigns.notifications, &(&1.id == id))
    {:noreply, assign(socket, notifications: notifications)}
  end

  @impl true
  def handle_event("toggle_details", %{"id" => id}, socket) do
    notifications =
      Enum.map(socket.assigns.notifications, fn notification ->
        if notification.id == id do
          Map.update(notification, :show_details, true, &(!&1))
        else
          notification
        end
      end)

    {:noreply, assign(socket, notifications: notifications)}
  end

  @impl true
  def handle_event("notification_action", %{"id" => id, "action" => action_id}, socket) do
    # Find the notification and action
    notification = Enum.find(socket.assigns.notifications, &(&1.id == id))

    if notification do
      action = Enum.find(notification.actions || [], &(&1.id == action_id))

      if action && action.handler do
        # Execute the action handler
        action.handler.(notification)
      end

      # If action should dismiss the notification
      notifications =
        if action && Map.get(action, :dismiss, true) do
          Enum.reject(socket.assigns.notifications, &(&1.id == id))
        else
          socket.assigns.notifications
        end

      {:noreply, assign(socket, notifications: notifications)}
    else
      {:noreply, socket}
    end
  end

  # Add a notification to the list
  def add_notification(notifications, notification) do
    # Ensure notification has an ID
    notification = Map.put_new_lazy(notification, :id, &generate_id/0)

    # Add notification to the list (newest first)
    [notification | notifications]
  end

  # Helper functions

  defp generate_id do
    :crypto.strong_rand_bytes(10) |> Base.encode16(case: :lower)
  end
end
