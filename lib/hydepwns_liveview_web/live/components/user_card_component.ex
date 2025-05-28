defmodule HydepwnsLiveviewWeb.LiveComponents.UserCardComponent do
  @moduledoc """
  A LiveView component for displaying a user card with real-time updates.

  This component demonstrates how to use the event-driven UI updates
  feature of the Resource Event System to automatically update the UI
  when user resources change.
  """

  use Phoenix.LiveComponent

  alias HydepwnsLiveview.Resources.UserResource
  # alias HydepwnsLiveview.Schemas.User # Removed unused alias

  @doc """
  Mount hook for the component.

  Fetches the user resource if it's not already provided.
  """
  def update(assigns, socket) do
    socket = assign(socket, assigns)

    resource =
      if Map.has_key?(assigns, :resource) do
        assigns.resource
      else
        {:ok, user} = UserResource.load(assigns.resource_id)
        user
      end

    {:ok, assign(socket, :resource, resource)}
  end

  @doc """
  Render the user card component.
  """
  def render(assigns) do
    ~H"""
    <div id={@id} phx-hook="EventDrivenComponent" class="event-driven-component user-card">
      <div class="user-card-header">
        <h3>{@resource.name}</h3>
        <span class={"user-status user-status-#{@resource.status}"}>
          {@resource.status}
        </span>
      </div>

      <div class="user-card-body">
        <p class="user-email">{@resource.email}</p>

        <div class="user-timestamps">
          <div>
            <span class="label">Created:</span>
            <span>{format_datetime(@resource.created_at)}</span>
          </div>
          <div>
            <span class="label">Last updated:</span>
            <span>{format_datetime(@resource.updated_at)}</span>
          </div>
          <div>
            <span class="label">Last login:</span>
            <span>{format_datetime(@resource.last_login_at)}</span>
          </div>
        </div>
      </div>

      <div class="user-card-actions">
        <button phx-click="user-activate" phx-target={@myself} phx-disable-with="Activating...">
          Activate
        </button>
        <button phx-click="user-deactivate" phx-target={@myself} phx-disable-with="Deactivating...">
          Deactivate
        </button>
        <button phx-click="user-edit" phx-target={@myself}>
          Edit
        </button>
      </div>
    </div>
    """
  end

  @doc """
  Handle user actions like activate, deactivate, edit.
  """
  def handle_event("user-activate", _params, socket) do
    _resource_id = socket.assigns.resource_id
    current_resource = socket.assigns.resource

    # Execute the activate command on the user resource
    case UserResource.execute_command(current_resource, "activate", %{
           "reason" => "Activated from UI"
         }) do
      {:ok, _events, updated_user} ->
        # Optimistically update the UI
        {:noreply, assign(socket, :resource, updated_user)}

      {:error, _reason} ->
        # Show an error message (would use put_flash in a real app)
        {:noreply, socket}
    end
  end

  def handle_event("user-deactivate", _params, socket) do
    _resource_id = socket.assigns.resource_id
    current_resource = socket.assigns.resource

    # Execute the deactivate command on the user resource
    case UserResource.execute_command(current_resource, "deactivate", %{
           "reason" => "Deactivated from UI"
         }) do
      {:ok, _events, updated_user} ->
        # Optimistically update the UI
        {:noreply, assign(socket, :resource, updated_user)}

      {:error, _reason} ->
        # Show an error message (would use put_flash in a real app)
        {:noreply, socket}
    end
  end

  def handle_event("user-edit", _params, socket) do
    # Send a message to the parent LiveView to show the edit form
    send(self(), {:show_edit_user_form, socket.assigns.resource_id})
    {:noreply, socket}
  end

  @doc """
  Handle event updates from the event system.
  """
  def handle_info({:event, event}, socket) do
    # Get the current resource
    resource = socket.assigns.resource

    # Apply different logic based on the event type
    socket =
      case event.type do
        "user.logged_in" ->
          # For login events, we might want to show a logged-in indicator
          updated_resource = UserResource.apply_event(event, resource)
          assign(socket, resource: updated_resource, last_activity: "User logged in")

        "user.activated" ->
          # For activation events, we might want to show a success message
          updated_resource = UserResource.apply_event(event, resource)
          assign(socket, resource: updated_resource, status_change: "User activated")

        "user.deactivated" ->
          # For deactivation events, we might want to show a warning message
          updated_resource = UserResource.apply_event(event, resource)
          assign(socket, resource: updated_resource, status_change: "User deactivated")

        _ ->
          # For all other events, just apply the default logic
          updated_resource = UserResource.apply_event(event, resource)
          assign(socket, resource: updated_resource)
      end

    {:noreply, socket}
  end

  # Helper function to format datetime values
  defp format_datetime(nil), do: "Never"

  defp format_datetime(datetime) do
    # In a real app, you would use a proper datetime formatter
    "#{datetime.year}-#{datetime.month}-#{datetime.day} #{datetime.hour}:#{datetime.minute}"
  end
end
