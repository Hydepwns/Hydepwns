defmodule HydepwnsLiveviewWeb.ResourceEventLive do
  use HydepwnsLiveviewWeb, :live_view

  alias HydepwnsLiveview.Resources

  @impl true
  def mount(%{"id" => resource_id}, _session, socket) do
    events = Resources.list_resource_events(resource_id)
    
    {:ok,
     socket
     |> assign(:resource_id, resource_id)
     |> assign(:events, events)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <div class="flex justify-between items-center mb-6">
        <h1 class="text-2xl font-bold">Resource Events</h1>
        <div class="flex gap-4">
          <.link
            navigate={~p"/resources/#{@resource_id}"}
            class="bg-gray-500 hover:bg-gray-600 text-white px-4 py-2 rounded"
            data-test-id="back-to-resource"
          >
            Back to Resource
          </.link>
        </div>
      </div>

      <div class="bg-white shadow rounded-lg p-6">
        <div class="space-y-4">
          <%= if @events == [] do %>
            <p class="text-gray-500">No events found for this resource.</p>
          <% else %>
            <div class="overflow-x-auto">
              <table class="min-w-full divide-y divide-gray-200">
                <thead class="bg-gray-50">
                  <tr>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Type</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Timestamp</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Data</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                  </tr>
                </thead>
                <tbody class="bg-white divide-y divide-gray-200">
                  <%= for event <- @events do %>
                    <tr class="event-row" data-test-id="event-row">
                      <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900" data-test-id="event-type">
                        <%= event.type %>
                      </td>
                      <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500" data-test-id="event-timestamp">
                        <%= Calendar.strftime(event.timestamp, "%Y-%m-%d %H:%M:%S") %>
                      </td>
                      <td class="px-6 py-4 text-sm text-gray-500" data-test-id="event-data">
                        <%= inspect(event.data) %>
                      </td>
                      <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500" data-test-id="event-status">
                        <%= event.status %>
                      </td>
                    </tr>
                  <% end %>
                </tbody>
              </table>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end 