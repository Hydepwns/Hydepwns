defmodule HydepwnsLiveviewWeb.Event.EventIndexLive do
  use HydepwnsLiveviewWeb, :live_view

  on_mount {HydepwnsLiveviewWeb.UserAuth, :mount_current_user}

  @impl true
  def mount(_params, _session, socket) do
    events = HydepwnsLiveview.Events.list_events()
    {:ok,
     socket
     |> assign(:page_title, "Events")
     |> assign(:events, events)
     |> assign(:all_events, events)
     |> assign(:event_filter, %{"type" => ""})}
  end

  @impl true
  def handle_event("filter_events", %{"event_filter" => filter_params}, socket) do
    type_filter = Map.get(filter_params, "type", "")
    filtered_events =
      if type_filter == "" do
        socket.assigns.all_events
      else
        Enum.filter(socket.assigns.all_events, fn event ->
          String.contains?(event.type, type_filter)
        end)
      end
    {:noreply, assign(socket, events: filtered_events, event_filter: filter_params)}
  end

  def handle_event("clear_filters", _params, socket) do
    {:noreply, assign(socket, events: socket.assigns.all_events, event_filter: %{"type" => ""})}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <div class="flex justify-between items-center mb-8">
        <h1 class="text-3xl font-bold">Events</h1>
        <div class="flex gap-4">
          <.link navigate={~p"/timeline"} class="text-blue-600 hover:text-blue-800" data-test-id="timeline-link">
            Timeline
          </.link>
          <.link navigate={~p"/events/new"} class="bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded">
            Create Event
          </.link>
        </div>
      </div>

      <form phx-change="filter_events" phx-submit="filter_events" class="mb-6 flex gap-4 items-center">
        <label for="event_filter_type" class="font-medium">Event Type:</label>
        <input id="event_filter_type" name="event_filter[type]" type="text" class="border rounded px-2 py-1" placeholder="Type (e.g. resource.created)" value={@event_filter["type"]} />
        <button type="submit" class="ml-2 px-3 py-1 bg-blue-500 text-white rounded">Apply Filter</button>
        <button type="button" phx-click="clear_filters" class="ml-2 px-3 py-1 bg-gray-300 text-gray-700 rounded">Clear Filters</button>
      </form>

      <div class="bg-white shadow-lg rounded-lg p-6">
        <%= if Enum.empty?(@events) do %>
          <div class="text-center text-gray-500 py-8">
            <p class="text-lg">No events found</p>
            <p class="text-sm mt-2">Create your first event to get started</p>
          </div>
        <% else %>
          <div class="space-y-4">
            <%= for event <- @events do %>
              <div class="event-row flex items-center gap-4 py-2 border-b" data-event-type={event.type}>
                <span class="event-type font-mono text-xs bg-gray-200 px-2 py-1 rounded">
                  <%= String.split(event.type, ".") |> List.last() %>
                </span>
                <span class="event-resource-id text-sm text-gray-700">
                  <%= event.data["name"] || event.data[:name] %>
                </span>
                <span class="event-resource-id text-xs text-gray-500">
                  <%= event.resource_id %>
                </span>
                <span class="event-data text-sm text-gray-600">
                  <%= event.data["description"] || event.data[:description] || "No description" %>
                </span>
                <span class="event-timestamp text-xs text-gray-400 ml-2">
                  <%= event.inserted_at || event.timestamp %>
                </span>
              </div>
            <% end %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end 