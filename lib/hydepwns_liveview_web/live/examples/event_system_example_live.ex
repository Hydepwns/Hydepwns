defmodule HydepwnsLiveviewWeb.Examples.EventSystemExampleLive do
  use HydepwnsLiveviewWeb, :live_view
  import Phoenix.Component

  @moduledoc """
  LiveView for demonstrating the Resource Event System.

  This LiveView provides a UI for:
  - Generating test events
  - Viewing event history
  - Monitoring projections
  - Inspecting event handlers
  """

  use HydepwnsLiveviewWeb.BaseLive,
    required_assigns: [
      :page_title,
      :theme_class,
      :show_toc,
      :toc_items,
      :images,
      :events,
      :projections,
      :handlers,
      :active_tab,
      :user_count,
      :event_type,
      :resource_id,
      :resource_type,
      :event_data,
      :event_result,
      :selected_projection,
      :projection_state
    ]

  require Logger

  alias HydepwnsLiveview.Events.Core.Event
  alias HydepwnsLiveview.Events.EventStore, as: EventStore
  alias HydepwnsLiveview.Events.TestEvents, as: TestEvents
  alias HydepwnsLiveview.Events.ProjectionSupervisor, as: ProjectionSupervisor

  @impl true
  def mount(_params, _session, socket) do
    theme_class = "dark-theme"
    events = Event.list_events()
    projections = [UserActivityProjection]

    socket =
      socket
      |> assign(:page_title, "Event System Example")
      |> assign(:theme_class, theme_class)
      |> assign(:events, events)
      |> assign(:projections, projections)
      |> assign(:active_tab, "events")
      |> assign(:selected_projection, nil)
      |> assign(:projection_state, nil)

    {:ok, socket}
  end

  @impl true
  def handle_event("select_tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, :active_tab, tab)}
  end

  @impl true
  def handle_event("generate_test_data", %{"user_count" => user_count}, socket) do
    # Parse the user count
    user_count = String.to_integer(user_count)

    # Generate test data
    case TestEvents.generate_test_data(user_count) do
      {:ok, events} ->
        # Refresh the events list
        {:ok, latest_events} = EventStore.get_events(%{limit: 10, sort: [timestamp: :desc]})

        socket =
          socket
          |> assign(:events, latest_events)
          |> assign(:event_result, "Generated #{length(events)} events for #{user_count} users")

        {:noreply, socket}

      {:error, reason} ->
        socket = assign(socket, :event_result, "Error: #{inspect(reason)}")
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("publish_event", params, socket) do
    # Extract event data
    event_type = params["event_type"]
    resource_id = params["resource_id"]
    resource_type = params["resource_type"]
    event_data = parse_json(params["event_data"])

    # Create and publish the event
    case Event.create(event_type, %{
           resource_id: resource_id,
           resource_type: resource_type,
           data: event_data
         }) do
      {:ok, event} ->
        # Publish the event
        HydepwnsLiveview.Events.EventBus.publish(event)

        # Refresh the events list
        {:ok, latest_events} = EventStore.get_events(%{limit: 10, sort: [timestamp: :desc]})

        socket =
          socket
          |> assign(:events, latest_events)
          |> assign(:event_result, "Event published: #{event.id}")

        {:noreply, socket}

      {:error, reason} ->
        socket = assign(socket, :event_result, "Error: #{inspect(reason)}")
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("view_projection", %{"projection" => projection_index}, socket) do
    # Get the projection from the list
    case Enum.at(socket.assigns.projections, String.to_integer(projection_index), nil) do
      {projection_module, pid} ->
        # Get the projection state
        {:ok, state} = ProjectionSupervisor.get_projection_state(pid)

        socket =
          socket
          |> assign(:selected_projection, projection_module)
          |> assign(:projection_state, state)

        {:noreply, socket}

      nil ->
        socket = assign(socket, :event_result, "Invalid projection index")
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("rebuild_projection", %{"projection" => projection_index}, socket) do
    # Get the projection from the list
    case Enum.at(socket.assigns.projections, String.to_integer(projection_index), nil) do
      {_projection_module, pid} ->
        # Rebuild the projection
        ProjectionSupervisor.rebuild_projection(pid)

        # Wait a moment for the rebuild to complete
        Process.sleep(100)

        # Refresh the projection state
        {:ok, projections} = ProjectionSupervisor.list_projections()

        socket =
          socket
          |> assign(:projections, projections)
          |> assign(:event_result, "Projection rebuild initiated")

        {:noreply, socket}

      nil ->
        socket = assign(socket, :event_result, "Invalid projection index")
        {:noreply, socket}
    end
  end

  @impl true
  def handle_info(_msg, socket) do
    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="event-system-example">
      <h1 class="text-2xl font-bold mb-4">Resource Event System Example</h1>

      <div class="mb-6">
        <div class="tabs">
          <button phx-click="select_tab" phx-value-tab="events" class={"tab #{if @active_tab == "events", do: "active"}"}>
            Events
          </button>
          <button phx-click="select_tab" phx-value-tab="projections" class={"tab #{if @active_tab == "projections", do: "active"}"}>
            Projections
          </button>
          <button phx-click="select_tab" phx-value-tab="handlers" class={"tab #{if @active_tab == "handlers", do: "active"}"}>
            Handlers
          </button>
        </div>

        <div class="tab-content">
          <%= case @active_tab do %>
            <% "events" -> %>
              <div class="events-tab">
                <div class="grid grid-cols-2 gap-4">
                  <div class="event-generator">
                    <h2 class="text-xl font-bold mb-2">Generate Events</h2>

                    <div class="mb-4">
                      <h3 class="text-lg font-semibold mb-2">Test Data Generator</h3>
                      <form phx-submit="generate_test_data" class="mb-4">
                        <div class="form-group">
                          <label for="user_count">Number of Users:</label>
                          <input type="number" name="user_count" id="user_count" value={@user_count} min="1" max="100" class="form-input" />
                        </div>
                        <button type="submit" class="btn btn-primary">Generate Test Data</button>
                      </form>
                    </div>

                    <div>
                      <h3 class="text-lg font-semibold mb-2">Custom Event</h3>
                      <form phx-submit="publish_event">
                        <div class="form-group">
                          <label for="event_type">Event Type:</label>
                          <input type="text" name="event_type" id="event_type" value={@event_type} class="form-input" />
                        </div>

                        <div class="form-group">
                          <label for="resource_id">Resource ID:</label>
                          <input type="text" name="resource_id" id="resource_id" value={@resource_id} class="form-input" />
                        </div>

                        <div class="form-group">
                          <label for="resource_type">Resource Type:</label>
                          <input type="text" name="resource_type" id="resource_type" value={@resource_type} class="form-input" />
                        </div>

                        <div class="form-group">
                          <label for="event_data">Event Data (JSON):</label>
                          <textarea name="event_data" id="event_data" rows="5" class="form-textarea"><%= @event_data %></textarea>
                        </div>

                        <button type="submit" class="btn btn-primary">Publish Event</button>
                      </form>
                    </div>

                    <%= if @event_result do %>
                      <div class="mt-4 p-2 bg-gray-100 rounded">
                        <p>{@event_result}</p>
                      </div>
                    <% end %>
                  </div>

                  <div class="event-list">
                    <h2 class="text-xl font-bold mb-2">Recent Events</h2>

                    <div class="overflow-auto max-h-96">
                      <table class="w-full">
                        <thead>
                          <tr>
                            <th class="text-left">Type</th>
                            <th class="text-left">Resource</th>
                            <th class="text-left">Timestamp</th>
                          </tr>
                        </thead>
                        <tbody>
                          <%= for event <- @events do %>
                            <tr class="border-t">
                              <td class="py-2">{event.type}</td>
                              <td class="py-2">{event.resource_type}:{event.resource_id}</td>
                              <td class="py-2">{format_timestamp(event.timestamp)}</td>
                            </tr>
                          <% end %>
                        </tbody>
                      </table>
                    </div>
                  </div>
                </div>
              </div>
            <% "projections" -> %>
              <div class="projections-tab">
                <div class="grid grid-cols-2 gap-4">
                  <div class="projection-list">
                    <h2 class="text-xl font-bold mb-2">Active Projections</h2>

                    <div class="overflow-auto max-h-96">
                      <table class="w-full">
                        <thead>
                          <tr>
                            <th class="text-left">Projection</th>
                            <th class="text-left">Actions</th>
                          </tr>
                        </thead>
                        <tbody>
                          <%= for {{projection, _pid}, index} <- Enum.with_index(@projections) do %>
                            <tr class="border-t">
                              <td class="py-2">{module_name(projection)}</td>
                              <td class="py-2">
                                <button phx-click="view_projection" phx-value-projection={index} class="btn btn-sm btn-secondary">
                                  View
                                </button>
                                <button phx-click="rebuild_projection" phx-value-projection={index} class="btn btn-sm btn-secondary">
                                  Rebuild
                                </button>
                              </td>
                            </tr>
                          <% end %>
                        </tbody>
                      </table>
                    </div>
                  </div>

                  <div class="projection-state">
                    <h2 class="text-xl font-bold mb-2">Projection State</h2>

                    <%= if @selected_projection do %>
                      <h3 class="text-lg font-semibold mb-2">{module_name(@selected_projection)}</h3>

                      <div class="overflow-auto max-h-96 bg-gray-100 p-4 rounded">
                        <pre><%= format_state(@projection_state) %></pre>
                      </div>
                    <% else %>
                      <p>Select a projection to view its state</p>
                    <% end %>
                  </div>
                </div>
              </div>
            <% "handlers" -> %>
              <div class="handlers-tab">
                <h2 class="text-xl font-bold mb-2">Active Handlers</h2>

                <div class="overflow-auto max-h-96">
                  <table class="w-full">
                    <thead>
                      <tr>
                        <th class="text-left">Handler</th>
                        <th class="text-left">PID</th>
                      </tr>
                    </thead>
                    <tbody>
                      <%= for {handler, pid} <- @handlers do %>
                        <tr class="border-t">
                          <td class="py-2">{module_name(handler)}</td>
                          <td class="py-2">{inspect(pid)}</td>
                        </tr>
                      <% end %>
                    </tbody>
                  </table>
                </div>
              </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  # Helper functions

  defp format_timestamp(%DateTime{} = dt) do
    Calendar.strftime(dt, "%Y-%m-%d %H:%M:%S")
  end

  defp format_state(state) when is_map(state) do
    state
    |> Jason.encode!(pretty: true)
    |> String.replace(~r/"(\w+)":/, "\\1:")
  end

  defp format_state(state) do
    inspect(state, pretty: true, limit: :infinity)
  end

  defp module_name(module) do
    module
    |> Atom.to_string()
    |> String.replace(~r/^Elixir\./, "")
  end

  defp parse_json(""), do: %{}

  defp parse_json(json) do
    case Jason.decode(json) do
      {:ok, data} -> data
      {:error, _} -> %{}
    end
  end
end
