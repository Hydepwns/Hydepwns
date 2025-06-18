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
        <div :for={{_module, _report} <- @performance_report} class="summary-card">
          <h4 class="transformation-name">{_report.transformation_name}</h4>
          <div class="metrics-grid">
            <div class="metric">
              <span class="metric-label">Executions</span>
              <span class="metric-value">{_report.total_executions}</span>
            </div>
            <div class="metric">
              <span class="metric-label">Avg. Time</span>
              <span class="metric-value">{format_time(_report.avg_execution_time_ms)}</span>
            </div>
            <div class="metric">
              <span class="metric-label">Success Rate</span>
              <span class="metric-value">{format_percentage(_report.success_rate)}</span>
            </div>
            <div class="metric">
              <span class="metric-label">Size Change</span>
              <span class="metric-value">{format_size_change(_report.avg_size_change)}</span>
            </div>
          </div>
          <div class="card-actions">
            <button phx-click="select_transformation" phx-value-module={_module} phx-target={@myself} class="view-details-btn">
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
                <option value="month" selected={@filter.time_period == :month}>Last month</option>
                <option value="last_month" selected={@filter.time_period == :last_month}>Last Month</option>
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
              <tr :for={metric <- @metrics_data}>
                <td>{format_timestamp(metric.timestamp)}</td>
                <td>{format_time(metric.execution_time)}</td>
                <td class={"status-#{metric.status}"}>{format_status(metric.status)}</td>
                <td>{format_size_change(metric.size_change)}</td>
              </tr>
            </tbody>
          </table>

          <div :if={Enum.empty?(@metrics_data)} class="empty-state">
            <p>No metrics data available for the selected filters.</p>
          </div>
        </div>
      </div>

      <div :if={is_nil(@selected_transformation)} class="empty-state">
        <p>Select a transformation to view detailed metrics.</p>
      </div>
    </div>
    """
  end

  defp render_metrics_charts(assigns) do
    ~H"""
    <div class="metrics-charts-view">
      <div class="chart-container">
        <h3>Execution Time Trend</h3>
        <div class="chart" id="execution-time-chart"></div>
      </div>
      <div class="chart-container">
        <h3>Success Rate</h3>
        <div class="chart" id="success-rate-chart"></div>
      </div>
      <div class="chart-container">
        <h3>Size Impact</h3>
        <div class="chart" id="size-impact-chart"></div>
      </div>
    </div>
    """
  end

  defp render_metrics_comparison(assigns) do
    ~H"""
    <div class="metrics-comparison-view">
      <div class="comparison-header">
        <h3>Transformation Comparison</h3>
        <div class="comparison-filters">
          <select name="comparison_metric">
            <option value="execution_time">Execution Time</option>
            <option value="success_rate">Success Rate</option>
            <option value="size_impact">Size Impact</option>
          </select>
        </div>
      </div>
      <div class="comparison-chart" id="comparison-chart"></div>
    </div>
    """
  end

  # Helper functions
  defp parse_integer(value) when is_binary(value) do
    case Integer.parse(value) do
      {number, _} -> number
      :error -> nil
    end
  end

  defp parse_integer(_), do: nil

  defp get_transformation_name(module) when is_atom(module) do
    module
    |> Module.split()
    |> List.last()
    |> String.replace("Transformation", "")
  end

  defp get_transformation_name(_), do: "Unknown"

  defp format_time(time_ms) when is_integer(time_ms) do
    cond do
      time_ms < 1000 -> "#{time_ms}ms"
      time_ms < 60_000 -> "#{Float.round(time_ms / 1000, 1)}s"
      true -> "#{Float.round(time_ms / 60_000, 1)}m"
    end
  end

  defp format_time(_), do: "N/A"

  defp format_timestamp(%DateTime{} = timestamp) do
    Calendar.strftime(timestamp, "%Y-%m-%d %H:%M:%S")
  end

  defp format_timestamp(_), do: "N/A"

  defp format_status(:ok), do: "Success"
  defp format_status(:error), do: "Error"
  defp format_status(_), do: "Unknown"

  defp format_percentage(value) when is_number(value) do
    "#{Float.round(value * 100, 1)}%"
  end

  defp format_percentage(_), do: "N/A"

  defp format_size_change(value) when is_number(value) do
    cond do
      value > 0 -> "+#{value}%"
      value < 0 -> "#{value}%"
      true -> "0%"
    end
  end

  defp format_size_change(_), do: "N/A"
end
