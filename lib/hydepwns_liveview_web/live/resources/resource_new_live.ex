defmodule HydepwnsLiveviewWeb.ResourceNewLive do
  use HydepwnsLiveviewWeb, :live_view

  alias HydepwnsLiveview.Resources.ResourceSystem
  alias HydepwnsLiveview.Resources.Resource

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "New Resource")
     |> assign(:resource, %Resource{})
     |> assign(:resources, ResourceSystem.list_resources())}
  end

  @impl true
  def handle_info({:resource_created, _resource}, socket) do
    {:noreply,
     socket
     |> put_flash(:info, "Resource created successfully")
     |> redirect(to: "/resources")}
  end

  @impl true
  def handle_info({:resource_updated, _resource}, socket) do
    {:noreply,
     socket
     |> put_flash(:info, "Resource updated successfully")
     |> redirect(to: "/resources")}
  end

  @impl true
  def handle_info(message, socket) do
    IO.puts("ResourceNewLive: Received unexpected message: #{inspect(message)}")
    {:noreply, socket}
  end
end
