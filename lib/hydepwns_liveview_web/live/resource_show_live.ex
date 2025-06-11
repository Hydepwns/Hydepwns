defmodule HydepwnsLiveviewWeb.ResourceShowLive do
  use HydepwnsLiveviewWeb.BaseLive,
    layout: {HydepwnsLiveviewWeb.Layouts, :app}

  alias HydepwnsLiveview.Utils.MapHelpers
  alias HydepwnsLiveview.Resources
  alias HydepwnsLiveview.Events
  alias HydepwnsLiveview.Resources.RelationshipManager

  @impl true
  def mount(params, _session, socket) do
    super(params, _session, socket)
  end

  @impl true
  def do_mount(%{"id" => id}, _session, socket) do
    case api_module().fetch_data(id) do
      {:ok, resource_data} ->
        case Resources.get_resource!(id) do
          {:ok, resource} ->
            parent_resource = if resource.parent_id, do: Resources.get_resource!(resource.parent_id), else: nil
            child_resources = Resources.list_child_resources(id)

            socket
            |> assign(
              page_title: resource.name,
              resource: resource,
              parent_resource: parent_resource,
              child_resources: child_resources,
              error: nil
            )

          {:error, _reason} ->
            socket
            |> assign(
              page_title: "Resource Not Found",
              resource: nil,
              parent_resource: nil,
              child_resources: [],
              error: "Unable to load resource"
            )

          resource when is_map(resource) ->
            parent_resource = if resource.parent_id, do: Resources.get_resource!(resource.parent_id), else: nil
            child_resources = Resources.list_child_resources(id)

            socket
            |> assign(
              page_title: resource.name,
              resource: resource,
              parent_resource: parent_resource,
              child_resources: child_resources,
              error: nil
            )
        end

      {:error, _reason} ->
        socket
        |> assign(
          page_title: "Resource Not Found",
          resource: nil,
          parent_resource: nil,
          child_resources: [],
          error: "Unable to load resource"
        )
    end
  end

  @impl true
  def handle_event("delete", _params, socket) do
    case Resources.delete_resource(socket.assigns.resource.id) do
      :ok ->
        {:noreply,
         socket
         |> put_flash(:info, "Resource deleted successfully")
         |> push_navigate(to: ~p"/resources")}

      {:error, _} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to delete resource")
         |> push_navigate(to: ~p"/resources")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <%= if @error do %>
        <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative mb-4" role="alert" data-test-id="error-message">
          <span class="block sm:inline"><%= @error %></span>
        </div>
      <% else %>
        <div class="flex justify-between items-center mb-6">
          <h1 class="text-2xl font-bold" data-test-id="resource-name"><%= @resource.name %></h1>
          <div class="flex gap-4">
            <.link
              navigate={~p"/resources/#{@resource.id}/edit"}
              class="bg-blue-500 hover:bg-blue-600 text-white px-4 py-2 rounded"
              data-test-id="edit-resource-link"
            >
              Edit
            </.link>
            <button
              phx-click="delete"
              class="bg-red-500 hover:bg-red-600 text-white px-4 py-2 rounded"
              data-confirm="Are you sure you want to delete this resource?"
              data-test-id="delete-resource-button"
            >
              Delete
            </button>
            <.link
              navigate={~p"/resources/#{@resource.id}/events"}
              class="bg-gray-500 hover:bg-gray-600 text-white px-4 py-2 rounded"
              data-test-id="events-link"
            >
              Events
            </.link>
            <.link
              navigate={~p"/resources/#{@resource.id}/subscriptions"}
              class="bg-gray-500 hover:bg-gray-600 text-white px-4 py-2 rounded"
              data-test-id="subscriptions-link"
            >
              Subscriptions
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

        <div class="bg-white rounded-lg shadow p-6">
          <div class="mb-6">
            <h2 class="text-xl font-semibold mb-2">Details</h2>
            <div class="grid grid-cols-2 gap-4">
              <div>
                <p class="text-gray-600">Type</p>
                <p class="font-medium"><%= @resource.type %></p>
              </div>
              <div>
                <p class="text-gray-600">Status</p>
                <p class="font-medium" data-test-id="resource-status"><%= @resource.status %></p>
              </div>
            </div>
          </div>

          <div class="mb-6">
            <h2 class="text-xl font-semibold mb-4">Content</h2>
            <div class="bg-gray-50 p-4 rounded">
              <p>
                <%= if @resource.content && @resource.content.text do %>
                  <%= @resource.content.text %>
                <% end %>
              </p>
            </div>
          </div>

          <%= if @parent_resource do %>
            <div class="mb-6">
              <h2 class="text-xl font-semibold mb-4">Parent Resource</h2>
              <div class="relationship-row">
                <.link
                  navigate={~p"/resources/#{@parent_resource.id}"}
                  class="text-blue-600 hover:text-blue-800"
                  data-test-id={"parent-resource-link-#{@parent_resource.id}"}
                >
                  <%= @parent_resource.name %>
                </.link>
              </div>
            </div>
          <% end %>

          <%= if @child_resources != [] do %>
            <div class="mb-6">
              <h2 class="text-xl font-semibold mb-4">Child Resources</h2>
              <div class="space-y-2">
                <%= for child <- @child_resources do %>
                  <div class="relationship-row">
                    <.link
                      navigate={~p"/resources/#{child.id}"}
                      class="block text-blue-600 hover:text-blue-800"
                      data-test-id={"child-resource-link-#{child.id}"}
                    >
                      <%= child.name %>
                    </.link>
                  </div>
                <% end %>
              </div>
            </div>
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end

  # Dependency-injectable API module
  defp api_module do
    Application.get_env(:hydepwns_liveview, :external_api, HydepwnsLiveview.DefaultExternalAPI)
  end
end
