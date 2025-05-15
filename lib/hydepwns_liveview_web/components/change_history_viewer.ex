defmodule HydepwnsLiveviewWeb.Components.ChangeHistoryViewer do
  @moduledoc """
  A component for displaying change history for tracked resources.

  This component provides a visual interface for viewing resource change history,
  comparing different versions, and visualizing changes over time.

  ## Examples

  ```heex
  <.change_history_viewer
    resource={@user}
    selected_version={@selected_version}
    on_view_version="view_version"
    on_diff_versions="diff_versions"
  />
  ```
  """

  use Phoenix.Component

  @doc """
  Renders a change history viewer for a resource.

  ## Attributes

  - `resource` - The resource with change history.
  - `selected_version` - Currently selected version (optional).
  - `on_view_version` - Event name to emit when a version is selected (optional).
  - `on_diff_versions` - Event name to emit when comparing versions (optional).
  - `show_timeline` - Whether to show a visual timeline (optional, default: true).
  - `show_audit_log` - Whether to show a detailed audit log (optional, default: false).
  - `view_mode` - The view mode to display: "timeline", "list", or "audit" (optional, default: "timeline").
  - `rest` - Additional HTML attributes to add to the container element.
  """
  attr :resource, :map, required: true
  attr :selected_version, :integer, default: nil
  attr :on_view_version, :string, default: nil
  attr :on_diff_versions, :string, default: nil
  attr :show_timeline, :boolean, default: true
  attr :show_audit_log, :boolean, default: false
  attr :view_mode, :string, default: "timeline"
  attr :diff, :map, default: nil
  attr :versioned_resource, :map, default: nil
  attr :rest, :global

  def change_history_viewer(assigns) do
    assigns =
      assigns
      |> assign(:change_history, get_history(assigns.resource))
      |> assign(:has_history, get_history(assigns.resource) |> Enum.any?())

    ~H"""
    <div class="change-history-viewer" {@rest}>
      <div class="change-history-header">
        <h3 class="text-xl font-bold mb-3">Change History</h3>
        <div class="view-mode-selector mb-4 flex space-x-2">
          <button phx-click="set_view_mode" phx-value-mode="timeline" class={"px-3 py-1 rounded #{if @view_mode == "timeline", do: "bg-blue-500 text-white", else: "bg-gray-200 text-gray-700"}"}>
            Timeline
          </button>
          <button phx-click="set_view_mode" phx-value-mode="list" class={"px-3 py-1 rounded #{if @view_mode == "list", do: "bg-blue-500 text-white", else: "bg-gray-200 text-gray-700"}"}>
            List
          </button>
          <button phx-click="set_view_mode" phx-value-mode="audit" class={"px-3 py-1 rounded #{if @view_mode == "audit", do: "bg-blue-500 text-white", else: "bg-gray-200 text-gray-700"}"}>
            Audit Log
          </button>
        </div>
      </div>

      <%= unless @has_history do %>
        <p class="text-gray-500 italic">No changes tracked yet. Update the resource to see change history.</p>
      <% else %>
        <%= if @show_timeline && @view_mode == "timeline" do %>
          <div class="timeline mb-6">
            <div class="timeline-track flex items-center justify-between w-full h-16 relative">
              <div class="timeline-line-bg absolute w-full h-1 bg-gray-200"></div>
              <%= for {change, index} <- Enum.with_index(@change_history) do %>
                <div
                  class={"timeline-marker relative z-10 w-4 h-4 rounded-full border-2 cursor-pointer transition-all
                    #{if @selected_version == change.version, do: "bg-blue-500 border-blue-700 w-6 h-6", else: "bg-white border-gray-300 hover:bg-blue-100"}"}
                  phx-click={@on_view_version && @on_view_version}
                  phx-value-version={change.version}
                  style={"margin-left: #{index * (100 / max(1, length(@change_history) - 1))}%"}
                >
                  <div class={"timeline-tooltip absolute bottom-full mb-2 bg-gray-800 text-white text-xs rounded py-1 px-2 left-1/2 transform -translate-x-1/2 w-48
                    #{if @selected_version == change.version, do: "block", else: "hidden group-hover:block"}"}>
                    <p><strong>Version {change.version}</strong></p>
                    <p>{format_timestamp(change.metadata.timestamp)}</p>
                    <p>{change.metadata.actor || "Unknown"}</p>
                    <p>{change.metadata.reason || "No reason provided"}</p>
                  </div>
                </div>
              <% end %>
            </div>
            <!-- Timeline labels -->
            <div class="timeline-labels flex justify-between w-full mt-2">
              <%= for change <- @change_history do %>
                <div class="text-xs text-gray-500">{format_timestamp_short(change.metadata.timestamp)}</div>
              <% end %>
            </div>
          </div>
        <% end %>

        <%= if @view_mode == "list" do %>
          <div class="mb-6">
            <table class="min-w-full bg-white">
              <thead>
                <tr>
                  <th class="py-2 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Version</th>
                  <th class="py-2 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Timestamp</th>
                  <th class="py-2 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Actor</th>
                  <th class="py-2 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Reason</th>
                  <th class="py-2 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Changes</th>
                  <th class="py-2 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Actions</th>
                </tr>
              </thead>
              <tbody>
                <%= for change <- @change_history do %>
                  <%= render_list_row(assigns, change) %>
                <% end %>
              </tbody>
            </table>
          </div>
        <% end %>

        <%= if @view_mode == "audit" do %>
          <div class="audit-log mb-6">
            <div class="flex justify-between mb-4">
              <h4 class="text-lg font-semibold">Audit Log</h4>
              <div class="filters flex space-x-2">
                <!-- Filter options would go here -->
              </div>
            </div>
            <div class="audit-entries space-y-4">
              <%= for change <- @change_history do %>
                <%= render_audit_row(assigns, change) %>
              <% end %>
            </div>
          </div>
        <% end %>
      <% end %>

      <%= if @versioned_resource do %>
        <div class="version-details mb-6">
          <h4 class="text-lg font-semibold mb-2">Version {@selected_version}</h4>
          <pre class="bg-gray-100 p-3 rounded text-sm overflow-auto"><%= inspect(@versioned_resource, pretty: true) %></pre>
        </div>
      <% end %>

      <%= if @diff do %>
        <div class="diff-view mb-6">
          <h4 class="text-lg font-semibold mb-2">Change Diff</h4>
          <div class="diff-details bg-gray-100 p-3 rounded">
            <%= for {key, values} <- @diff do %>
              <div class="diff-item mb-4 border-b pb-2">
                <div class="diff-key font-bold mb-1">{key}</div>
                <div class="diff-values grid grid-cols-2 gap-4">
                  <div class="diff-old">
                    <span class="text-red-500">- {inspect(values.before)}</span>
                  </div>
                  <div class="diff-new">
                    <span class="text-green-500">+ {inspect(values.after)}</span>
                  </div>
                </div>
                <%= if values[:nested_diff] do %>
                  <div class="mt-2 pl-4 border-l-2 border-gray-300">
                    <div class="text-sm font-medium mb-1">Nested Changes:</div>
                    <%= for {nested_key, nested_values} <- values.nested_diff do %>
                      <div class="diff-item mb-2">
                        <div class="diff-key font-medium text-sm">{nested_key}</div>
                        <div class="diff-values grid grid-cols-2 gap-4 text-sm">
                          <div class="diff-old">
                            <span class="text-red-500">- {inspect(nested_values.before)}</span>
                          </div>
                          <div class="diff-new">
                            <span class="text-green-500">+ {inspect(nested_values.after)}</span>
                          </div>
                        </div>
                      </div>
                    <% end %>
                  </div>
                <% end %>
              </div>
            <% end %>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  # Extracted row rendering for list view
  defp render_list_row(assigns, change) do
    assigns = assign(assigns, :change, change)
    ~H"""
    <tr class={if @selected_version == @change.version, do: "bg-blue-50", else: ""}>
      <td class="py-2 px-4 border-b border-gray-200">{@change.version}</td>
      <td class="py-2 px-4 border-b border-gray-200">{format_timestamp(@change.metadata.timestamp)}</td>
      <td class="py-2 px-4 border-b border-gray-200">{@change.metadata.actor || "unknown"}</td>
      <td class="py-2 px-4 border-b border-gray-200">{@change.metadata.reason || "No reason provided"}</td>
      <td class="py-2 px-4 border-b border-gray-200">
        <ul class="list-disc pl-5">
          <%= for {key, _value} <- @change.changes do %>
            <li>{key}</li>
          <% end %>
        </ul>
      </td>
      <td class="py-2 px-4 border-b border-gray-200">
        <button phx-click={@on_view_version && @on_view_version} phx-value-version={@change.version} class="text-blue-500 hover:text-blue-700">
          View
        </button>
        <%= if @selected_version && @selected_version != @change.version do %>
          <button phx-click={@on_diff_versions && @on_diff_versions} phx-value-version1={@selected_version} phx-value-version2={@change.version} class="ml-2 text-green-500 hover:text-green-700">
            Diff
          </button>
        <% end %>
      </td>
    </tr>
    """
  end

  # Extracted row rendering for audit view
  defp render_audit_row(assigns, change) do
    assigns = assign(assigns, :change, change)
    ~H"""
    <div class={"audit-entry p-4 border rounded-lg #{if @selected_version == @change.version, do: "border-blue-500 bg-blue-50", else: "border-gray-200"}")}> 
      <div class="flex justify-between mb-2">
        <div class="text-sm font-semibold text-gray-700">Version {@change.version}</div>
        <div class="text-sm text-gray-500">{format_timestamp(@change.metadata.timestamp)}</div>
      </div>
      <div class="mb-2">
        <span class="inline-block bg-blue-100 text-blue-800 text-xs px-2 py-1 rounded mr-2">
          Actor: {@change.metadata.actor || "Unknown"}
        </span>
        <span class="inline-block bg-green-100 text-green-800 text-xs px-2 py-1 rounded mr-2">
          Source: {@change.metadata.source || "Unknown"}
        </span>
      </div>
      <div class="mb-3 text-sm text-gray-600">
        <p><strong>Reason:</strong> {@change.metadata.reason || "No reason provided"}</p>
      </div>
      <div class="changes-details">
        <div class="text-sm font-medium mb-1">Changes:</div>
        <div class="bg-gray-50 p-3 rounded text-sm">
          <%= for {key, value} <- @change.changes do %>
            <div class="mb-2">
              <div class="font-medium text-gray-700">{key}</div>
              <div class="grid grid-cols-2 gap-2">
                <div>
                  <span class="text-red-500">- {inspect(Map.get(@change.before, key))}</span>
                </div>
                <div>
                  <span class="text-green-500">+ {inspect(value)}</span>
                </div>
              </div>
            </div>
          <% end %>
        </div>
      </div>
      <div class="mt-3 flex justify-end">
        <button phx-click={@on_view_version && @on_view_version} phx-value-version={@change.version} class="bg-blue-100 hover:bg-blue-200 text-blue-800 text-xs px-3 py-1 rounded mr-2">
          View
        </button>
        <%= if @selected_version && @selected_version != @change.version do %>
          <button phx-click={@on_diff_versions && @on_diff_versions} phx-value-version1={@selected_version} phx-value-version2={@change.version} class="bg-green-100 hover:bg-green-200 text-green-800 text-xs px-3 py-1 rounded">
            Compare
          </button>
        <% end %>
      </div>
    </div>
    """
  end

  # Helper functions
  defp format_timestamp(nil), do: "Unknown"
  defp format_timestamp(timestamp), do: Calendar.strftime(timestamp, "%Y-%m-%d %H:%M:%S")

  defp format_timestamp_short(nil), do: "Unknown"
  defp format_timestamp_short(timestamp), do: Calendar.strftime(timestamp, "%m/%d %H:%M")

  defp get_history(resource) do
    Map.get(resource, :__change_history__, [])
  end
end
