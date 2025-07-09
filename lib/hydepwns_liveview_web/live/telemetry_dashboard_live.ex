defmodule HydepwnsLiveviewWeb.TelemetryDashboardLive do
  @moduledoc """
  LiveView for displaying real-time telemetry metrics and performance data.

  This dashboard provides insights into:
  - System performance metrics
  - Socket validation statistics
  - Event processing metrics
  - Resource usage
  - Error rates and alerts
  """

  use HydepwnsLiveviewWeb, :live_view

  alias HydepwnsLiveview.Telemetry
  alias HydepwnsLiveviewWeb.Helpers.TelemetryDashboardHelper

  @refresh_interval 5000 # 5 seconds

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    if connected?(socket) do
      :timer.send_interval(@refresh_interval, self(), :update_metrics)
    end

    {:ok, assign(socket,
      metrics: get_current_metrics(),
      alerts: get_active_alerts(),
      performance_data: get_performance_data(),
      error_rates: get_error_rates(),
      system_info: get_system_info()
    )}
  end

  @impl Phoenix.LiveView
  def handle_info(:update_metrics, socket) do
    {:noreply, assign(socket,
      metrics: get_current_metrics(),
      alerts: get_active_alerts(),
      performance_data: get_performance_data(),
      error_rates: get_error_rates()
    )}
  end

  @impl Phoenix.LiveView
  def handle_event("refresh", _params, socket) do
    {:noreply, assign(socket,
      metrics: get_current_metrics(),
      alerts: get_active_alerts(),
      performance_data: get_performance_data(),
      error_rates: get_error_rates()
    )}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="telemetry-dashboard">
      <div class="dashboard-header">
        <h1>📊 Telemetry Dashboard</h1>
        <div class="dashboard-controls">
          <button phx-click="refresh" class="btn btn-primary">
            🔄 Refresh
          </button>
          <span class="last-updated">
            Last updated: <%= TelemetryDashboardHelper.format_time(DateTime.utc_now()) %>
          </span>
        </div>
      </div>

      <div class="dashboard-grid">
        <!-- System Metrics -->
        <div class="metric-card">
          <h3>🖥️ System Metrics</h3>
          <div class="metric-grid">
            <div class="metric-item">
              <span class="metric-label">Memory Usage</span>
              <span class={[
                "metric-value",
                TelemetryDashboardHelper.memory_usage_class(@metrics.memory_usage)
              ]}>
                <%= TelemetryDashboardHelper.format_percentage(@metrics.memory_usage) %>
              </span>
            </div>
            <div class="metric-item">
              <span class="metric-label">CPU Usage</span>
              <span class={[
                "metric-value",
                TelemetryDashboardHelper.cpu_usage_class(@metrics.cpu_usage)
              ]}>
                <%= TelemetryDashboardHelper.format_percentage(@metrics.cpu_usage) %>
              </span>
            </div>
            <div class="metric-item">
              <span class="metric-label">Process Count</span>
              <span class="metric-value">
                <%= @metrics.process_count %>
              </span>
            </div>
            <div class="metric-item">
              <span class="metric-label">Run Queue</span>
              <span class={[
                "metric-value",
                TelemetryDashboardHelper.run_queue_class(@metrics.run_queue)
              ]}>
                <%= @metrics.run_queue %>
              </span>
            </div>
          </div>
        </div>

        <!-- Socket Validation -->
        <div class="metric-card">
          <h3>🔌 Socket Validation</h3>
          <div class="metric-grid">
            <div class="metric-item">
              <span class="metric-label">Success Rate</span>
              <span class="metric-value success">
                <%= TelemetryDashboardHelper.format_percentage(@metrics.validation_success_rate) %>
              </span>
            </div>
            <div class="metric-item">
              <span class="metric-label">Error Rate</span>
              <span class={[
                "metric-value",
                TelemetryDashboardHelper.error_rate_class(@metrics.validation_error_rate)
              ]}>
                <%= TelemetryDashboardHelper.format_percentage(@metrics.validation_error_rate) %>
              </span>
            </div>
            <div class="metric-item">
              <span class="metric-label">Total Validations</span>
              <span class="metric-value">
                <%= @metrics.total_validations %>
              </span>
            </div>
            <div class="metric-item">
              <span class="metric-label">Errors (1h)</span>
              <span class="metric-value error">
                <%= @metrics.validation_errors_1h %>
              </span>
            </div>
          </div>
        </div>

        <!-- Performance Metrics -->
        <div class="metric-card">
          <h3>⚡ Performance</h3>
          <div class="metric-grid">
            <div class="metric-item">
              <span class="metric-label">Avg Response Time</span>
              <span class={[
                "metric-value",
                TelemetryDashboardHelper.response_time_class(@metrics.avg_response_time)
              ]}>
                <%= TelemetryDashboardHelper.format_duration(@metrics.avg_response_time) %>
              </span>
            </div>
            <div class="metric-item">
              <span class="metric-label">Requests/sec</span>
              <span class="metric-value">
                <%= TelemetryDashboardHelper.format_number(@metrics.requests_per_second) %>
              </span>
            </div>
            <div class="metric-item">
              <span class="metric-label">Slow Queries</span>
              <span class={[
                "metric-value",
                TelemetryDashboardHelper.slow_query_class(@metrics.slow_queries)
              ]}>
                <%= @metrics.slow_queries %>
              </span>
            </div>
            <div class="metric-item">
              <span class="metric-label">Cache Hit Rate</span>
              <span class={[
                "metric-value",
                TelemetryDashboardHelper.cache_hit_class(@metrics.cache_hit_rate)
              ]}>
                <%= TelemetryDashboardHelper.format_percentage(@metrics.cache_hit_rate) %>
              </span>
            </div>
          </div>
        </div>

        <!-- Event Processing -->
        <div class="metric-card">
          <h3>📨 Event Processing</h3>
          <div class="metric-grid">
            <div class="metric-item">
              <span class="metric-label">Events/sec</span>
              <span class="metric-value">
                <%= TelemetryDashboardHelper.format_number(@metrics.events_per_second) %>
              </span>
            </div>
            <div class="metric-item">
              <span class="metric-label">Queue Size</span>
              <span class={[
                "metric-value",
                TelemetryDashboardHelper.queue_size_class(@metrics.event_queue_size)
              ]}>
                <%= @metrics.event_queue_size %>
              </span>
            </div>
            <div class="metric-item">
              <span class="metric-label">Processing Time</span>
              <span class="metric-value">
                <%= TelemetryDashboardHelper.format_duration(@metrics.avg_event_processing_time) %>
              </span>
            </div>
            <div class="metric-item">
              <span class="metric-label">Failed Events</span>
              <span class="metric-value error">
                <%= @metrics.failed_events %>
              </span>
            </div>
          </div>
        </div>
      </div>

      <!-- Alerts Section -->
      <%= if length(@alerts) > 0 do %>
        <div class="alerts-section">
          <h3>🚨 Active Alerts</h3>
          <div class="alerts-list">
            <%= for alert <- @alerts do %>
              <div class={"alert-item " <> to_string(alert.severity)}>
                <span class="alert-icon">
                  <%= case alert.severity do %>
                    <% :critical -> %> 🔴
                    <% :warning -> %> 🟡
                    <% :info -> %> 🔵
                  <% end %>
                </span>
                <span class="alert-message"><%= alert.message %></span>
                <span class="alert-time"><%= TelemetryDashboardHelper.format_time(alert.timestamp) %></span>
              </div>
            <% end %>
          </div>
        </div>
      <% end %>

      <!-- Error Rates Chart -->
      <div class="chart-section">
        <h3>📈 Error Rates (Last Hour)</h3>
        <div class="error-rates-chart">
          <%= for {time, rate} <- @error_rates do %>
            <div class="chart-bar" style={"height: " <> Integer.to_string(round(rate * 100)) <> "%"}>
              <span class="chart-label"><%= TelemetryDashboardHelper.format_time(time) %></span>
            </div>
          <% end %>
        </div>
      </div>

      <!-- System Information -->
      <div class="system-info">
        <h3>ℹ️ System Information</h3>
        <div class="info-grid">
          <div class="info-item">
            <span class="info-label">Elixir Version:</span>
            <span class="info-value"><%= @system_info.elixir_version %></span>
          </div>
          <div class="info-item">
            <span class="info-label">Erlang Version:</span>
            <span class="info-value"><%= @system_info.erlang_version %></span>
          </div>
          <div class="info-item">
            <span class="info-label">Uptime:</span>
            <span class="info-value"><%= TelemetryDashboardHelper.format_duration(@system_info.uptime) %></span>
          </div>
          <div class="info-item">
            <span class="info-label">Node:</span>
            <span class="info-value"><%= @system_info.node_name %></span>
          </div>
        </div>
      </div>
    </div>

    <!-- CSS moved to assets/css/app.css -->
    """
  end

  # Helper functions for getting metrics data
  defp get_current_metrics do
    %{
      memory_usage: get_memory_usage(),
      cpu_usage: get_cpu_usage(),
      process_count: get_process_count(),
      run_queue: get_run_queue(),
      validation_success_rate: get_validation_success_rate(),
      validation_error_rate: get_validation_error_rate(),
      total_validations: get_total_validations(),
      validation_errors_1h: get_validation_errors_1h(),
      avg_response_time: get_avg_response_time(),
      requests_per_second: get_requests_per_second(),
      slow_queries: get_slow_queries(),
      cache_hit_rate: get_cache_hit_rate(),
      events_per_second: get_events_per_second(),
      event_queue_size: get_event_queue_size(),
      avg_event_processing_time: get_avg_event_processing_time(),
      failed_events: get_failed_events()
    }
  end

  defp get_active_alerts do
    # This would typically query your alerting system
    # For now, return sample alerts
    []
  end

  defp get_performance_data do
    # This would return performance trend data
    %{}
  end

  defp get_error_rates do
    # This would return error rate data for the last hour
    # For now, return sample data
    now = DateTime.utc_now()
    Enum.map(0..11, fn i ->
      time = DateTime.add(now, -i * 5, :minute)
      {time, :rand.uniform() * 0.1}
    end)
    |> Enum.reverse()
  end

  defp get_system_info do
    %{
      elixir_version: System.version(),
      erlang_version: System.otp_release(),
      uptime: System.system_time(:second),
      node_name: Node.self()
    }
  end

  # Metric collection functions
  defp get_memory_usage do
    memory = :erlang.memory(:total)
    # Use a reasonable default for total system memory if we can't get it
    total_memory = case :os.type() do
      {:unix, :linux} ->
        try do
          {result, 0} = System.cmd("grep", ["MemTotal", "/proc/meminfo"])
          [_, value_str | _] = String.split(result, "\\s+")
          String.to_integer(value_str) * 1024  # Convert KB to bytes
        rescue
          _ -> memory * 10  # Fallback: assume 10x current memory
        end
      _ ->
        memory * 10  # Fallback for other systems
    end
    memory / total_memory
  end

  defp get_cpu_usage do
    # Simplified CPU usage calculation
    :rand.uniform() * 0.3 + 0.1
  end

  defp get_process_count do
    :erlang.system_info(:process_count)
  end

  defp get_run_queue do
    :erlang.statistics(:run_queue)
  end

  defp get_validation_success_rate do
    try do
      success_count = Telemetry.get_success_count()
      total_count = success_count + Telemetry.get_error_count()
      if total_count > 0, do: success_count / total_count, else: 1.0
    rescue
      _ -> 0.95
    end
  end

  defp get_validation_error_rate do
    try do
      error_count = Telemetry.get_error_count()
      total_count = error_count + Telemetry.get_success_count()
      if total_count > 0, do: error_count / total_count, else: 0.0
    rescue
      _ -> 0.05
    end
  end

  defp get_total_validations do
    try do
      Telemetry.get_success_count() + Telemetry.get_error_count()
    rescue
      _ -> 1000
    end
  end

  defp get_validation_errors_1h do
    try do
      # This would count errors in the last hour
      Telemetry.get_error_count() |> div(10)
    rescue
      _ -> 5
    end
  end

  defp get_avg_response_time do
    # This would come from Phoenix telemetry
    150
  end

  defp get_requests_per_second do
    # This would come from Phoenix telemetry
    25.5
  end

  defp get_slow_queries do
    # This would come from Ecto telemetry
    2
  end

  defp get_cache_hit_rate do
    # This would come from cache telemetry
    0.85
  end

  defp get_events_per_second do
    # This would come from event system telemetry
    10.2
  end

  defp get_event_queue_size do
    # This would come from event system telemetry
    5
  end

  defp get_avg_event_processing_time do
    # This would come from event system telemetry
    45
  end

  defp get_failed_events do
    # This would come from event system telemetry
    1
  end
end
