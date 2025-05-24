defmodule HydepwnsLiveviewWeb.ResourceShowLive do
  use HydepwnsLiveviewWeb.BaseLive,
    layout: {HydepwnsLiveviewWeb.Components.Layout.Layouts, :app}

  alias HydepwnsLiveview.Resources.ResourceSystem
  alias HydepwnsLiveview.DefaultExternalAPI
  alias HydepwnsLiveview.Utils.MapHelpers
  import HydepwnsLiveviewWeb.CoreComponents

  @impl true
  def do_mount(%{"id" => id}, _session, socket) do
    case DefaultExternalAPI.fetch_data(id) do
      {:ok, resource} ->
        # Recursively unwrap nested 'data' keys and ensure all keys are strings
        resource =
          resource
          |> MapHelpers.unwrap_data()
          |> MapHelpers.stringify_keys()
        socket =
          socket
          |> assign(:page_title, "Show Resource")
          |> assign(:resource, resource)
          |> assign(:resource_not_found, false)
        socket
      {:error, _reason} ->
        socket =
          socket
          |> assign(:page_title, "Show Resource")
          |> assign(:resource, nil)
          |> assign(:resource_not_found, true)
        socket
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.flash_group flash={@flash} />
    <div>
      <div :if={@resource_not_found}>
        <h1>Resource Not Found</h1>
        <p>Sorry, the requested resource could not be found.</p>
        <div data-test-id="error-message">Unable to load resource</div>
      </div>
      <div :if={!@resource_not_found && @resource}>
        <h1 class="resource-name" data-test-id="resource-name">{Map.get(@resource, "name", "N/A")} (#{Map.get(@resource, "id", "N/A")})</h1>
        <p class="resource-description">Description: {Map.get(@resource, "description", "N/A")}</p>
        <p class="resource-type">Type: {Map.get(@resource, "type", "N/A")}</p>
        <p class="resource-status" data-test-id="resource-status">Status: {Map.get(@resource, "status", "N/A")}</p>
        <div class="resource-content" data-test-id="resource-content">
          <% content = Map.get(@resource, "content", "N/A") %>
          <%= content %>
        </div>
        <div class="resource-html" data-test-id="resource-html">
          <div :if={Map.has_key?(@resource, "html_content") && Map.get(@resource, "html_content")}> 
            <h3>Rendered HTML:</h3>
            <div>{raw(Map.get(@resource, "html_content"))}</div>
          </div>
        </div>

        <div class="resource-relationships"></div>

        <.link navigate={~p"/resources/#{Map.get(@resource, "id")}/edit"}>Edit Resource</.link>
        <.link navigate={~p"/admin/event-dashboard?resource_id=#{Map.get(@resource, "id")}"}>View Events</.link>
        <.link navigate={~p"/resources/#{Map.get(@resource, "id")}/manage-subscriptions"}>Manage Subscriptions</.link>
      </div>
      <br />
      <.link navigate={~p"/resources"}>Back to Resources</.link>
    </div>
    """
  end
end
