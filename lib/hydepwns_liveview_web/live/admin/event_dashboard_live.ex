defmodule HydepwnsLiveviewWeb.Admin.EventDashboardLive do
  @moduledoc """
  LiveView dashboard for monitoring event system performance.

  Provides real-time visualization of:
  - Event processing rates and times
  - Queue sizes and backpressure status
  - Error rates and bottlenecks
  - Historical performance trends
  """

  use HydepwnsLiveviewWeb, :live_view

  alias HydepwnsLiveview.Events.Core.Event

  # 5 seconds
  @refresh_interval 5000

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    default_theme = HydepwnsLiveview.ThemeSystem.ensure_default_theme()
    theme_class = "#{default_theme.mode}-theme"
    if connected?(socket) do
      # Start auto-refresh timer
      Process.send_after(self(), :refresh_metrics, @refresh_interval)

      # Subscribe to notification topic for real-time updates
      Phoenix.PubSub.subscribe(HydepwnsLiveview.PubSub, "admin_notifications")

      # Get initial metrics
      case HydepwnsLiveview.Events.Core.EventMonitor.get_metrics() do
        {:ok, metrics} ->
          socket =
            socket
            |> assign(:metrics, metrics)
            |> assign(:error, nil)
            |> assign(:refresh_interval, @refresh_interval)
            |> assign(:theme_class, theme_class)

          # Set up alerting system - auto-refresh every minute
          HydepwnsLiveview.Events.Core.EventMonitor.setup_alerting(
            notification_channels: [:in_app, :log],
            interval_ms: 60_000,
            lookback_seconds: 300,
            recipients: :admins_only
          )

          # Initial notifications state
          _notifications = []

          socket

        {:error, reason} ->
          assign(socket, :error, "Failed to load metrics: #{inspect(reason)}") |> assign(:theme_class, theme_class)
      end
    else
      assign(socket, :metrics, nil) |> assign(:theme_class, theme_class)
    end
  end

  @impl Phoenix.LiveView
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Event Dashboard")
    |> assign(:events, HydepwnsLiveview.Events.list_events())
    |> assign(:upcoming_events, HydepwnsLiveview.Events.list_upcoming_events())
    |> assign(:past_events, HydepwnsLiveview.Events.list_past_events())
    |> assign(:event_stats, HydepwnsLiveview.Events.get_event_statistics())
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Event")
    |> assign(:event, %Event{})
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Event")
    |> assign(:event, HydepwnsLiveview.Events.get_event!(id))
  end

  @impl Phoenix.LiveView
  def handle_event("delete", %{"id" => id}, socket) do
    event = HydepwnsLiveview.Events.get_event!(id)
    {:ok, _} = HydepwnsLiveview.Events.delete_event(event)

    {:noreply,
     socket
     |> assign(:events, HydepwnsLiveview.Events.list_events())
     |> assign(:upcoming_events, HydepwnsLiveview.Events.list_upcoming_events())
     |> assign(:past_events, HydepwnsLiveview.Events.list_past_events())
     |> assign(:event_stats, HydepwnsLiveview.Events.get_event_statistics())}
  end

  @impl Phoenix.LiveView
  def handle_event("toggle_refresh", _, socket) do
    auto_refresh = !socket.assigns.auto_refresh

    if auto_refresh do
      # Restart refresh timer
      Process.send_after(self(), :refresh_metrics, @refresh_interval)
    end

    {:noreply, assign(socket, auto_refresh: auto_refresh)}
  end

  @impl Phoenix.LiveView
  def handle_event("clear_notifications", _, socket) do
    {:noreply, assign(socket, notifications: [])}
  end

  @impl Phoenix.LiveView
  def handle_event("test_notification", %{"level" => level}, socket) do
    # Create a test alert with the selected level
    level_atom = String.to_existing_atom(level)

    alert = %{
      type: :test_notification,
      level: level_atom,
      message: "This is a test #{level} notification",
      summary: "Testing the notification system with a #{level} level alert",
      details: %{
        test_id: :crypto.strong_rand_bytes(4) |> Base.encode16(),
        timestamp: DateTime.utc_now(),
        test_data: %{
          level: level,
          source: "manual test"
        }
      },
      timestamp: DateTime.utc_now()
    }

    # Send the test notification
    {:ok, _} = HydepwnsLiveview.Events.Core.NotificationSystem.send_alert(alert)

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_info(:refresh_metrics, socket) do
    case HydepwnsLiveview.Events.Core.EventMonitor.get_metrics() do
      {:ok, metrics} ->
        Process.send_after(self(), :refresh_metrics, @refresh_interval)
        {:noreply, assign(socket, :metrics, metrics)}

      {:error, reason} ->
        Process.send_after(self(), :refresh_metrics, @refresh_interval)
        {:noreply, assign(socket, :error, "Failed to refresh metrics: #{inspect(reason)}")}
    end
  end

  @impl Phoenix.LiveView
  def handle_info({:notification, notification}, socket) do
    {:noreply, assign(socket, :notifications, [notification | socket.assigns.notifications])}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <div class="flex justify-between items-center mb-6">
        <h1 class="text-2xl font-bold">Event Dashboard</h1>
        <.link navigate={~p"/admin/events/new"} class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded">
          New Event
        </.link>
      </div>

      <%= if @error do %>
        <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative mb-4" role="alert">
          <span class="block sm:inline"><%= @error %></span>
        </div>
      <% end %>

      <%= if @metrics do %>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
          <div class="bg-white rounded-lg shadow p-4">
            <h3 class="text-lg font-semibold mb-2">Processing Rate</h3>
            <p class="text-2xl font-bold"><%= @metrics.processing_rate %> events/sec</p>
          </div>

          <div class="bg-white rounded-lg shadow p-4">
            <h3 class="text-lg font-semibold mb-2">Queue Size</h3>
            <p class="text-2xl font-bold"><%= @metrics.queue_size %></p>
          </div>

          <div class="bg-white rounded-lg shadow p-4">
            <h3 class="text-lg font-semibold mb-2">Error Rate</h3>
            <p class="text-2xl font-bold"><%= @metrics.error_rate %>%</p>
          </div>

          <div class="bg-white rounded-lg shadow p-4">
            <h3 class="text-lg font-semibold mb-2">Avg Processing Time</h3>
            <p class="text-2xl font-bold"><%= @metrics.avg_processing_time %>ms</p>
          </div>
        </div>

        <div class="bg-white rounded-lg shadow p-4 mb-8">
          <h3 class="text-lg font-semibold mb-4">Performance Trends</h3>
          <div class="h-64">
            <!-- Add chart component here -->
          </div>
        </div>

        <div class="bg-white rounded-lg shadow p-4">
          <h3 class="text-lg font-semibold mb-4">Recent Notifications</h3>
          <%= if @notifications do %>
            <div class="space-y-2">
              <%= for notification <- @notifications do %>
                <div class="p-2 border rounded">
                  <p class="font-medium"><%= notification.title %></p>
                  <p class="text-sm text-gray-600"><%= notification.message %></p>
                  <p class="text-xs text-gray-500"><%= notification.timestamp %></p>
                </div>
              <% end %>
            </div>
          <% else %>
            <p class="text-gray-500">No recent notifications</p>
          <% end %>
        </div>
      <% end %>

      <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <div class="bg-white shadow rounded-lg p-6">
          <h2 class="text-lg font-semibold text-gray-900 mb-2">Total Events</h2>
          <p class="text-3xl font-bold text-blue-600"><%= @event_stats.total_events %></p>
        </div>

        <div class="bg-white shadow rounded-lg p-6">
          <h2 class="text-lg font-semibold text-gray-900 mb-2">Upcoming Events</h2>
          <p class="text-3xl font-bold text-green-600"><%= @event_stats.upcoming_events %></p>
        </div>

        <div class="bg-white shadow rounded-lg p-6">
          <h2 class="text-lg font-semibold text-gray-900 mb-2">Past Events</h2>
          <p class="text-3xl font-bold text-gray-600"><%= @event_stats.past_events %></p>
        </div>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div class="bg-white shadow rounded-lg overflow-hidden">
          <div class="px-6 py-4 border-b border-gray-200">
            <h2 class="text-lg font-semibold text-gray-900">Upcoming Events</h2>
          </div>
          <div class="divide-y divide-gray-200">
            <%= for event <- @upcoming_events do %>
              <div class="px-6 py-4">
                <div class="flex justify-between items-start">
                  <div>
                    <h3 class="text-sm font-medium text-gray-900"><%= event.name %></h3>
                    <p class="mt-1 text-sm text-gray-500">
                      <%= Calendar.strftime(event.date, "%B %d, %Y at %I:%M %p") %>
                    </p>
                    <p class="mt-1 text-sm text-gray-500"><%= event.location %></p>
                  </div>
                  <div class="flex space-x-2">
                    <.link navigate={~p"/admin/events/#{event}"} class="text-indigo-600 hover:text-indigo-900">
                      View
                    </.link>
                    <.link navigate={~p"/admin/events/#{event}/edit"} class="text-indigo-600 hover:text-indigo-900">
                      Edit
                    </.link>
                  </div>
                </div>
              </div>
            <% end %>
          </div>
        </div>

        <div class="bg-white shadow rounded-lg overflow-hidden">
          <div class="px-6 py-4 border-b border-gray-200">
            <h2 class="text-lg font-semibold text-gray-900">Past Events</h2>
          </div>
          <div class="divide-y divide-gray-200">
            <%= for event <- @past_events do %>
              <div class="px-6 py-4">
                <div class="flex justify-between items-start">
                  <div>
                    <h3 class="text-sm font-medium text-gray-900"><%= event.name %></h3>
                    <p class="mt-1 text-sm text-gray-500">
                      <%= Calendar.strftime(event.date, "%B %d, %Y at %I:%M %p") %>
                    </p>
                    <p class="mt-1 text-sm text-gray-500"><%= event.location %></p>
                  </div>
                  <div class="flex space-x-2">
                    <.link navigate={~p"/admin/events/#{event}"} class="text-indigo-600 hover:text-indigo-900">
                      View
                    </.link>
                    <.link navigate={~p"/admin/events/#{event}/edit"} class="text-indigo-600 hover:text-indigo-900">
                      Edit
                    </.link>
                  </div>
                </div>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
