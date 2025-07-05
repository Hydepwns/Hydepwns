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
    if connected?(socket), do: Phoenix.PubSub.subscribe(HydepwnsLiveview.PubSub, "resources")
    {:ok,
     socket
     |> assign(:resources, ResourceSystem.list_resources())
     |> assign(:selected_type, nil)
     |> assign(:relationships, [])
     |> assign(:current_user, nil)
     |> assign(:page_title, "Resources")
     |> assign(:notifications, [])}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:resources, ResourceSystem.list_resources())
    |> assign(:relationships, [])
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
  def handle_event("navigate_to_new", _params, socket) do
    {:noreply, push_navigate(socket, to: ~p"/resources/new")}
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

  @impl true
  def handle_info({:resource_created, resource}, socket) do
    notification = %{
      id: :crypto.strong_rand_bytes(10) |> Base.encode16(case: :lower),
      title: "Resource Created",
      message: "Resource '#{resource.name}' was created successfully",
      severity: :success,
      persistent: false
    }
    notifications = HydepwnsLiveviewWeb.NotificationComponent.add_notification(socket.assigns.notifications, notification)
    {:noreply,
      socket
      |> put_flash(:info, "Resource created successfully")
      |> assign(:resources, ResourceSystem.list_resources())
      |> assign(:notifications, notifications)
    }
  end

  @impl true
  def handle_info({:resource_updated, resource}, socket) do
    notification = %{
      id: :crypto.strong_rand_bytes(10) |> Base.encode16(case: :lower),
      title: "Resource Updated",
      message: "Resource '#{resource.name}' was updated successfully",
      severity: :success,
      persistent: false
    }
    notifications = HydepwnsLiveviewWeb.NotificationComponent.add_notification(socket.assigns.notifications, notification)
    {:noreply,
      socket
      |> put_flash(:info, "Resource updated successfully")
      |> assign(:resources, ResourceSystem.list_resources())
      |> assign(:notifications, notifications)
    }
  end

  @impl true
  def handle_info(_message, socket) do
    {:noreply, socket}
  end
end
