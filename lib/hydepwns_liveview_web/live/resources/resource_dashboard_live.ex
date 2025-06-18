defmodule HydepwnsLiveviewWeb.ResourceDashboardLive do
  @moduledoc """
  LiveView for the resource dashboard.
  """

  use HydepwnsLiveviewWeb, :live_view
  require Logger

  alias HydepwnsLiveview.Resources.ResourceSystem
  alias HydepwnsLiveview.Resources.Resource

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:resources, ResourceSystem.list_resources())
     |> assign(:selected_type, nil)
     |> assign(:page_title, "Resources")}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:resources, ResourceSystem.list_resources())
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Resource")
    |> assign(:resource, %Resource{})
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    case ResourceSystem.get_resource(id) do
      {:ok, resource} ->
        socket
        |> assign(:page_title, "Edit Resource")
        |> assign(:resource, resource)

      {:error, :not_found} ->
        socket
        |> put_flash(:error, "Resource not found")
        |> redirect(to: ~p"/resources")
    end
  end

  @impl true
  def handle_event("filter", %{"type" => type}, socket) do
    resources =
      case type do
        "" -> ResourceSystem.list_resources()
        type -> Enum.filter(ResourceSystem.list_resources(), &(&1.type == type))
      end

    {:noreply, assign(socket, :resources, resources)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    case ResourceSystem.delete_resource(id) do
      {:ok, _resource} ->
        {:noreply,
         socket
         |> put_flash(:info, "Resource deleted successfully")
         |> assign(:resources, ResourceSystem.list_resources())}

      {:error, _reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to delete resource")}
    end
  end

  defp resource_status_class("draft"), do: "bg-gray-100 text-gray-800"
  defp resource_status_class("published"), do: "bg-green-100 text-green-800"
  defp resource_status_class("archived"), do: "bg-red-100 text-red-800"
  defp resource_status_class(_), do: "bg-gray-100 text-gray-800"
end
