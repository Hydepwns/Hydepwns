defmodule HydepwnsLiveviewWeb.Admin.EventDashboardLive do
  @moduledoc """
  LiveView dashboard for monitoring event system performance.

  Provides real-time visualization of:
  - Event processing rates and times
  - Queue sizes and backpressure status
  - Error rates and bottlenecks
  - Historical performance trends
  """

  use HydepwnsLiveviewWeb.BaseLive,
    required_assigns: [
      :page_title,
      :theme_class,
      :auto_refresh,
      :metrics,
      :error,
      :notifications
    ]

  alias HydepwnsLiveview.Events.Core.EventMonitor
  alias HydepwnsLiveview.Events.Core.NotificationSystem
  import Phoenix.Component

  alias HydepwnsLiveviewWeb.NotificationComponent

  # 5 seconds
  @refresh_interval 5000

  @impl true
  def do_mount(_params, _session, socket) do
    if connected?(socket) do
      # Start auto-refresh timer
      Process.send_after(self(), :refresh_metrics, @refresh_interval)

      # Subscribe to notification topic for real-time updates
      Phoenix.PubSub.subscribe(HydepwnsLiveview.PubSub, "admin_notifications")

      # Get initial metrics
      case EventMonitor.get_metrics() do
        {:ok, metrics} ->
          socket =
            socket
            |> assign(:metrics, metrics)
            |> assign(:error, nil)
            |> assign(:refresh_interval, @refresh_interval)

          # Set up alerting system - auto-refresh every minute
          EventMonitor.setup_alerting(
            notification_channels: [:in_app, :log],
            interval_ms: 60_000,
            lookback_seconds: 300,
            recipients: :admins_only
          )

          # Initial notifications state
          _notifications = []

          {:ok, socket}

        {:error, reason} ->
          {:ok, assign(socket, :error, "Failed to load metrics: #{inspect(reason)}")}
      end
    else
      {:ok, assign(socket, :metrics, nil)}
    end
  end

  @impl true
  def handle_params(_params, _url, socket) do
    # Process URL parameters here if needed
    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle_refresh", _, socket) do
    auto_refresh = !socket.assigns.auto_refresh

    if auto_refresh do
      # Restart refresh timer
      Process.send_after(self(), :refresh_metrics, @refresh_interval)
    end

    {:noreply, assign(socket, auto_refresh: auto_refresh)}
  end

  @impl true
  def handle_event("clear_notifications", _, socket) do
    {:noreply, assign(socket, notifications: [])}
  end

  @impl true
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
    {:ok, _} = NotificationSystem.send_alert(alert)

    {:noreply, socket}
  end

  @impl true
  def handle_info(:refresh_metrics, socket) do
    if socket.assigns.auto_refresh do
      # Get updated metrics
      case EventMonitor.get_metrics() do
        {:ok, metrics} ->
          {:noreply, assign(socket, metrics: metrics)}

        {:error, reason} ->
          {:noreply, assign(socket, :error, "Failed to refresh metrics: #{inspect(reason)}")}
      end

      # Schedule next refresh
      Process.send_after(self(), :refresh_metrics, @refresh_interval)
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:new_notification, notification}, socket) do
    # Add the new notification to the list
    notifications =
      NotificationComponent.add_notification(
        socket.assigns.notifications,
        notification
      )

    # Update socket with new notifications
    {:noreply, assign(socket, notifications: notifications)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto p-4">
      <h1 class="text-2xl font-bold mb-6">Event System Dashboard</h1>
      
    <!-- Notification Component -->
      <.live_component module={HydepwnsLiveviewWeb.NotificationComponent} id="event-dashboard-notifications" notifications={@notifications} />
      
    <!-- Controls -->
      <div class="bg-white shadow rounded-lg p-4 mb-6 flex justify-between items-center">
        <div class="flex items-center space-x-4">
          <button phx-click="toggle_refresh" class={"px-4 py-2 rounded-lg #{if @auto_refresh, do: "bg-blue-500 text-white", else: "bg-gray-200 text-gray-700"}"}>
            {if @auto_refresh, do: "Auto-Refresh On", else: "Auto-Refresh Off"}
          </button>

          <span class="text-sm text-gray-500">
            {if @metrics, do: "Last updated: #{format_time(@metrics.timestamp)}", else: "No data"}
          </span>
        </div>

        <div class="flex items-center space-x-2">
          <span class="text-sm">Test Notification:</span>
          <button phx-click="test_notification" phx-value-level="info" class="px-3 py-1 rounded-lg bg-blue-100 text-blue-800 text-sm">
            Info
          </button>
          <button phx-click="test_notification" phx-value-level="warning" class="px-3 py-1 rounded-lg bg-yellow-100 text-yellow-800 text-sm">
            Warning
          </button>
          <button phx-click="test_notification" phx-value-level="critical" class="px-3 py-1 rounded-lg bg-red-100 text-red-800 text-sm">
            Critical
          </button>
          <button phx-click="clear_notifications" class="ml-4 px-3 py-1 rounded-lg bg-gray-100 text-gray-800 text-sm">
            Clear All
          </button>
        </div>
      </div>

      <%= if @error do %>
        <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
          <p>{@error}</p>
        </div>
      <% end %>

      <%= if @metrics do %>
        <!-- Summary Cards -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
          <!-- Overall Status -->
          <div class={"p-4 rounded-lg #{backpressure_color(@metrics.backpressure.status)}"}>
            <h3 class="text-lg font-semibold mb-2">System Status</h3>
            <div class="text-2xl font-bold">{format_backpressure_status(@metrics.backpressure.status)}</div>
            <div class="text-sm mt-2">
              <%= if @metrics.backpressure.queue_pressure do %>
                <p>Queue pressure detected</p>
              <% end %>
              <%= if length(@metrics.backpressure.slow_processing_types) > 0 do %>
                <p>Slow processing: {Enum.join(@metrics.backpressure.slow_processing_types, ", ")}</p>
              <% end %>
              <%= if length(@metrics.backpressure.high_error_types) > 0 do %>
                <p>High errors: {Enum.join(@metrics.backpressure.high_error_types, ", ")}</p>
              <% end %>
            </div>
          </div>
          
    <!-- Event Rate -->
          <div class="bg-white p-4 rounded-lg shadow">
            <h3 class="text-lg font-semibold mb-2">Event Rate</h3>
            <div class="text-2xl font-bold">{format_decimal(@metrics.events_per_second)} events/sec</div>
            <div class="text-sm mt-2">
              <p>Total: {@metrics.event_count} events in last {format_time_period(@metrics.lookback_period_seconds)}</p>
            </div>
          </div>
          
    <!-- Event Types -->
          <div class="bg-white p-4 rounded-lg shadow">
            <h3 class="text-lg font-semibold mb-2">Event Types</h3>
            <div class="text-2xl font-bold">{map_size(@metrics.processing_metrics)} types</div>
            <div class="text-sm mt-2">
              <p>{Enum.map(@metrics.processing_metrics, fn {type, _} -> type end) |> Enum.join(", ")}</p>
            </div>
          </div>
        </div>
        
    <!-- Tabs for detailed metrics -->
        <div class="mb-6">
          <div class="border-b border-gray-200">
            <nav class="-mb-px flex" aria-label="Tabs">
              <button phx-click="switch_tab" phx-value-tab="processing" class="text-blue-600 py-4 px-1 text-center border-b-2 border-blue-500 font-medium text-sm flex-1">
                Processing Metrics
              </button>
              <button phx-click="switch_tab" phx-value-tab="queues" class="text-gray-500 hover:text-gray-700 py-4 px-1 text-center border-b-2 border-transparent font-medium text-sm flex-1">
                Queue Sizes
              </button>
              <button phx-click="switch_tab" phx-value-tab="errors" class="text-gray-500 hover:text-gray-700 py-4 px-1 text-center border-b-2 border-transparent font-medium text-sm flex-1">
                Error Rates
              </button>
            </nav>
          </div>
        </div>
        
    <!-- Processing Metrics Table -->
        <div class="bg-white shadow rounded-lg overflow-hidden mb-6">
          <div class="px-4 py-5 sm:px-6 border-b border-gray-200">
            <h3 class="text-lg leading-6 font-medium text-gray-900">Event Processing Metrics</h3>
            <p class="mt-1 max-w-2xl text-sm text-gray-500">Performance metrics for event processing by type</p>
          </div>
          <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200">
              <thead class="bg-gray-50">
                <tr>
                  <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Event Type
                  </th>
                  <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Avg. Time (ms)
                  </th>
                  <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Count
                  </th>
                  <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Errors
                  </th>
                  <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Status
                  </th>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-gray-200">
                <tr :for={{type, metrics} <- @metrics.processing_metrics}>
                  <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                    {type}
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {format_decimal(metrics.avg_time)}
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {metrics.count}
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {metrics.errors}
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    <span :if={metrics.avg_time > 500} class="event-status px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-red-100 text-red-800" data-test-id={"event-status-" <> to_string(type)}>
                      processed
                    </span>
                    <span :if={metrics.avg_time > 200 && metrics.avg_time <= 500} class="event-status px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-yellow-100 text-yellow-800" data-test-id={"event-status-" <> to_string(type)}>
                      processed
                    </span>
                    <span :if={metrics.avg_time <= 200} class="event-status px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800" data-test-id={"event-status-" <> to_string(type)}>
                      processed
                    </span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
        
    <!-- Queue Sizes Table -->
        <div class="bg-white shadow rounded-lg overflow-hidden mb-6">
          <div class="px-4 py-5 sm:px-6 border-b border-gray-200">
            <h3 class="text-lg leading-6 font-medium text-gray-900">Event Handler Queue Sizes</h3>
            <p class="mt-1 max-w-2xl text-sm text-gray-500">Current queue sizes for each event handler</p>
          </div>
          <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200">
              <thead class="bg-gray-50">
                <tr>
                  <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Handler
                  </th>
                  <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Queue Size
                  </th>
                  <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Status
                  </th>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-gray-200">
                <tr :for={{handler, size} <- @metrics.queue_sizes}>
                  <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                    {handler}
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {size}
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    <span :if={size > 1000} class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-red-100 text-red-800">
                      Backpressure
                    </span>
                    <span :if={size > 500 && size <= 1000} class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-yellow-100 text-yellow-800">
                      Warning
                    </span>
                    <span :if={size <= 500} class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">
                      Good
                    </span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
        
    <!-- Bottlenecks Section -->
        <div class="bg-white shadow rounded-lg overflow-hidden mb-6">
          <div class="px-4 py-5 sm:px-6 border-b border-gray-200">
            <h3 class="text-lg leading-6 font-medium text-gray-900">System Bottlenecks</h3>
            <p class="mt-1 max-w-2xl text-sm text-gray-500">
              Identified system bottlenecks based on metrics analysis
            </p>
          </div>
          <div class="px-4 py-5 sm:p-6">
            <%= if map_size(@metrics.backpressure.bottlenecks) == 0 || 
                  (length(@metrics.backpressure.bottlenecks.high_queue_handlers) == 0 && 
                  length(@metrics.backpressure.bottlenecks.slow_event_types) == 0 && 
                  length(@metrics.backpressure.bottlenecks.high_error_types) == 0) do %>
              <p class="text-sm text-gray-500">No bottlenecks detected in the system. All metrics are within normal parameters.</p>
            <% else %>
              <ul class="mt-2 space-y-2">
                <%= if length(@metrics.backpressure.bottlenecks.high_queue_handlers) > 0 do %>
                  <li class="text-sm">
                    <span class="font-medium text-red-600">High Queue Sizes:</span>
                    <span class="text-gray-700">
                      {Enum.join(@metrics.backpressure.bottlenecks.high_queue_handlers, ", ")}
                    </span>
                  </li>
                <% end %>

                <%= if length(@metrics.backpressure.bottlenecks.slow_event_types) > 0 do %>
                  <li class="text-sm">
                    <span class="font-medium text-red-600">Slow Processing:</span>
                    <span class="text-gray-700">
                      {Enum.join(@metrics.backpressure.bottlenecks.slow_event_types, ", ")}
                    </span>
                  </li>
                <% end %>

                <%= if length(@metrics.backpressure.bottlenecks.high_error_types) > 0 do %>
                  <li class="text-sm">
                    <span class="font-medium text-red-600">High Error Rates:</span>
                    <span class="text-gray-700">
                      {Enum.join(@metrics.backpressure.bottlenecks.high_error_types, ", ")}
                    </span>
                  </li>
                <% end %>
              </ul>

              <div class="mt-4 p-3 bg-red-50 rounded-md border border-red-200">
                <h4 class="text-sm font-medium text-red-800">Recommended Actions:</h4>
                <ul class="mt-2 text-sm text-red-700 list-disc list-inside">
                  <%= if length(@metrics.backpressure.bottlenecks.high_queue_handlers) > 0 do %>
                    <li>Increase handler concurrency or optimize handler performance</li>
                  <% end %>

                  <%= if length(@metrics.backpressure.bottlenecks.slow_event_types) > 0 do %>
                    <li>Optimize event processing for the identified slow event types</li>
                  <% end %>

                  <%= if length(@metrics.backpressure.bottlenecks.high_error_types) > 0 do %>
                    <li>Investigate and fix errors in the identified event types</li>
                  <% end %>
                </ul>
              </div>
            <% end %>
          </div>
        </div>
      <% else %>
        <div class="bg-white p-6 rounded-lg shadow text-center">
          <p class="text-gray-500">Loading metrics data...</p>
        </div>
      <% end %>
    </div>
    """
  end

  # Helper functions for formatting and display

  defp format_decimal(value) when is_number(value) do
    :erlang.float_to_binary(value * 1.0, decimals: 2)
  end

  defp format_decimal(_), do: "0.00"

  defp format_time_period(seconds) when seconds >= 3600 do
    hours = Float.round(seconds / 3600, 1)
    "#{hours} hours"
  end

  defp format_time_period(seconds) when seconds >= 60 do
    minutes = Float.round(seconds / 60, 1)
    "#{minutes} minutes"
  end

  defp format_time_period(seconds), do: "#{seconds} seconds"

  defp format_backpressure_status(:normal), do: "Normal"
  defp format_backpressure_status(:warning), do: "Warning"
  defp format_backpressure_status(:critical), do: "Critical"
  defp format_backpressure_status(_), do: "Unknown"

  defp backpressure_color(:normal), do: "bg-green-100 text-green-800"
  defp backpressure_color(:warning), do: "bg-yellow-100 text-yellow-800"
  defp backpressure_color(:critical), do: "bg-red-100 text-red-800"
  defp backpressure_color(_), do: "bg-gray-100 text-gray-800"

  defp format_time(nil), do: "Unknown"

  defp format_time(datetime) do
    Calendar.strftime(datetime, "%H:%M:%S")
  end
end
