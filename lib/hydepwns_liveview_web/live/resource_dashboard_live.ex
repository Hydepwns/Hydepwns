defmodule HydepwnsLiveviewWeb.ResourceDashboardLive do
  use HydepwnsLiveviewWeb.BaseLive,
    layout: {HydepwnsLiveviewWeb.Layouts, :app}

  alias HydepwnsLiveview.Resources
  alias HydepwnsLiveviewWeb.Components.ResourceCard

  @impl true
  def mount(params, session, socket) do
    super(params, session, socket)
  end

  @impl true
  def do_mount(_params, _session, socket) do
    # Subscribe to resource events using LiveEventHandler
    HydepwnsLiveview.Events.LiveEventHandler.subscribe(
      ["resource:created", "resource:updated", "resource:deleted"],
      "resource",
      nil
    )

    socket
    |> assign(
      page_title: "Resource Dashboard",
      resources: Resources.list_resources(),
      selected_resource_type: nil,
      selected_resources: [],
      show_filters: false,
      sort: %{field: :name, direction: :asc},
      errors: %{}
    )
  end

  @impl true
  def handle_event("select_resource_type", %{"type" => type}, socket) do
    {:noreply, assign(socket, selected_resource_type: type)}
  end

  @impl true
  def handle_event("toggle_filters", _, socket) do
    {:noreply, assign(socket, show_filters: !socket.assigns.show_filters)}
  end

  @impl true
  def handle_event("sort", %{"field" => field, "direction" => direction}, socket) do
    sort = %{
      field: String.to_existing_atom(field),
      direction: String.to_existing_atom(direction)
    }
    {:noreply, assign(socket, sort: sort)}
  end

  @impl true
  def handle_info({:resource_created, resource}, socket) do
    {:noreply, assign(socket, resources: [resource | socket.assigns.resources])}
  end

  @impl true
  def handle_info({:resource_updated, resource}, socket) do
    resources = Enum.map(socket.assigns.resources, fn r ->
      if r.id == resource.id, do: resource, else: r
    end)
    {:noreply, assign(socket, resources: resources)}
  end

  @impl true
  def handle_info({:resource_deleted, resource_id}, socket) do
    resources = Enum.reject(socket.assigns.resources, &(&1.id == resource_id))
    {:noreply, assign(socket, resources: resources)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <div class="flex justify-between items-center mb-6">
        <h1 class="text-2xl font-bold">Resource Dashboard</h1>
        <div class="flex gap-4">
          <.link
            navigate={~p"/resources/new"}
            class="bg-blue-500 hover:bg-blue-600 text-white px-4 py-2 rounded"
            data-test-id="new-resource-link"
          >
            Create New Resource
          </.link>
          <.link
            navigate={~p"/events"}
            class="bg-gray-500 hover:bg-gray-600 text-white px-4 py-2 rounded"
            data-test-id="events-link"
          >
            Events
          </.link>
          <.link
            navigate={~p"/account"}
            class="bg-gray-500 hover:bg-gray-600 text-white px-4 py-2 rounded"
            data-test-id="account-link"
          >
            Account
          </.link>
        </div>
      </div>

      <div class="mb-6">
        <button
          phx-click="toggle_filters"
          class="bg-gray-200 hover:bg-gray-300 px-4 py-2 rounded"
          data-test-id="toggle-filters"
        >
          <%= if @show_filters, do: "Hide Filters", else: "Show Filters" %>
        </button>

        <%= if @show_filters do %>
          <div class="mt-4 p-4 bg-gray-100 rounded">
            <div class="grid grid-cols-3 gap-4">
              <div>
                <label class="block text-sm font-medium text-gray-700">Resource Type</label>
                <select
                  phx-change="select_resource_type"
                  class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                  data-test-id="resource-type-select"
                >
                  <option value="">All Types</option>
                  <option value="document">Document</option>
                  <option value="folder">Folder</option>
                  <option value="image">Image</option>
                  <option value="video">Video</option>
                </select>
              </div>
            </div>
          </div>
        <% end %>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <%= for resource <- @resources do %>
          <div class="bg-white rounded-lg shadow p-6" data-test-id={"resource-card-#{resource.id}"}>
            <div class="flex justify-between items-start mb-4">
              <h2 class="text-xl font-semibold">
                <.link
                  navigate={~p"/resources/#{resource.id}"}
                  class="text-blue-600 hover:text-blue-800"
                  data-test-id={"resource-link-#{resource.id}"}
                >
                  <%= resource.name %>
                </.link>
              </h2>
              <div class="flex gap-2">
                <.link
                  navigate={~p"/resources/#{resource.id}/edit"}
                  class="text-gray-600 hover:text-gray-800"
                  data-test-id={"edit-resource-link-#{resource.id}"}
                >
                  Edit
                </.link>
                <.link
                  navigate={~p"/resources/#{resource.id}/events"}
                  class="text-gray-600 hover:text-gray-800"
                  data-test-id={"resource-events-link-#{resource.id}"}
                >
                  Events
                </.link>
                <.link
                  navigate={~p"/resources/#{resource.id}/subscriptions"}
                  class="text-gray-600 hover:text-gray-800"
                  data-test-id={"resource-subscriptions-link-#{resource.id}"}
                >
                  Subscriptions
                </.link>
              </div>
            </div>
            <p class="text-gray-600 mb-4"><%= resource.description %></p>
            <div class="flex justify-between items-center text-sm text-gray-500">
              <span>Type: <%= resource.type %></span>
              <span>Status: <%= resource.status %></span>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  defp get_resource_module(type) do
    case type do
      "document" -> HydepwnsLiveview.Resources.DocumentResource
      "folder" -> HydepwnsLiveview.Resources.FolderResource
      "image" -> HydepwnsLiveview.Resources.ImageResource
      "video" -> HydepwnsLiveview.Resources.VideoResource
      _ -> HydepwnsLiveview.Resources.DocumentResource
    end
  end

  defp get_resource_type(resource) do
    resource.__struct__
    |> Module.split()
    |> List.last()
    |> String.replace("Resource", "")
    |> String.downcase()
  end

  defp sort_resources(resources, sort) do
    Enum.sort_by(resources, fn resource ->
      case sort.field do
        :name -> resource.name
        :type -> get_resource_type(resource)
        :status -> resource.status || "active"
      end
    end, sort.direction)
  end
end
