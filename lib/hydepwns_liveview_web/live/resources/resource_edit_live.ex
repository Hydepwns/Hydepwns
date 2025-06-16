defmodule HydepwnsLiveviewWeb.ResourceEditLive do
  use HydepwnsLiveviewWeb, :live_view

  alias HydepwnsLiveview.Resources.ResourceSystem
  alias HydepwnsLiveview.Resources.Resource

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
         |> assign(:resources, ResourceSystem.list_resources())}

      {:error, :not_found} ->
        {:noreply,
         socket
         |> put_flash(:error, "Resource not found")
         |> redirect(to: ~p"/resources")}
    end
  end
end 