defmodule HydepwnsLiveviewWeb.Live.ResourceDashboardLive do
  use HydepwnsLiveviewWeb.BaseLive,
    layout: {HydepwnsLiveviewWeb.Components.Layout.Layouts, :app}

  alias HydepwnsLiveview.ResourceSystem

  @impl true
  def do_mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Resource Dashboard")
      |> assign(:resources, ResourceSystem.list_resources())

    socket
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h1>Resource Dashboard</h1>
      <p>
        <.link navigate={~p"/resources/new"}>Create New Resource</.link>
      </p>

      <h2>Existing Resources</h2>
      <ul>
        <%= for resource <- @resources do %>
          <li>
            <.link navigate={~p"/resources/#{resource.id}"}><%= resource.name %></.link>
            (Type: <%= resource.type %>, ID: <%= resource.id %>)
          </li>
        <% end %>
      </ul>
    </div>
    """
  end
end 