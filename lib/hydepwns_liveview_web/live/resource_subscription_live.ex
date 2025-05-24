defmodule HydepwnsLiveviewWeb.ResourceSubscriptionLive do
  use HydepwnsLiveviewWeb, :live_view

  @event_types ["resource.updated", "resource.transformed"]

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    # In a real app, load current subscriptions from DB or API
    {:ok,
      socket
      |> assign(:resource_id, id)
      |> assign(:selected_events, [])
      |> assign(:status, nil)
    }
  end

  @impl true
  def handle_event("save_subscriptions", %{"events" => events}, socket) do
    # In a real app, persist subscriptions
    {:noreply, assign(socket, :selected_events, events) |> assign(:status, "Subscriptions updated!")}
  end
  def handle_event("save_subscriptions", _params, socket) do
    {:noreply, assign(socket, :selected_events, []) |> assign(:status, "Subscriptions updated!")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto p-8">
      <h1 class="text-2xl font-bold mb-4">Manage Subscriptions for Resource {@resource_id}</h1>
      <form phx-submit="save_subscriptions">
        <div class="mb-4">
          <%= for event_type <- @event_types do %>
            <div class="mb-2">
              <label>
                <input type="checkbox" name="events[]" value={event_type} checked={event_type in @selected_events} />
                {event_type}
              </label>
            </div>
          <% end %>
        </div>
        <button type="submit" class="btn btn-primary">Save Subscriptions</button>
      </form>
      <%= if @status do %>
        <div class="mt-4 text-green-600">{@status}</div>
      <% end %>
      <div class="mt-8">
        <.link navigate={~p"/resources/#{@resource_id}"} class="text-blue-600">Back to Resource</.link>
      </div>
    </div>
    """
  end
end 