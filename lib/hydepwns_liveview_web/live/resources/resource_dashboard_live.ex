defmodule HydepwnsLiveviewWeb.ResourceDashboardLive do
  @moduledoc """
  LiveView for the resource dashboard.
  """

  use HydepwnsLiveviewWeb, :live_view
  require Logger

  alias HydepwnsLiveview.Resources
  alias HydepwnsLiveview.Resources.Resource

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    default_theme = HydepwnsLiveview.ThemeSystem.ensure_default_theme()
    theme_class = "#{default_theme.mode}-theme"
    
    Logger.debug("ResourceDashboardLive: Mounting with empty resources")
    
    socket = socket
      |> assign(:theme_class, theme_class)
      |> assign(:resources, [])
      |> assign(:relationships, [])
      |> assign(:page_title, "Resource Dashboard")

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_params(params, _url, socket) do
    Logger.debug("ResourceDashboardLive: Handling params #{inspect(params)}")
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    resources = Resources.list_resources()
    relationships = Resources.list_relationships()
    
    Logger.debug("ResourceDashboardLive: Loading #{length(resources)} resources")
    Logger.debug("ResourceDashboardLive: Resource IDs: #{Enum.map_join(resources, ", ", & &1.id)}")
    
    socket
    |> assign(:resources, resources)
    |> assign(:relationships, relationships)
  end

  @impl Phoenix.LiveView
  def handle_event("filter", %{"type" => type}, socket) do
    resources = Resources.list_resources_by_type(type)
    {:noreply, assign(socket, :resources, resources)}
  end

  @impl Phoenix.LiveView
  def handle_event("new-resource", _params, socket) do
    {:noreply, push_navigate(socket, to: ~p"/resources/new")}
  end

  defp resource_status_class("draft"), do: "bg-gray-100 text-gray-800"
  defp resource_status_class("published"), do: "bg-green-100 text-green-800"
  defp resource_status_class("archived"), do: "bg-red-100 text-red-800"
  defp resource_status_class(_), do: "bg-gray-100 text-gray-800"
end
