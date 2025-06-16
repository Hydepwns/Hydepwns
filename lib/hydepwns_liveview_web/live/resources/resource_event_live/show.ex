defmodule HydepwnsLiveviewWeb.ResourceEventLive.Show do
  use HydepwnsLiveviewWeb, :live_view

  alias HydepwnsLiveview.Events
  alias HydepwnsLiveview.Events.Schemas.Event

  @impl Phoenix.LiveView
  def mount(%{"id" => event_id}, _session, socket) do
    case Events.get_event(event_id) do
      {:ok, event} ->
        {:ok,
         socket
         |> assign(:event, event)
         |> assign(:page_title, "Show Resource Event")}
      {:error, :not_found} ->
        {:ok,
         socket
         |> put_flash(:error, "Event not found")
         |> redirect(to: ~p"/resource_events")}
    end
  end

  @impl Phoenix.LiveView
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    socket
    |> assign(:page_title, "Show Resource Event")
    |> assign(:event_id, id)
  end

  @impl Phoenix.LiveView
  def handle_event("delete", %{"id" => id}, socket) do
    case Events.delete_event(id) do
      {:ok, _event} ->
        {:noreply,
         socket
         |> put_flash(:info, "Event deleted successfully")
         |> push_redirect(to: ~p"/resource_events")}
      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to delete event: #{inspect(reason)}")}
    end
  end

  @impl Phoenix.LiveView
  def handle_event("back", _params, socket) do
    {:noreply, push_redirect(socket, to: ~p"/resource_events")}
  end
end 