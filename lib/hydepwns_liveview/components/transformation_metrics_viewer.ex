defmodule HydepwnsLiveview.Components.TransformationMetricsViewer do
  @moduledoc """
  LiveComponent for visualizing transformation metrics and performance data.

  This component provides visual representations of:
  - Execution time trends
  - Success/failure rates
  - Resource size impacts
  - Comparative performance between transformations
  """

  use Phoenix.LiveComponent
  alias HydepwnsLiveview.Utils.TransformationMetrics

  @doc """
  Initializes the TransformationMetricsViewer LiveComponent with default assigns.
  """
  @spec mount(Phoenix.LiveView.Socket.t()) :: {:ok, Phoenix.LiveView.Socket.t()}
  def mount(socket) do
    {
      :ok,
      socket
      |> assign(:view_mode, :summary)
      |> assign(:selected_transformation, nil)
      |> assign(:filter, %{
        min_time: nil,
        max_time: nil,
        status: :all,
        time_period: :all
      })
      |> assign(:metrics_data, [])
      |> assign(:performance_report, %{})
    }
  end

  @doc """
  Updates the component assigns and loads metrics and performance report for the given transformation module.
  """
  @spec update(map(), Phoenix.LiveView.Socket.t()) :: {:ok, Phoenix.LiveView.Socket.t()}
  def update(assigns, socket) do
    transformation_module = assigns[:transformation_module]

    metrics_data =
      TransformationMetrics.get_metrics_for_visualization(
        transformation_module,
        Map.get(assigns, :opts, [])
      )

    performance_report =
      TransformationMetrics.generate_performance_report(
        transformation_module: transformation_module
      )

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:metrics_data, metrics_data)
      |> assign(:performance_report, performance_report)
    }
  end

  @doc """
  Handles UI events for changing view, selecting/clearing transformations, and updating filters.
  """
  @spec handle_event(String.t(), map(), Phoenix.LiveView.Socket.t()) ::
          {:noreply, Phoenix.LiveView.Socket.t()}
  def handle_event("change_view", %{"view" => view}, socket) do
    {:noreply, assign(socket, :view_mode, String.to_atom(view))}
  end

  @spec handle_event(String.t(), map(), Phoenix.LiveView.Socket.t()) ::
          {:noreply, Phoenix.LiveView.Socket.t()}
  def handle_event("select_transformation", %{"module" => module_string}, socket) do
    module =
      try do
        String.to_existing_atom(module_string)
      rescue
        _ -> nil
      end

    {:noreply, assign(socket, :selected_transformation, module)}
  end

  @spec handle_event(String.t(), map(), Phoenix.LiveView.Socket.t()) ::
          {:noreply, Phoenix.LiveView.Socket.t()}
  def handle_event("clear_selection", _, socket) do
    {:noreply, assign(socket, :selected_transformation, nil)}
  end

  @spec handle_event(String.t(), map(), Phoenix.LiveView.Socket.t()) ::
          {:noreply, Phoenix.LiveView.Socket.t()}
  def handle_event("update_filter", %{"filter" => filter_params}, socket) do
    filter = %{
      min_time: parse_integer(filter_params["min_time"]),
      max_time: parse_integer(filter_params["max_time"]),
      status: String.to_atom(filter_params["status"]),
      time_period: String.to_atom(filter_params["time_period"])
    }

    {:noreply, assign(socket, :filter, filter)}
  end

  @doc """
  Renders the TransformationMetricsViewer component UI based on the current view mode and assigns.
  """
  @spec render(map()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div class="transformation-metrics-viewer">
      <div class="metrics-viewer-header">
        <h2 class="metrics-title">Transformation Metrics</h2>
        <div class="view-selector">
          <button phx-click="change_view" phx-value-view="summary" phx-target={@myself} class={[~c"view-btn", if(@view_mode == :summary, do: ~c"active")]}>
            Summary
          </button>
          <button phx-click="change_view" phx-value-view="detail" phx-target={@myself} class={[~c"view-btn", if(@view_mode == :detail, do: ~c"active")]}>
            Detail
          </button>
          <button phx-click="change_view" phx-value-view="chart" phx-target={@myself} class={[~c"view-btn", if(@view_mode == :chart, do: ~c"active")]}>
            Charts
          </button>
          <button phx-click="change_view" phx-value-view="compare" phx-target={@myself} class={[~c"view-btn", if(@view_mode == :compare, do: ~c"active")]}>
            Compare
          </button>
        </div>
      </div>

      <div :if={@view_mode == :summary} class="metrics-summary">
        {render_performance_summary(assigns)}
      </div>
      <div :if={@view_mode == :detail} class="metrics-detail">
        {render_metrics_detail(assigns)}
      </div>
      <div :if={@view_mode == :chart} class="metrics-charts">
        {render_metrics_charts(assigns)}
      </div>
      <div :if={@view_mode == :compare} class="metrics-compare">
        {render_metrics_comparison(assigns)}
      </div>
    </div>
    """
  end

  defp render_performance_summary(assigns) do
    ~H"""
    <div class="performance-summary">
      <h3 class="summary-title">Performance Summary</h3>

      <div class="summary-cards">
        <div :for={{module, report} <- @performance_report} class="summary-card">
          <h4 class="transformation-name">{report.transformation_name}</h4>
          <div class="metrics-grid">
            <div class="metric">
              <span class="metric-label">Executions</span>
              <span class="metric-value">{report.total_executions}</span>
            </div>
            <div class="metric">
              <span class="metric-label">Avg. Time</span>
              <span class="metric-value">{format_time(report.avg_execution_time_ms)}</span>
            </div>
            <div class="metric">
              <span class="metric-label">Success Rate</span>
              <span class="metric-value">{format_percentage(report.success_rate)}</span>
            </div>
            <div class="metric">
              <span class="metric-label">Size Change</span>
              <span class="metric-value">{format_size_change(report.avg_size_change)}</span>
            </div>
          </div>
          <div class="card-actions">
            <button phx-click="select_transformation" phx-value-module={module} phx-target={@myself} class="view-details-btn">
              View Details
            </button>
          </div>
        </div>
      </div>

      <div :if={Enum.empty?(@performance_report)} class="empty-state">
        <p>No transformation metrics available yet.</p>
        <p>Run some transformations to collect performance data.</p>
      </div>
    </div>
    """
  end

  defp render_metrics_detail(assigns) do
    ~H"""
    <div class="metrics-detail-view">
      <div :if={@selected_transformation} class="transformation-details">
        <div class="detail-header">
          <h3 class="detail-title">
            {get_transformation_name(@selected_transformation)} Details
          </h3>
          <button phx-click="clear_selection" phx-target={@myself} class="back-btn">
            Back to All
          </button>
        </div>

        <div class="metrics-filter">
          <form phx-change="update_filter" phx-target={@myself}>
            <div class="filter-group">
              <label>Time Range:</label>
              <input type="number" name="filter[min_time]" placeholder="Min ms" value={@filter.min_time} />
              <span>to</span>
              <input type="number" name="filter[max_time]" placeholder="Max ms" value={@filter.max_time} />
            </div>

            <div class="filter-group">
              <label>Status:</label>
              <select name="filter[status]">
                <option value="all" selected={@filter.status == :all}>All</option>
                <option value="ok" selected={@filter.status == :ok}>Success</option>
                <option value="error" selected={@filter.status == :error}>Error</option>
              </select>
            </div>

            <div class="filter-group">
              <label>Period:</label>
              <select name="filter[time_period]">
                <option value="all" selected={@filter.time_period == :all}>All time</option>
                <option value="day" selected={@filter.time_period == :day}>Last 24 hours</option>
                <option value="week" selected={@filter.time_period == :week}>Last week</option>
              </select>
            </div>
          </form>
        </div>

        <div class="metrics-table-container">
          <table class="metrics-table">
            <thead>
              <tr>
                <th>Timestamp</th>
                <th>Execution Time</th>
                <th>Status</th>
                <th>Size Change</th>
              </tr>
            </thead>
            <tbody>
              <tr :for={metric <- filter_metrics(@metrics_data, @selected_transformation, @filter)}>
                <td>{format_timestamp(metric.timestamp)}</td>
                <td>{format_time(metric.execution_time)}</td>
                <td class={"status-#{metric.status}"}>{format_status(metric.status)}</td>
                <td>{format_size_change(metric.size_change)}</td>
              </tr>
            </tbody>
          </table>

          <div :if={Enum.empty?(filter_metrics(@metrics_data, @selected_transformation, @filter))} class="empty-state">
            <p>No metrics matching the current filters.</p>
          </div>
        </div>
      </div>
      <div :if={!@selected_transformation} class="select-prompt">
        <p>Please select a transformation from the summary view to see detailed metrics.</p>
        <button phx-click="change_view" phx-value-view="summary" phx-target={@myself} class="view-summary-btn">
          Go to Summary
        </button>
      </div>
    </div>
    """
  end

  defp render_metrics_charts(assigns) do
    ~H"""
    <div class="metrics-charts-view">
      <div class="chart-container">
        <h3 class="chart-title">Execution Time Trends</h3>
        <div class="chart-placeholder">
          <!-- In a real implementation, we would render an SVG chart here -->
          <div class="chart-mock">
            <div class="chart-y-axis">
              <span>Time (ms)</span>
            </div>
            <div class="chart-content">
              <div :for={{module, data} <- group_metrics_by_module(@metrics_data)} class="chart-series" style={"--series-color: #{get_module_color(module)}"}>
                <div class="series-label">{get_transformation_name(module)}</div>
                <div :for={point <- mock_chart_points(data)} class="chart-point" style={"height: #{point}%;"}></div>
              </div>
            </div>
            <div class="chart-x-axis">
              <span>Time</span>
            </div>
          </div>
        </div>
      </div>

      <div class="chart-container">
        <h3 class="chart-title">Success Rate Comparison</h3>
        <div class="chart-placeholder">
          <!-- Mock bar chart for success rates -->
          <div class="bar-chart-mock">
            <div :for={{module, report} <- @performance_report} class="bar-container">
              <div class="bar-label">{report.transformation_name}</div>
              <div class="bar-wrapper">
                <div class="success-bar" style={"width: #{report.success_rate}%; --bar-color: #{get_module_color(module)}"}>
                  {format_percentage(report.success_rate)}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp render_metrics_comparison(assigns) do
    ~H"""
    <div class="metrics-comparison-view">
      <div class="comparison-chart">
        <h3 class="comparison-title">Performance Comparison</h3>

        <div class="comparison-wrapper">
          <div class="metric-dimension">
            <h4>Average Execution Time (ms)</h4>
            <div class="horizontal-chart">
              <div :for={{module, report} <- sort_by_execution_time(@performance_report)} class="horizontal-bar-container">
                <div class="bar-label">{report.transformation_name}</div>
                <div class="bar-wrapper">
                  <div class="horizontal-bar" style={"width: #{calculate_percentage(report.avg_execution_time_ms, max_execution_time(@performance_report))}%; --bar-color: #{get_module_color(module)}"}>
                    {format_time(report.avg_execution_time_ms)}
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div class="metric-dimension">
            <h4>Resource Size Impact (bytes)</h4>
            <div class="horizontal-chart">
              <div :for={{module, report} <- sort_by_size_impact(@performance_report)} class="horizontal-bar-container">
                <div class="bar-label">{report.transformation_name}</div>
                <div class="bar-wrapper">
                  <div class={"horizontal-bar #{if report.avg_size_change < 0, do: "negative", else: "positive"}"} style={"width: #{calculate_percentage(abs(report.avg_size_change), max_size_change(@performance_report))}%; --bar-color: #{get_module_color(module)}"}>
                    {format_size_change(report.avg_size_change)}
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="overall-ranking">
        <h3>Overall Transformation Ranking</h3>
        <table class="ranking-table">
          <thead>
            <tr>
              <th>Rank</th>
              <th>Transformation</th>
              <th>Efficiency Score</th>
              <th>Success Rate</th>
              <th>Avg Time</th>
            </tr>
          </thead>
          <tbody>
            <tr :for={{{_module, report}, index} <- Enum.with_index(calculate_overall_ranking(@performance_report))}>
              <td>{index + 1}</td>
              <td>{report.transformation_name}</td>
              <td>{format_score(report.efficiency_score)}</td>
              <td>{format_percentage(report.success_rate)}</td>
              <td>{format_time(report.avg_execution_time_ms)}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    """
  end

  # Helper functions

  defp parse_integer(nil), do: nil
  defp parse_integer(""), do: nil

  defp parse_integer(str) when is_binary(str) do
    case Integer.parse(str) do
      {int, _} -> int
      :error -> nil
    end
  end

  defp get_transformation_name(module) when is_atom(module) do
    case HydepwnsLiveview.Utils.TransformationMetrics.get_metrics(module) do
      [] ->
        module
        |> to_string()
        |> String.split(".")
        |> List.last()

      [first | _] ->
        first.transformation_name
    end
  end

  defp format_time(time) when is_number(time) do
    cond do
      time < 1 -> "#{Float.round(time, 2)} ms"
      time < 1000 -> "#{Float.round(time, 1)} ms"
      true -> "#{Float.round(time / 1000, 2)} s"
    end
  end

  defp format_percentage(percentage) when is_number(percentage) do
    "#{Float.round(percentage, 1)}%"
  end

  defp format_size_change(change) when is_number(change) do
    sign = if change >= 0, do: "+", else: ""
    "#{sign}#{change} bytes"
  end

  defp format_timestamp(timestamp) do
    Calendar.strftime(timestamp, "%Y-%m-%d %H:%M:%S")
  end

  defp format_status(:ok), do: "Success"
  defp format_status(:error), do: "Error"

  defp format_score(score) when is_number(score) do
    "#{Float.round(score, 2)}"
  end

  defp filter_metrics(metrics, module, filter) do
    metrics
    |> Enum.filter(fn m ->
      module_matches = to_string(m.module) == to_string(module)

      time_matches =
        cond do
          filter.min_time != nil and filter.max_time != nil ->
            m.execution_time >= filter.min_time and m.execution_time <= filter.max_time

          filter.min_time != nil ->
            m.execution_time >= filter.min_time

          filter.max_time != nil ->
            m.execution_time <= filter.max_time

          true ->
            true
        end

      status_matches = filter.status == :all or m.status == filter.status

      period_matches =
        case filter.time_period do
          :all -> true
          :day -> DateTime.diff(DateTime.utc_now(), m.timestamp) <= 24 * 60 * 60
          :week -> DateTime.diff(DateTime.utc_now(), m.timestamp) <= 7 * 24 * 60 * 60
          _ -> true
        end

      module_matches and time_matches and status_matches and period_matches
    end)
  end

  defp group_metrics_by_module(metrics) do
    Enum.group_by(metrics, fn m ->
      # Extract module from the metrics data
      # This depends on how modules are represented in your metrics data
      # This is a placeholder implementation
      Map.get(m, :module, nil)
    end)
  end

  defp get_module_color(module) do
    # Generate a deterministic color based on the module name
    # Simple implementation for demonstration purposes
    hash = :erlang.phash2(to_string(module), 360)
    "hsl(#{hash}, 70%, 50%)"
  end

  defp mock_chart_points(_data) do
    # This is just a mock for visualization purposes
    # In a real implementation, you would calculate this based on actual data
    Enum.map(1..10, fn _ -> :rand.uniform(100) end)
  end

  defp sort_by_execution_time(report) do
    Enum.sort_by(report, fn {_, data} -> data.avg_execution_time_ms end)
  end

  defp sort_by_size_impact(report) do
    Enum.sort_by(report, fn {_, data} -> data.avg_size_change end)
  end

  defp max_execution_time(report) do
    Enum.reduce(report, 0, fn {_, data}, acc ->
      max(acc, data.avg_execution_time_ms)
    end)
  end

  defp max_size_change(report) do
    Enum.reduce(report, 0, fn {_, data}, acc ->
      max(acc, abs(data.avg_size_change))
    end)
  end

  defp calculate_percentage(value, max_value) when max_value > 0 do
    value / max_value * 100
  end

  defp calculate_percentage(_, _), do: 0

  defp calculate_overall_ranking(performance_report) do
    # Calculate an efficiency score based on execution time and success rate
    report_with_scores =
      Enum.map(performance_report, fn {module, report} ->
        # Lower execution time is better, higher success rate is better
        # Normalize execution time to be between 0 and 1 (reversed so lower is better)
        max_time = max_execution_time(performance_report)
        time_score = if max_time > 0, do: 1 - report.avg_execution_time_ms / max_time, else: 0

        # Success rate is already between 0 and 100, normalize to 0-1
        success_score = report.success_rate / 100

        # Combine scores (weighted average)
        efficiency_score = time_score * 0.7 + success_score * 0.3

        {module, Map.put(report, :efficiency_score, efficiency_score)}
      end)

    # Sort by efficiency score (higher is better)
    Enum.sort_by(report_with_scores, fn {_, report} -> report.efficiency_score end, :desc)
  end
end
