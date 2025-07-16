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
  def handle_event("validate", %{"resource" => resource_params}, socket) do
    IO.puts("🔍 ResourceEditLive: handle_event('validate') called")
    # Forward validation to the form component
    send_update(HydepwnsLiveviewWeb.ResourceFormComponent,
      id: socket.assigns.resource.id,
      resource_params: resource_params)
    {:noreply, socket}
  end

  @impl true
  def handle_event("save", %{"resource" => resource_params}, socket) do
    IO.puts("🔍 ResourceEditLive: handle_event('save') called with params: #{inspect(resource_params)}")
    IO.puts("🔍 ResourceEditLive: parent_id in params: #{inspect(Map.get(resource_params, "parent_id"))}")
    # The form component will handle the update and notify us
    {:noreply, socket}
  end

  @impl true
  def handle_event(event, params, socket) do
    IO.puts("🔍 ResourceEditLive: Received unexpected event '#{event}' with params: #{inspect(params)}")
    {:noreply, socket}
  end

  @impl true
  def handle_info({:resource_updated, resource}, socket) do
    IO.puts(
      "[DEBUG] ResourceEditLive.handle_info(:resource_updated) called with resource: #{inspect(resource)}"
    )

    {:noreply,
     socket
     |> put_flash(:info, "Resource updated successfully")
     |> push_navigate(to: ~p"/resources")}
  end

  @impl true
  def handle_info(message, socket) do
    IO.puts(
      "[DEBUG] ResourceEditLive: Received unexpected message: #{inspect(message)} (self: #{inspect(self())})"
    )

    {:noreply, socket}
  end

end
