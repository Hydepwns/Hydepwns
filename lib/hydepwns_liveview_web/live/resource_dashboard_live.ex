defmodule HydepwnsLiveviewWeb.ResourceDashboardLive do
  use HydepwnsLiveviewWeb.BaseLive,
    layout: {HydepwnsLiveviewWeb.Layouts, :app}

  alias HydepwnsLiveview.Resources.ResourceSystem

  @impl true
  def do_mount(_params, _session, socket) do
    IO.puts("[DEBUG] ResourceDashboardLive.do_mount called")
    socket =
      socket
      |> assign(:page_title, "Resource Dashboard")
      |> assign(:resources, ResourceSystem.list_resources())
    IO.inspect(socket.assigns, label: "[DEBUG] ResourceDashboardLive.do_mount assigns")
    socket
  end

  @impl true
  def render(assigns) do
    IO.puts("[DEBUG] ResourceDashboardLive.render called")
    IO.inspect(assigns, label: "[DEBUG] ResourceDashboardLive.render assigns")
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
            <.link navigate={~p"/resources/#{resource.id}"}>{resource.name}</.link> (Type: {resource.type}, ID: {resource.id})
          </li>
        <% end %>
      </ul>
    </div>
    """
  end
end
