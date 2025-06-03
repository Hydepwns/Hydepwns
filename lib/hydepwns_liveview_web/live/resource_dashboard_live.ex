defmodule HydepwnsLiveviewWeb.ResourceDashboardLive do
  use HydepwnsLiveviewWeb.BaseLive,
    layout: {HydepwnsLiveviewWeb.Layouts, :app}

  alias HydepwnsLiveview.Resources.ResourceSystem

  @impl true
  def do_mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Resource Dashboard")
      |> assign(:resources, ResourceSystem.list_resources())
      |> assign_new(:errors, fn -> %{} end)

    socket
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h1>Resource Dashboard</h1>
      <p>
        <.link navigate={~p"/resources/new"} data-test-id="create-new-resource">Create New Resource</.link>
      </p>

      <h2>Existing Resources</h2>
      <ul>
        <%= for resource <- @resources do %>
          <li>
            <.link navigate={~p"/resources/#{resource.id}"} data-test-id={"resource-link-#{resource.id}"}>{resource.name}</.link>
            (Type: {resource.type}, ID: {resource.id})
            <div class="resource-actions">
              <.link navigate={~p"/resources/#{resource.id}/edit"}>Edit</.link>
              <.link navigate={~p"/resources/#{resource.id}/manage-subscriptions"}>Manage Subscriptions</.link>
              <.link navigate={~p"/resources/#{resource.id}/events"}>View Events</.link>
            </div>
          </li>
        <% end %>
      </ul>
    </div>
    """
  end
end
