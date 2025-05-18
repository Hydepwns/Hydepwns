defmodule HydepwnsLiveviewWeb.Live.ResourceShowLive do
  use HydepwnsLiveviewWeb.BaseLive,
    layout: {HydepwnsLiveviewWeb.Components.Layout.Layouts, :app}

  alias HydepwnsLiveview.ResouceSystem

  @impl true
  def do_mount(%{"id" => id}, _session, socket) do
    resource = ResourceSystem.get_resource(String.to_integer(id))

    socket = 
      socket
      |> assign(:page_title, "Show Resource")
      |> assign(:resource, resource)

    # Debugging: Inspect the fetched resource
    # IO.inspect(resource, label: "Resource in ShowLive mount")

    if resource do
      socket
    else
      assign(socket, :resource_not_found, true)
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <%= if @resource_not_found do %>
        <h1>Resource Not Found</h1>
        <p>Sorry, the requested resource could not be found.</p>
      <% else %>
        <h1 class="resource-name"><%= @resource.name %> (#<%= @resource.id %>)</h1>
        <p class="resource-description">Description: <%= @resource.description %></p>
        <p class="resource-type">Type: <%= @resource.type %></p>
        <p class="resource-status">Status: <%= Map.get(@resource, :status, "N/A") %></p>
        <div class="resource-content">
          Content: 
          <pre><%= Jason.encode!(@resource.data) %></pre>
        </div>
        <div class="resource-html">
          <%= if Map.get(@resource.data, :html_content) do %>
            <h3>Rendered HTML:</h3>
            <div><%= raw Map.get(@resource.data, :html_content) %></div>
          <% end %>
        </div>

        <%# Placeholder for relationships %>
        <div class="resource-relationships">
          <%# Parent: ... Child: ... %>
        </div>

        <%# Links for actions %>
        <.link navigate={~p"/resources/#{@resource.id}/edit"}>Edit Resource</.link>
        <.link navigate={~p"/admin/event-dashboard?resource_id=#{@resource.id}"}>View Events</.link>
        <.link navigate={~p"/resources/#{@resource.id}/manage-subscriptions"}>Manage Subscriptions</.link>
      <% end %>
      <br/>
      <.link navigate={~p"/resources"}>Back to Resources</.link>
    </div>
    """
  end
end 