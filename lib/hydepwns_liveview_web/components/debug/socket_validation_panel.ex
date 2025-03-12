defmodule HydepwnsLiveviewWeb.Components.Debug.SocketValidationPanel do
  @moduledoc """
  A debug panel component for visualizing socket validation issues.

  This component provides a real-time view of socket validation errors
  during development, making it easier to identify and fix validation
  issues in LiveView components.

  ## Usage

  The panel is automatically included in the app layout in development
  mode. No additional setup is required.

  You can manually trigger validation errors for testing using:

      SocketValidationHelper.broadcast_error(MyAppWeb.HomeLive, :type_error, 
        "Invalid type for :count", %{expected: "integer", got: "string"})

  You can also clear all errors using:

      SocketValidationHelper.clear_errors()
  """
  use HydepwnsLiveviewWeb, :live_component

  alias HydepwnsLiveview.Utils.SocketValidationHelper

  @default_max_errors 50

  @impl Phoenix.LiveComponent
  def mount(socket) do
    if Mix.env() == :dev do
      SocketValidationHelper.subscribe()

      {:ok,
       socket
       |> assign(:errors, [])
       |> assign(:filtered_errors, [])
       |> assign(:visible, false)
       |> assign(:show_timestamps, true)
       |> assign(:show_details, true)
       |> assign(:show_assign_inspector, false)
       |> assign(:max_errors, @default_max_errors)
       |> assign(:status, "idle")
       |> assign(:current_tab, "errors")
       |> assign(:error_filter, "all")
       |> assign(:sort_by, "timestamp")
       |> assign(:sort_direction, :desc)
       |> assign(:assign_filter, "")
       |> assign(:selected_view, "")
       |> assign(:available_views, [])
       |> assign(:current_assigns, nil)
       |> assign(:error_metrics, %{
         type_error: 0,
         missing_key: 0,
         missing_assigns: 0,
         schema_error: 0
       })
       |> assign(:total_error_count, 0)
       |> assign(:most_common_error, "None")
       |> assign(:error_rate, 0.0)
       |> assign(:max_error_count, 1)
       |> schedule_metrics_update()}
    else
      {:ok, socket}
    end
  end

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  # Add a pubsub subscription behavior to the component
  def subscribe do
    Phoenix.PubSub.subscribe(HydepwnsLiveview.PubSub, "socket_validation")
  end

  def handle_info({:validation_error, error_data}, socket) do
    # Add the error to the list of errors
    errors = [error_data | socket.assigns.errors]
    # Limit the number of errors to store
    errors = Enum.take(errors, socket.assigns.max_errors)

    # Apply filtering and sorting
    filtered_errors =
      filter_and_sort_errors(
        errors,
        socket.assigns.error_filter,
        socket.assigns.sort_by,
        socket.assigns.sort_direction
      )

    # Update error metrics
    socket = update_error_metrics(socket, error_data)

    # Show notification (add animation class)
    socket =
      socket
      |> assign(:errors, errors)
      |> assign(:filtered_errors, filtered_errors)
      |> assign(:status, "active")

    # Schedule status reset
    if socket.assigns.status == "active" do
      Process.send_after(self(), :reset_status, 2000)
    end

    {:noreply, socket}
  end

  def handle_info(:update_metrics, socket) do
    # Recalculate metrics
    error_rate = calculate_error_rate(socket.assigns.errors)

    # Schedule the next update
    {:noreply,
     socket
     |> assign(:error_rate, error_rate)
     |> schedule_metrics_update()}
  end

  def handle_info({:clear_errors, _}, socket) do
    {:noreply, assign(socket, :errors, []) |> assign(:filtered_errors, [])}
  end

  def handle_info({:show_validation_panel}, socket) do
    # Make the panel visible
    socket = assign(socket, :visible, true)

    # Set the current tab to errors
    socket = assign(socket, :current_tab, "errors")

    {:noreply, socket}
  end

  def handle_info(:reset_status, socket) do
    {:noreply, assign(socket, :status, "idle")}
  end

  def handle_info({:refresh_assigns, _view_module, assigns}, socket) do
    {:noreply, socket |> assign(:current_assigns, assigns)}
  end

  def handle_info(:refresh_views, socket) do
    # This would normally query for active LiveViews
    # For demonstration, we'll use mock data
    available_views = [
      HydepwnsLiveviewWeb.HomeLive,
      HydepwnsLiveviewWeb.AboutLive,
      HydepwnsLiveviewWeb.DocsLive
    ]

    {:noreply, socket |> assign(:available_views, available_views)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id} class="socket-validation-panel" data-visible={@visible}>
      <div class="panel-header">
        <div class="panel-title">
          <div class={"status-indicator #{status_class(@errors)}"} title={"#{length(@errors)} validation errors"}>
            {length(@errors)}
          </div>
          <h3>Socket Validation</h3>
        </div>
        <div class="panel-controls">
          <button phx-click="toggle-timestamps" phx-target={@myself} class="control-button" title="Toggle timestamps">
            <span class={if @show_timestamps, do: "active", else: ""}>🕒</span>
          </button>
          <button phx-click="toggle-details" phx-target={@myself} class="control-button" title="Toggle details">
            <span class={if @show_details, do: "active", else: ""}>🔍</span>
          </button>
          <button phx-click="toggle-assign-inspector" phx-target={@myself} class="control-button" title="Toggle assign inspector">
            <span class={if @show_assign_inspector, do: "active", else: ""}>📊</span>
          </button>
          <button phx-click="clear-errors" phx-target={@myself} class="control-button" title="Clear all errors">
            🗑️
          </button>
          <button phx-click="toggle-panel" phx-target={@myself} class="control-button" title="Toggle panel">
            {if @visible, do: "▼", else: "▲"}
          </button>
        </div>
      </div>
      <div class="panel-content" style={if @visible, do: "display: block;", else: "display: none;"}>
        <div class="panel-tabs">
          <button phx-click="switch-tab" phx-value-tab="errors" phx-target={@myself} class={"tab-button #{if @current_tab == "errors", do: "active"}"}>
            Errors ({length(@errors)})
          </button>
          <button phx-click="switch-tab" phx-value-tab="inspector" phx-target={@myself} class={"tab-button #{if @current_tab == "inspector", do: "active"}"}>
            Assign Inspector
          </button>
          <button phx-click="switch-tab" phx-value-tab="metrics" phx-target={@myself} class={"tab-button #{if @current_tab == "metrics", do: "active"}"}>
            Metrics
          </button>
          <button phx-click="switch-tab" phx-value-tab="suggestions" phx-target={@myself} class={"tab-button #{if @current_tab == "suggestions", do: "active"}"}>
            Fix Suggestions
          </button>
        </div>

        <%= if @current_tab == "errors" do %>
          <div class="errors-container">
            <div class="errors-controls">
              <div class="filter-container">
                <input type="text" placeholder="Filter errors..." phx-keyup="filter-errors" phx-target={@myself} value={@error_filter} class="error-filter" />
                <div class="sort-controls">
                  <select phx-change="change-sort" phx-target={@myself}>
                    <option value="timestamp" selected={@sort_by == "timestamp"}>Time</option>
                    <option value="view_module" selected={@sort_by == "view_module"}>View</option>
                    <option value="type" selected={@sort_by == "type"}>Type</option>
                  </select>
                  <button phx-click="toggle-sort-direction" phx-target={@myself} class="sort-direction-button">
                    {if @sort_direction == :asc, do: "↑", else: "↓"}
                  </button>
                </div>
              </div>
              <div class="view-filter">
                <select phx-change="filter-by-view" phx-target={@myself}>
                  <option value="">All Views</option>
                  <%= for view <- unique_views(@errors) do %>
                    <option value={view} selected={@view_filter == view}>{view}</option>
                  <% end %>
                </select>
              </div>
            </div>

            <%= if Enum.empty?(@filtered_errors) do %>
              <div class="no-errors">
                <p>No validation errors found.</p>
                <p class="help-text">
                  <%= if Enum.empty?(@errors) do %>
                    Validation errors will appear here when they occur.
                  <% else %>
                    No errors match your current filters.
                  <% end %>
                </p>
              </div>
            <% else %>
              <div class="error-list">
                <%= for error <- @filtered_errors do %>
                  <div class={"error-item error-type-#{error.type}"}>
                    <div class="error-header" phx-click="toggle-error-details" phx-value-id={error.id} phx-target={@myself}>
                      <div class="error-icon">
                        {error_icon(error.type)}
                      </div>
                      <div class="error-summary">
                        <div class="error-key">{error.key}</div>
                        <div class="error-message">{truncate_message(error.message)}</div>
                      </div>
                      <div class="error-meta">
                        <div class="error-view">{short_view_name(error.view_module)}</div>
                        <%= if @show_timestamps do %>
                          <div class="error-time">{format_time(error.timestamp)}</div>
                        <% end %>
                        <div class="error-expand-toggle">
                          <%= if Map.get(@expanded_errors, error.id, false) do %>
                            <span>▼</span>
                          <% else %>
                            <span>▶</span>
                          <% end %>
                        </div>
                      </div>
                    </div>
                    <%= if Map.get(@expanded_errors, error.id, false) do %>
                      <div class="error-details">
                        <div class="error-full-message">
                          <%= for line <- String.split(error.message, "\n") do %>
                            <div class={"#{if String.starts_with?(line, "```elixir"), do: "code-block-start"} #{if String.starts_with?(line, "```") && !String.starts_with?(line, "```elixir"), do: "code-block-end"}"}>
                              <%= if String.starts_with?(line, "```elixir") do %>
                                <span class="code-label">Code Sample:</span>
                              <% else %>
                                <div class={"#{if @in_code_block, do: "code-line", else: ""}"}>
                                  <%= if String.starts_with?(line, "#") && !@in_code_block do %>
                                    <strong>{line}</strong>
                                  <% else %>
                                    {line}
                                  <% end %>
                                </div>
                              <% end %>
                            </div>
                          <% end %>
                        </div>
                        <div class="error-details-value">
                          <div class="details-label">Details:</div>
                          <div class="details-content">
                            <%= for {key, value} <- Map.get(error, :details, %{}) do %>
                              <div class="detail-item">
                                <span class="detail-key">{key}:</span>
                                <span class="detail-value">{inspect(value)}</span>
                              </div>
                            <% end %>
                          </div>
                        </div>
                        <div class="error-actions">
                          <button phx-click="copy-fix-suggestion" phx-value-id={error.id} phx-target={@myself} class="action-button">
                            Copy Fix
                          </button>
                          <button phx-click="focus-in-editor" phx-value-view={error.view_module} phx-target={@myself} class="action-button">
                            Find in Editor
                          </button>
                          <button phx-click="dismiss-error" phx-value-id={error.id} phx-target={@myself} class="action-button">
                            Dismiss
                          </button>
                        </div>
                      </div>
                    <% end %>
                  </div>
                <% end %>
              </div>
              <div class="error-pagination">
                <div class="pagination-info">
                  Showing {length(@filtered_errors)} of {length(@errors)} errors
                </div>
                <div>
                  <label for="max-errors">Max errors:</label>
                  <select id="max-errors" phx-change="set-max-errors" phx-target={@myself} class="max-errors-selector">
                    <option value="10" selected={@max_errors == 10}>10</option>
                    <option value="25" selected={@max_errors == 25}>25</option>
                    <option value="50" selected={@max_errors == 50}>50</option>
                    <option value="100" selected={@max_errors == 100}>100</option>
                  </select>
                </div>
              </div>
            <% end %>
          </div>
        <% end %>

        <%= if @current_tab == "inspector" do %>
          <div class="inspector-container">
            <div class="inspector-controls">
              <div class="view-selector">
                <label for="inspector-view">Select View:</label>
                <select id="inspector-view" phx-change="select-view-for-inspection" phx-target={@myself}>
                  <option value="">Select a view...</option>
                  <%= for view <- @available_views do %>
                    <option value={inspect(view)} selected={@current_inspection_view == inspect(view)}>
                      {short_view_name(view)}
                    </option>
                  <% end %>
                </select>
                <button phx-click="refresh-views" phx-target={@myself} class="refresh-button">
                  🔄
                </button>
              </div>
            </div>

            <%= if @current_inspection_view && map_size(@current_assigns) > 0 do %>
              <div class="assigns-explorer">
                <div class="assigns-filter">
                  <input type="text" placeholder="Filter assigns..." phx-keyup="filter-assigns" phx-target={@myself} class="assign-filter" />
                </div>
                <div class="assigns-list">
                  <%= for {key, value} <- filter_assigns(@current_assigns, @assign_filter) do %>
                    <div class="assign-item">
                      <div class="assign-header" phx-click="toggle-assign-details" phx-value-key={key} phx-target={@myself}>
                        <div class="assign-key">{key}</div>
                        <div class="assign-type">{get_type(value)}</div>
                        <div class="assign-preview">{truncate_preview(value)}</div>
                        <div class="assign-toggle">
                          <%= if MapSet.member?(@expanded_assigns, key) do %>
                            <span>▼</span>
                          <% else %>
                            <span>▶</span>
                          <% end %>
                        </div>
                      </div>
                      <%= if MapSet.member?(@expanded_assigns, key) do %>
                        <div class="assign-details">
                          <pre class="assign-value"><%= inspect(value, pretty: true, width: 60) %></pre>
                          <div class="assign-validation">
                            <div class="validation-title">Validation Status:</div>
                            <div class="validation-result">
                              {render_validation_status(key, value, @current_inspection_view)}
                            </div>
                          </div>
                        </div>
                      <% end %>
                    </div>
                  <% end %>
                </div>
              </div>
            <% else %>
              <div class="no-assigns">
                <%= if !@current_inspection_view do %>
                  <p>Select a LiveView to inspect its assigns.</p>
                <% else %>
                  <p>No assigns found for the selected view.</p>
                <% end %>
              </div>
            <% end %>
          </div>
        <% end %>

        <%= if @current_tab == "metrics" do %>
          <div class="metrics-container">
            <div class="metrics-summary">
              <div class="metric-card">
                <div class="metric-title">Total Errors</div>
                <div class="metric-value">{length(@errors)}</div>
                <div class="metric-trend">
                  <%= if @error_rate > 0 do %>
                    <span class="trend-up">↑ {format_rate(@error_rate)}/min</span>
                  <% else %>
                    <span class="trend-stable">→ 0/min</span>
                  <% end %>
                </div>
              </div>

              <div class="metric-card">
                <div class="metric-title">Error Types</div>
                <div class="metric-value">{length(unique_error_types(@errors))}</div>
                <div class="metric-subtitle">
                  Most common: {most_common_error_type(@errors)}
                </div>
              </div>

              <div class="metric-card">
                <div class="metric-title">Affected Views</div>
                <div class="metric-value">{length(unique_views(@errors))}</div>
                <div class="metric-subtitle">
                  Most affected: {most_affected_view(@errors)}
                </div>
              </div>
            </div>

            <div class="metrics-charts">
              <div class="chart-container">
                <h4>Errors by Type</h4>
                <div class="bar-chart">
                  <%= for {type, count} <- error_counts_by_type(@errors) do %>
                    <div class="chart-item">
                      <div class="chart-label">{type}</div>
                      <div class="chart-bar-container">
                        <div class="chart-bar" style={"width: #{percentage(count, length(@errors))}%;"}>
                          {count}
                        </div>
                      </div>
                    </div>
                  <% end %>
                </div>
              </div>

              <div class="chart-container">
                <h4>Errors by View</h4>
                <div class="bar-chart">
                  <%= for {view, count} <- error_counts_by_view(@errors) do %>
                    <div class="chart-item">
                      <div class="chart-label">{short_view_name(view)}</div>
                      <div class="chart-bar-container">
                        <div class="chart-bar" style={"width: #{percentage(count, length(@errors))}%;"}>
                          {count}
                        </div>
                      </div>
                    </div>
                  <% end %>
                </div>
              </div>
            </div>
          </div>
        <% end %>

        <%= if @current_tab == "suggestions" do %>
          <div class="suggestions-container">
            <div class="quick-fixes">
              <h4>Quick Fixes</h4>
              <%= if Enum.empty?(@filtered_errors) do %>
                <p class="no-suggestions">No errors to suggest fixes for.</p>
              <% else %>
                <div class="quick-fixes-list">
                  <%= for error <- prioritize_errors(@filtered_errors) |> Enum.take(5) do %>
                    <div class="quick-fix-item">
                      <div class="quick-fix-header">
                        <div class="quick-fix-view">{short_view_name(error.view_module)}</div>
                        <div class="quick-fix-key">{error.key}</div>
                      </div>
                      <div class="quick-fix-message">{truncate_message(error.message, 120)}</div>
                      <div class="quick-fix-suggestion">
                        <%= if has_fix_suggestion?(error) do %>
                          <pre class="fix-code"><%= extract_first_code_sample(error.message) %></pre>
                          <button phx-click="apply-suggestion" phx-value-id={error.id} phx-target={@myself} class="apply-button">
                            Apply Fix
                          </button>
                        <% else %>
                          <p class="no-quick-fix">No automatic fix available.</p>
                        <% end %>
                      </div>
                    </div>
                  <% end %>
                </div>
              <% end %>
            </div>

            <div class="common-patterns">
              <h4>Common Error Patterns</h4>
              <div class="patterns-list">
                <%= for {pattern, count, solution} <- identify_error_patterns(@errors) do %>
                  <div class="pattern-item">
                    <div class="pattern-header">
                      <div class="pattern-name">{pattern}</div>
                      <div class="pattern-count">{count} occurrences</div>
                    </div>
                    <div class="pattern-solution">
                      <div class="solution-label">Recommended Solution:</div>
                      <div class="solution-content">{solution}</div>
                    </div>
                  </div>
                <% end %>
              </div>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("toggle-panel", _, socket) do
    {:noreply, assign(socket, :visible, !socket.assigns.visible)}
  end

  def handle_event("clear-errors", _, socket) do
    SocketValidationHelper.clear_errors()
    {:noreply, socket}
  end

  def handle_event("toggle-timestamps", _, socket) do
    {:noreply, assign(socket, :show_timestamps, !socket.assigns.show_timestamps)}
  end

  def handle_event("toggle-details", _, socket) do
    {:noreply, assign(socket, :show_details, !socket.assigns.show_details)}
  end

  def handle_event("toggle-assign-inspector", _, socket) do
    {:noreply, assign(socket, :show_assign_inspector, !socket.assigns.show_assign_inspector)}
  end

  def handle_event("set-max-errors", %{"max_errors" => max_str}, socket) do
    {max, _} = Integer.parse(max_str)
    {:noreply, socket |> assign(:max_errors, max)}
  end

  def handle_event("switch-tab", %{"tab" => tab}, socket) do
    # If switching to inspector tab, refresh views list
    socket =
      if tab == "inspector" and socket.assigns.current_tab != "inspector" do
        send(self(), :refresh_views)
        socket
      else
        socket
      end

    {:noreply, assign(socket, :current_tab, tab)}
  end

  def handle_event("filter-errors", %{"error_type" => type}, socket) do
    filtered_errors =
      filter_and_sort_errors(
        socket.assigns.errors,
        type,
        socket.assigns.sort_by,
        socket.assigns.sort_direction
      )

    {:noreply, socket |> assign(:error_filter, type) |> assign(:filtered_errors, filtered_errors)}
  end

  def handle_event("sort-errors", %{"sort_by" => sort_by}, socket) do
    filtered_errors =
      filter_and_sort_errors(
        socket.assigns.errors,
        socket.assigns.error_filter,
        sort_by,
        socket.assigns.sort_direction
      )

    {:noreply, socket |> assign(:sort_by, sort_by) |> assign(:filtered_errors, filtered_errors)}
  end

  def handle_event("toggle-sort-direction", _, socket) do
    new_direction = if socket.assigns.sort_direction == :asc, do: :desc, else: :asc

    filtered_errors =
      filter_and_sort_errors(
        socket.assigns.errors,
        socket.assigns.error_filter,
        socket.assigns.sort_by,
        new_direction
      )

    {:noreply,
     socket |> assign(:sort_direction, new_direction) |> assign(:filtered_errors, filtered_errors)}
  end

  def handle_event("filter-assigns", %{"assign_filter" => filter}, socket) do
    {:noreply, socket |> assign(:assign_filter, filter)}
  end

  def handle_event("select-view", %{"selected_view" => view}, socket) when view != "" do
    # This would normally fetch the actual assigns from the selected LiveView
    # For demonstration, we'll use mock data
    mock_assigns = %{
      user_id: 123,
      theme: "dark",
      items: ["Item 1", "Item 2", "Item 3"],
      user: %{name: "Test User", role: "admin"},
      count: 42,
      active: true
    }

    {:noreply, socket |> assign(:selected_view, view) |> assign(:current_assigns, mock_assigns)}
  end

  def handle_event("select-view", %{"selected_view" => ""}, socket) do
    {:noreply, socket |> assign(:selected_view, "") |> assign(:current_assigns, nil)}
  end

  def handle_event("refresh-assigns", %{"view" => view}, socket) do
    if view != "" do
      # This would normally query the actual LiveView for current assigns
      # For now, we'll just refresh with the same mock data
      send(
        self(),
        {:refresh_assigns, view, socket.assigns.current_assigns}
      )
    end

    {:noreply, socket}
  end

  # Status class helper based on error count
  defp status_class([]), do: "status-ok"
  defp status_class(errors) when length(errors) < 5, do: "status-warning"
  defp status_class(_errors), do: "status-error"

  # Format timestamp for display
  defp format_timestamp(%DateTime{} = timestamp) do
    Calendar.strftime(timestamp, "%H:%M:%S")
  end

  defp format_timestamp(_), do: "Unknown time"

  # Error type display labels
  defp error_type_label("type_error"), do: "Type Error"
  defp error_type_label("missing_key"), do: "Missing Key"
  defp error_type_label("missing_assigns"), do: "Missing Assigns"
  defp error_type_label("schema_error"), do: "Schema Error"
  defp error_type_label(type), do: String.capitalize(to_string(type))

  # Filter errors based on type and sort them
  defp filter_and_sort_errors(errors, filter, sort_by, direction) do
    errors
    |> filter_by_type(filter)
    |> sort_errors(sort_by, direction)
  end

  defp filter_by_type(errors, "all"), do: errors

  defp filter_by_type(errors, filter) do
    Enum.filter(errors, fn error ->
      to_string(error.error_type) == filter
    end)
  end

  defp sort_errors(errors, "timestamp", :desc) do
    Enum.sort_by(errors, fn e -> e.timestamp end, {:desc, DateTime})
  end

  defp sort_errors(errors, "timestamp", :asc) do
    Enum.sort_by(errors, fn e -> e.timestamp end, {:asc, DateTime})
  end

  defp sort_errors(errors, "type", direction) do
    Enum.sort_by(errors, fn e -> to_string(e.error_type) end, direction)
  end

  defp sort_errors(errors, "module", direction) do
    Enum.sort_by(errors, fn e -> to_string(e.view_module) end, direction)
  end

  # Filter assigns based on search term
  defp filtered_assigns(assigns, "") do
    assigns
  end

  defp filtered_assigns(assigns, filter) do
    Enum.filter(assigns, fn {key, _value} ->
      String.contains?(to_string(key), filter)
    end)
    |> Enum.into(%{})
  end

  # Determine the type of a value
  defp determine_type(value) when is_binary(value), do: "string"
  defp determine_type(value) when is_integer(value), do: "integer"
  defp determine_type(value) when is_boolean(value), do: "boolean"
  defp determine_type(value) when is_map(value), do: "map"
  defp determine_type(value) when is_list(value), do: "list"
  defp determine_type(value) when is_atom(value), do: "atom"
  defp determine_type(value) when is_function(value), do: "function"
  defp determine_type(value) when is_float(value), do: "float"
  defp determine_type(_), do: "unknown"

  # Update error metrics with a new error
  defp update_error_metrics(socket, error_data) do
    error_type = String.to_atom(to_string(error_data.type))
    error_metrics = Map.update(socket.assigns.error_metrics, error_type, 1, &(&1 + 1))

    # Calculate metrics summary
    {total_count, most_common, max_count} = calculate_metrics_summary(error_metrics)

    # Update socket with new metrics
    socket
    |> assign(:error_metrics, error_metrics)
    |> assign(:total_error_count, total_count)
    |> assign(:most_common_error, most_common)
    |> assign(:max_error_count, max_count)
    |> update_error_rate()
  end

  # Calculate summary metrics from error metrics
  defp calculate_metrics_summary(error_metrics) do
    total_count = Enum.sum(Map.values(error_metrics))

    {most_common, max_count} =
      if total_count > 0 do
        Enum.max_by(error_metrics, fn {_, count} -> count end)
      else
        {:none, 0}
      end

    {total_count, most_common, max_count}
  end

  # Calculate error rate (errors per minute)
  defp calculate_error_rate(errors) do
    now = DateTime.utc_now()
    one_minute_ago = DateTime.add(now, -60, :second)

    recent_errors =
      Enum.count(errors, fn error ->
        DateTime.compare(error.timestamp, one_minute_ago) in [:gt, :eq]
      end)

    recent_errors
  end

  # Update the error rate in the socket
  defp update_error_rate(socket) do
    assign(socket, :error_rate, calculate_error_rate(socket.assigns.errors))
  end

  # Calculate bar width for the chart (as percentage)
  defp calculate_bar_width(count, max_count) do
    Float.round(count / max_count * 100, 1)
  end

  # Schedule a metrics update
  defp schedule_metrics_update(socket) do
    # Schedule a metrics update every 5 seconds
    Process.send_after(self(), :update_metrics, 5000)
    socket
  end

  # Format an error message with proper line breaks and improved readability
  defp format_error_message(message) do
    message
    |> String.split("\n")
    |> Enum.map(fn line ->
      cond do
        String.contains?(line, "Suggestion:") ->
          Phoenix.HTML.raw(
            "<strong class=\"suggestion-header\">#{Phoenix.HTML.html_escape(line)}</strong>"
          )

        String.starts_with?(line, "- ") ->
          Phoenix.HTML.raw(
            "<span class=\"suggestion-bullet\">#{Phoenix.HTML.html_escape(line)}</span>"
          )

        String.starts_with?(line, "#") && String.contains?(line, "elixir") ->
          Phoenix.HTML.raw("<pre class=\"code-block\">#{Phoenix.HTML.html_escape(line)}</pre>")

        String.starts_with?(line, "```") ->
          if String.contains?(line, "elixir") do
            Phoenix.HTML.raw("<div class=\"code-block-start\">Elixir Code:</div>")
          else
            Phoenix.HTML.raw("")
          end

        true ->
          Phoenix.HTML.raw(
            "<span class=\"message-line\">#{Phoenix.HTML.html_escape(line)}</span>"
          )
      end
    end)
    |> Enum.join(Phoenix.HTML.raw("<br>"))
  end

  # Renders a simple bar chart for error metrics
  defp render_error_chart(metrics, max_count) do
    assigns = %{metrics: metrics, max_count: max_count}

    ~H"""
    <div class="bar-chart">
      <%= for {type, count} <- @metrics do %>
        <div class="chart-row">
          <div class="chart-label">{error_type_label(type)}</div>
          <div class="chart-bar-container">
            <div class="chart-bar" style={"width: #{calculate_bar_width(count, @max_count)}%;"}>
              <span class="bar-value">{count}</span>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  defp calculate_bar_width(count, max_count) when max_count > 0 do
    count / max_count * 100
  end

  defp calculate_bar_width(_count, _max_count), do: 0

  # Helper to determine if a value is simple enough to display directly
  defp is_simple_value(value) do
    case value do
      v when is_binary(v) -> String.length(v) < 50
      v when is_number(v) -> true
      v when is_atom(v) -> true
      v when is_boolean(v) -> true
      nil -> true
      _ -> false
    end
  end

  # Helper to create a summary for complex values
  defp summarize_value(value) do
    cond do
      is_map(value) -> "Map with #{map_size(value)} keys"
      is_list(value) -> "List with #{length(value)} items"
      is_tuple(value) -> "Tuple with #{tuple_size(value)} elements"
      is_function(value) -> "Function"
      is_pid(value) -> "PID"
      true -> "Complex value"
    end
  end

  # Format a complex value for display
  defp format_complex_value(value) do
    inspect(value, pretty: true, width: 60)
  end

  # Helper to get type of a value
  defp type_of_value(value) do
    cond do
      is_binary(value) -> "String"
      is_integer(value) -> "Integer"
      is_float(value) -> "Float"
      is_boolean(value) -> "Boolean"
      is_atom(value) -> "Atom"
      is_map(value) -> "Map"
      is_list(value) -> "List"
      is_tuple(value) -> "Tuple"
      is_function(value) -> "Function"
      is_pid(value) -> "PID"
      is_nil(value) -> "nil"
      true -> "Unknown"
    end
  end

  # Filter assigns based on search term
  defp filter_assigns(assigns, filter) when is_map(assigns) and is_binary(filter) do
    if filter == "" do
      assigns
    else
      assigns
      |> Enum.filter(fn {key, _value} ->
        key
        |> to_string()
        |> String.downcase()
        |> String.contains?(String.downcase(filter))
      end)
      |> Enum.into(%{})
    end
  end

  defp filter_assigns(assigns, _), do: assigns || %{}

  # Helper to get the short name of a view module
  defp short_view_name(nil), do: "Unknown"

  defp short_view_name(view_module) when is_binary(view_module) do
    view_module
    |> String.split(".")
    |> List.last()
    |> case do
      nil -> view_module
      name -> name
    end
  end

  defp short_view_name(view_module) do
    view_module
    |> to_string()
    |> short_view_name()
  end

  # Helper to get unique view modules from errors
  defp unique_views(errors) do
    errors
    |> Enum.map(& &1.view_module)
    |> Enum.uniq()
    |> Enum.reject(&is_nil/1)
    |> Enum.sort()
  end

  # Helper to get icon for different error types
  defp error_icon("type_error"), do: "🔍"
  defp error_icon("missing_key"), do: "🔑"
  defp error_icon("missing_assigns"), do: "📋"
  defp error_icon("schema_error"), do: "🧩"
  defp error_icon(_), do: "⚠️"

  # Helper for filtering assigns based on a search string
  defp filter_assigns(assigns, filter) when is_map(assigns) and is_binary(filter) do
    if filter == "" do
      assigns
    else
      assigns
      |> Enum.filter(fn {key, _value} ->
        key
        |> to_string()
        |> String.downcase()
        |> String.contains?(String.downcase(filter))
      end)
      |> Enum.into(%{})
    end
  end

  defp filter_assigns(assigns, _), do: assigns || %{}

  # Helper to get the type of a value as a string
  defp get_type(nil), do: "nil"
  defp get_type(value) when is_binary(value), do: "string"
  defp get_type(value) when is_integer(value), do: "integer"
  defp get_type(value) when is_float(value), do: "float"
  defp get_type(value) when is_boolean(value), do: "boolean"
  defp get_type(value) when is_map(value), do: "map"
  defp get_type(value) when is_list(value), do: "list"
  defp get_type(value) when is_atom(value), do: "atom"
  defp get_type(value) when is_function(value), do: "function"
  defp get_type(_), do: "unknown"

  # Helper to create a preview of a value
  defp truncate_preview(nil), do: "nil"

  defp truncate_preview(value) when is_binary(value) do
    if String.length(value) > 30 do
      String.slice(value, 0, 27) <> "..."
    else
      value
    end
  end

  defp truncate_preview(value) when is_list(value) do
    case length(value) do
      0 -> "[]"
      n -> "[...] (#{n} items)"
    end
  end

  defp truncate_preview(value) when is_map(value) do
    case map_size(value) do
      0 -> "{}"
      n -> "{...} (#{n} keys)"
    end
  end

  defp truncate_preview(value), do: inspect(value, limit: 10)

  # Helper to render validation status for an assign
  defp render_validation_status(key, value, view_module) do
    # This is a placeholder - in a real implementation you would
    # check the view module's type_specs and validate the value
    type_html = Phoenix.HTML.html_escape(get_type(value))
    required_html = Phoenix.HTML.html_escape(inspect(is_required_assign?(key, view_module)))

    Phoenix.HTML.raw("""
    <div class="validation-check">
      <div class="validation-type">Type: <code>#{type_html}</code></div>
      <div class="validation-required">
        Required: <code>#{required_html}</code>
      </div>
    </div>
    """)
  end

  # Helper to check if an assign is required (placeholder implementation)
  defp is_required_assign?(_key, _view_module) do
    # In a real implementation, this would check the view's required_assigns
    "unknown"
  end

  # Helper to get unique error types from errors
  defp unique_error_types(errors) do
    errors
    |> Enum.map(& &1.type)
    |> Enum.uniq()
  end

  # Helper to get the most common error type
  defp most_common_error_type([]), do: "None"

  defp most_common_error_type(errors) do
    errors
    |> Enum.group_by(& &1.type)
    |> Enum.map(fn {type, errors} -> {type, length(errors)} end)
    |> Enum.max_by(fn {_type, count} -> count end, fn -> {"None", 0} end)
    |> elem(0)
  end

  # Helper to get the most affected view
  defp most_affected_view([]), do: "None"

  defp most_affected_view(errors) do
    errors
    |> Enum.group_by(& &1.view_module)
    |> Enum.map(fn {view, errors} -> {view, length(errors)} end)
    |> Enum.max_by(fn {_view, count} -> count end, fn -> {"None", 0} end)
    |> elem(0)
    |> short_view_name()
  end

  # Helper to format error rate
  defp format_rate(rate) when is_float(rate) do
    :erlang.float_to_binary(rate, decimals: 1)
  end

  defp format_rate(rate), do: to_string(rate)

  # Helper to count errors by type
  defp error_counts_by_type(errors) do
    errors
    |> Enum.group_by(& &1.type)
    |> Enum.map(fn {type, type_errors} -> {type, length(type_errors)} end)
    |> Enum.sort_by(fn {_type, count} -> count end, :desc)
  end

  # Helper to count errors by view
  defp error_counts_by_view(errors) do
    errors
    |> Enum.group_by(& &1.view_module)
    |> Enum.map(fn {view, view_errors} -> {view, length(view_errors)} end)
    |> Enum.sort_by(fn {_view, count} -> count end, :desc)
  end

  # Helper to calculate percentage
  defp percentage(_, 0), do: 0
  defp percentage(count, total), do: min(100, trunc(count / total * 100))

  # Helper to check if an error has a fix suggestion
  defp has_fix_suggestion?(error) do
    error.message && String.contains?(error.message, "```elixir")
  end

  # Helper to extract the first code sample from an error message
  defp extract_first_code_sample(nil), do: ""

  defp extract_first_code_sample(message) do
    case Regex.run(~r/```elixir\s*\n([\s\S]*?)\n\s*```/, message) do
      [_, code] -> code
      _ -> ""
    end
  end

  # Helper to prioritize errors for quick fixes
  defp prioritize_errors(errors) do
    errors
    |> Enum.filter(&has_fix_suggestion?/1)
    |> Enum.sort_by(
      fn error ->
        # Sort by recency and whether it has a fix suggestion
        {has_fix_suggestion?(error), error.timestamp}
      end,
      :desc
    )
  end

  # Helper to identify common error patterns
  defp identify_error_patterns(errors) do
    type_errors = Enum.filter(errors, &(&1.type == "type_error"))
    missing_keys = Enum.filter(errors, &(&1.type == "missing_key"))
    schema_errors = Enum.filter(errors, &(&1.type == "schema_error"))

    [
      identify_string_type_errors(type_errors),
      identify_integer_type_errors(type_errors),
      identify_common_missing_keys(missing_keys),
      identify_schema_validation_pattern(schema_errors)
    ]
    |> Enum.reject(&is_nil/1)
  end

  # Helper to identify string type error patterns
  defp identify_string_type_errors(errors) do
    string_errors =
      Enum.filter(errors, fn e ->
        e.message && String.contains?(e.message, "expected string")
      end)

    if length(string_errors) >= 2 do
      {"String Type Errors", length(string_errors),
       "Convert values to strings using to_string/1 or String.to_string/1"}
    else
      nil
    end
  end

  # Helper to identify integer type error patterns
  defp identify_integer_type_errors(errors) do
    integer_errors =
      Enum.filter(errors, fn e ->
        e.message && String.contains?(e.message, "expected integer")
      end)

    if length(integer_errors) >= 2 do
      {"Integer Type Errors", length(integer_errors),
       "Convert string values to integers using String.to_integer/1"}
    else
      nil
    end
  end

  # Helper to identify common missing keys
  defp identify_common_missing_keys(errors) do
    if length(errors) >= 3 do
      {"Missing Required Keys", length(errors),
       "Add all required keys to your socket assigns in the mount function"}
    else
      nil
    end
  end

  # Helper to identify schema validation patterns
  defp identify_schema_validation_pattern(errors) do
    if length(errors) >= 2 do
      {"Schema Validation Errors", length(errors),
       "Ensure maps match their expected schema structure"}
    else
      nil
    end
  end

  # Helper function to truncate message to a reasonable length
  defp truncate_message(message, length \\ 80) do
    cond do
      is_nil(message) -> ""
      String.length(message) <= length -> message
      true -> String.slice(message, 0, length) <> "..."
    end
  end

  # Helper to format timestamp to a readable format
  defp format_time(nil), do: ""

  defp format_time(timestamp) do
    timestamp
    |> DateTime.truncate(:second)
    |> Calendar.strftime("%H:%M:%S")
  end
end
