defmodule HydepwnsLiveviewWeb.Examples.UserResourceExampleLive do
  @moduledoc """
  Example LiveView that demonstrates the Ash-inspired resource-oriented architecture.

  This LiveView uses the ResourceLive module and the `assigns` DSL to
  define and work with resource-oriented socket assigns.
  """

  use HydepwnsLiveviewWeb.ResourceLive
  alias HydepwnsLiveview.Utils.LiveViewAPI
  alias HydepwnsLiveview.Resources.UserResource

  # Use the new assigns DSL
  assigns do
    attribute(:user_id, :string, required: true)
    attribute(:username, :string, required: true)
    attribute(:email, :string)
    attribute(:role, {:one_of, ["admin", "editor", "viewer"]}, default: "viewer")

    attribute :settings, :map do
      attribute(:theme, {:one_of, ["light", "dark", "system"]}, default: "system")
      attribute(:notifications, :boolean, default: true)
    end

    attribute(:show_admin_panel, :boolean, default: false)
    attribute(:loading, :boolean, default: false)
  end

  # Called by ResourceLive's do_mount after setting defaults
  def do_mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:user_id, "123")
      |> assign(:username, "example_user")
      |> assign(:email, "user@example.com")
      |> load_user_from_resource()

    socket
  end

  def render(assigns) do
    ~H"""
    <div class="resource-example">
      <h1>User Resource Example</h1>

      <div class="user-info">
        <h2>Current User</h2>
        <p><strong>ID:</strong> {@user_id}</p>
        <p><strong>Username:</strong> {@username}</p>
        <p><strong>Email:</strong> {@email}</p>
        <p><strong>Role:</strong> {@role}</p>

        <h3>Settings</h3>
        <p><strong>Theme:</strong> {@settings.theme}</p>
        <p><strong>Notifications:</strong> {if @settings.notifications, do: "Enabled", else: "Disabled"}</p>

        <%= if @show_admin_panel do %>
          <div class="admin-panel">
            <h3>Admin Panel</h3>
            <p>This is only visible to admins.</p>
          </div>
        <% end %>
      </div>

      <div class="actions">
        <h2>Actions</h2>
        <button phx-click="update_role" phx-value-role="admin">Set as Admin</button>
        <button phx-click="update_role" phx-value-role="editor">Set as Editor</button>
        <button phx-click="update_role" phx-value-role="viewer">Set as Viewer</button>

        <h3>Theme</h3>
        <button phx-click="update_theme" phx-value-theme="light">Light Theme</button>
        <button phx-click="update_theme" phx-value-theme="dark">Dark Theme</button>
        <button phx-click="update_theme" phx-value-theme="system">System Theme</button>

        <h3>Notifications</h3>
        <button phx-click="toggle_notifications">
          {if @settings.notifications, do: "Disable", else: "Enable"} Notifications
        </button>
      </div>

      <div class="resource-debug">
        <h2>Resource Debug Information</h2>
        <pre><%= inspect(@settings, pretty: true) %></pre>
      </div>
    </div>
    """
  end

  def handle_event("update_role", %{"role" => role}, socket) do
    # Use the update_resource method from ResourceLive
    case update_resource(socket, :role, role) do
      {:ok, socket} ->
        # Update admin panel visibility based on role
        socket =
          if role == "admin" do
            assign(socket, :show_admin_panel, true)
          else
            assign(socket, :show_admin_panel, false)
          end

        {:noreply, socket}

      {:error, message, socket} ->
        {:noreply, put_flash(socket, :error, message)}
    end
  end

  def handle_event("update_theme", %{"theme" => theme}, socket) do
    # Use the LiveViewAPI to update nested settings
    {:ok, socket} = LiveViewAPI.update(socket, :settings, %{theme: theme})
    {:noreply, socket}
  end

  def handle_event("toggle_notifications", _, socket) do
    # Get the current notifications setting
    current_setting = get_resource(socket, :settings).notifications

    # Update the notifications setting
    {:ok, socket} = LiveViewAPI.update(socket, :settings, %{notifications: !current_setting})
    {:noreply, socket}
  end

  # Private helper function to load user from UserResource
  defp load_user_from_resource(socket) do
    # Create a user from the UserResource definition
    user_data = %{
      id: socket.assigns.user_id,
      name: socket.assigns.username,
      email: socket.assigns.email,
      role: socket.assigns.role
    }

    # Load the user resource using LiveViewAPI
    case LiveViewAPI.create_from_resource(socket, :user, UserResource, user_data) do
      {:ok, socket} ->
        # Update the show_admin_panel based on role
        assign(socket, :show_admin_panel, socket.assigns.role == "admin")

      {:error, _message, socket} ->
        # Just return the socket as is
        socket
    end
  end
end
