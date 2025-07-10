defmodule HydepwnsLiveviewWeb.ResourceEditLive do
  use HydepwnsLiveviewWeb, :live_view

  alias HydepwnsLiveview.Resources.ResourceSystem

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    case ResourceSystem.get_resource(id) do
      {:ok, resource} ->
        {:noreply,
         socket
         |> assign(:page_title, "Edit Resource")
         |> assign(:resource, resource)
         |> assign(:resources, ResourceSystem.list_resources([]))}

      {:error, :not_found} ->
        {:noreply,
         socket
         |> put_flash(:error, "Resource not found")
         |> redirect(to: ~p"/resources")}
    end
  end

  @impl true
  def handle_info({:resource_updated, resource}, socket) do
    IO.puts("🔍 ResourceEditLive: Received :resource_updated message")
    IO.puts("🔍 Setting flash message for resource update")

    {:noreply,
     socket
     |> put_flash(:info, "Resource updated successfully")
     |> redirect(to: ~p"/resources/#{resource.id}")}
  end
end
