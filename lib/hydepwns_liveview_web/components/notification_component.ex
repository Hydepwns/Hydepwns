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
        <div :for={notification <- @notifications}>
          {render_notification(notification, @id)}
        </div>
      </div>
    </div>
    """
  end

  defp render_notification(notification, base_id) do
    assigns = %{notification: notification, base_id: base_id, myself: self()}

    ~H"""
    <div id={"#{@base_id}-notification-#{@notification.id}"} class={"notification-item rounded-lg shadow-md p-4 transform transition-all duration-300 ease-in-out #{notification_color(@notification.level)}"} role="alert" phx-target={@myself} phx-click="dismiss_notification" phx-value-id={@notification.id}>
      <div class="flex items-start space-x-3">
        <div class="flex-shrink-0 mt-0.5">
          {render_icon(@notification.level)}
        </div>
        <div class="flex-1 overflow-hidden">
          <div class="flex items-center justify-between">
            <p class="text-sm font-medium truncate">
              {@notification.title}
            </p>
            <div class="ml-3 flex-shrink-0 flex">
              <p class="text-xs text-gray-500">
                {@notification.timestamp}
              </p>
              <button type="button" class="ml-2 text-gray-400 hover:text-gray-500" phx-target={@myself} phx-click="dismiss_notification" phx-value-id={@notification.id}>
                <span class="sr-only">Close</span>
                <svg class="h-4 w-4" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
                  <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
                </svg>
              </button>
            </div>
          </div>
          <p class="mt-1 text-sm text-gray-600 whitespace-pre-wrap break-words">
            {@notification.message}
          </p>
          <div :if={@notification.actions && length(@notification.actions) > 0} class="mt-3 flex space-x-3">
            <button
              :for={action <- @notification.actions}
              type="button"
              class={"inline-flex items-center px-3 py-1.5 border border-transparent text-xs font-medium rounded-md shadow-sm #{action_button_color(action.style)} focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"}
              phx-click={action.event}
              phx-value-id={@notification.id}
              phx-target={@myself}
            >
              {action.label}
            </button>
          </div>
          <div :if={@notification.progress} class="mt-2">
            <div class="mt-2">
              <div class="bg-gray-200 rounded-full overflow-hidden">
                <div class={"h-2 rounded-full #{progress_color(@notification.level)}"} style={"width: #{@notification.progress}%"}></div>
              </div>
              <p class="mt-1 text-xs text-gray-500 text-right">
                {@notification.progress}%
              </p>
            </div>
          </div>
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

  defp notification_color(level) do
    case level do
      :critical -> "bg-red-100 dark:bg-red-900 dark:bg-opacity-30"
      :warning -> "bg-yellow-100 dark:bg-yellow-900 dark:bg-opacity-30"
      :info -> "bg-blue-100 dark:bg-blue-900 dark:bg-opacity-30"
      :success -> "bg-green-100 dark:bg-green-900 dark:bg-opacity-30"
      _ -> "bg-gray-100 dark:bg-gray-800"
    end
  end

  defp progress_color(level) do
    case level do
      :critical -> "bg-red-500"
      :warning -> "bg-yellow-500"
      :info -> "bg-blue-500"
      :success -> "bg-green-500"
      _ -> "bg-gray-500"
    end
  end

  defp action_button_color(style) do
    case style do
      :primary -> "bg-indigo-600 hover:bg-indigo-700 text-white"
      :secondary -> "bg-gray-200 hover:bg-gray-300 text-gray-700"
      :danger -> "bg-red-600 hover:bg-red-700 text-white"
      :success -> "bg-green-600 hover:bg-green-700 text-white"
      :warning -> "bg-yellow-500 hover:bg-yellow-600 text-white"
      _ -> "bg-gray-200 hover:bg-gray-300 text-gray-700"
    end
  end

  defp render_icon(level) do
    assigns = %{level: level}

    ~H"""
    <svg :if={@level == :critical} class="h-5 w-5 text-red-500" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
      <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
    </svg>
    <svg :if={@level == :warning} class="h-5 w-5 text-yellow-500" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
      <path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
    </svg>
    <svg :if={@level == :info} class="h-5 w-5 text-blue-500" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
      <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd" />
    </svg>
    <svg :if={@level == :success} class="h-5 w-5 text-green-500" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
      <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
    </svg>
    <svg :if={!Enum.member?([:critical, :warning, :info, :success], @level)} class="h-5 w-5 text-gray-500" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
      <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd" />
    </svg>
    """
  end

  defp format_notification_type(type) do
    type
    |> to_string()
    |> String.replace("_", " ")
    |> String.capitalize()
  end

  defp format_timestamp(timestamp) do
    case timestamp do
      %DateTime{} ->
        Calendar.strftime(timestamp, "%b %d, %H:%M")

      %NaiveDateTime{} ->
        Calendar.strftime(timestamp, "%b %d, %H:%M")

      timestamp when is_binary(timestamp) ->
        timestamp

      _ ->
        ""
    end
  end

  defp show_details?(notification) do
    Map.has_key?(notification, :details) && notification.details != nil
  end

  defp action_button_class(style) do
    case style do
      :primary -> "bg-blue-600 hover:bg-blue-700 text-white"
      :secondary -> "bg-gray-200 hover:bg-gray-300 text-gray-700"
      :danger -> "bg-red-600 hover:bg-red-700 text-white"
      _ -> "bg-gray-200 hover:bg-gray-300 text-gray-700"
    end
  end
end
