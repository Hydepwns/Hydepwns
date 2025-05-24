defmodule HydepwnsLiveviewWeb.Components.Debug.SocketValidationGrid do
  @moduledoc """
  Debug Grid component for visualizing socket validation status.

  This component provides a visual representation of socket validation
  data in the Debug Grid interface, making it easier to identify and
  fix validation issues during development.
  """
  use HydepwnsLiveviewWeb, :live_component

  @doc """
  Renders the socket validation information in the Debug Grid.

  ## Assigns

  - id: Component ID (required)
  - data: Validation data from SocketValidationDebugGrid (required)
  """
  def render(assigns) do
    ~H"""
    <div id={@id} class="debug-grid-validation-panel" data-testid="socket-validation-grid">
      <div class="validation-panel-header">
        <h3 class="validation-title">
          <span class={"status-indicator-#{@data.overall_status}"}>
            {status_icon(@data.overall_status)}
          </span>
          Socket Validation
        </h3>
        <div class="validation-controls">
          <button class="validation-button" phx-click="toggle-validation-details" phx-target={@myself} title="Toggle details">
            🔍
          </button>
          <button class="validation-button" phx-click="highlight-validation-errors" phx-target={@myself} title="Highlight errors in UI">
            🔆
          </button>
          <button class="validation-button" phx-click="open-validation-panel" phx-target={@myself} title="Open validation panel">
            📋
          </button>
        </div>
      </div>

      <div :if={@show_details} class="validation-panel-content">
        <div class="validation-summary">
          <div>
            <span class="label">View:</span>
            <span class="value">{@data.view_module}</span>
          </div>
          <div>
            <span class="label">Required:</span>
            <span class={"value status-#{@data.required_status}"}>
              {status_icon(@data.required_status)}
              <span :if={@data.required_status == :error}>
                Missing: {Enum.join(@data.missing_assigns, ", ")}
              </span>
              <span :if={@data.required_status != :error}>
                All present
              </span>
            </span>
          </div>
        </div>

        <div class="validation-results">
          <h4>Validation Results</h4>
          <div class="validation-table-header">
            <div class="col-assign">Assign</div>
            <div class="col-status">Status</div>
            <div class="col-message">Message</div>
          </div>

          <div :for={result <- @data.validation_results} class={"validation-result result-#{result.status}"}>
            <div class="col-assign">
              <code>{result.assign}</code>
            </div>
            <div class="col-status">
              {status_icon(String.to_atom(result.status))}
            </div>
            <div class="col-message">
              <span :if={result.status == "error"}>
                {result.message}
              </span>
              <span :if={result.status != "error"}>
                Valid
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @doc false
  def mount(socket) do
    {:ok, socket |> assign(:show_details, false)}
  end

  @doc false
  def update(assigns, socket) do
    {:ok, socket |> assign(assigns)}
  end

  @doc false
  def handle_event("toggle-validation-details", _, socket) do
    {:noreply, socket |> assign(:show_details, !socket.assigns.show_details)}
  end

  @doc false
  def handle_event("highlight-validation-errors", _, socket) do
    # Send a message to the parent LiveView to highlight errors
    send(self(), {:highlight_validation_errors, socket.assigns.data.validation_results})
    {:noreply, socket}
  end

  @doc false
  def handle_event("open-validation-panel", _, socket) do
    # Send a message to the parent LiveView to open the validation panel
    send(self(), :open_validation_panel)
    {:noreply, socket}
  end

  # Helper functions for rendering status icons
  defp status_icon(:ok), do: "✅"
  defp status_icon(:error), do: "❌"
  defp status_icon(_unknown), do: "❓"
end
