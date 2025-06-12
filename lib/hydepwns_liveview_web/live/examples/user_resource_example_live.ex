defmodule HydepwnsLiveviewWeb.Examples.UserResourceExampleLive do
  @moduledoc """
  Example LiveView that demonstrates the Ash-inspired resource-oriented architecture.

  This LiveView uses the ResourceLive module and the `assigns` DSL to
  define and work with resource-oriented socket assigns.
  """

  use HydepwnsLiveviewWeb.ResourceLive

  alias HydepwnsLiveview.Utils.LiveViewAPI
  alias HydepwnsLiveview.Resources.UserResource
  alias HydepwnsLiveview.Resources
  alias HydepwnsLiveview.Resources.Resource

  # Valid roles that can be assigned to users
  @valid_roles ["admin", "editor", "viewer"]
  # Valid themes that can be applied
  @valid_themes ["light", "dark", "system"]

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "User Resource Example")
      |> assign(:theme_class, "")
      |> assign(:show_toc, false)
      |> assign(:toc_items, [])
      |> assign(:images, [])
      |> assign(:user_id, "123")
      |> assign(:username, "example_user")
      |> assign(:email, "user@example.com")
      |> assign(:role, "viewer")
      |> assign(:settings, %{theme: "light", notifications: false})
      |> assign(:show_admin_panel, false)
      |> load_user_from_resource()

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "User Resource Example")
    |> assign(:resources, Resources.list_resources())
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    case Resources.get_resource(id) do
      nil ->
        socket
        |> put_flash(:error, "Resource not found")
        |> redirect(to: ~p"/resources")
      resource ->
        socket
        |> assign(:page_title, "User Resource Details")
        |> assign(:resource, resource)
    end
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    case Resources.get_resource(id) do
      nil ->
        socket
        |> put_flash(:error, "Resource not found")
        |> redirect(to: ~p"/resources")
      resource ->
        socket
        |> assign(:page_title, "Edit User Resource")
        |> assign(:resource, resource)
    end
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New User Resource")
    |> assign(:resource, %Resource{})
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

  @impl true
  def handle_event("update_role", %{"role" => role}, socket) do
    with :ok <- validate_role(role),
         {:ok, socket} <- update_resource(socket, :role, role) do
      {:noreply, put_flash(socket, :info, "Role updated successfully")}
    else
      {:error, :invalid_role} ->
        {:noreply, put_flash(socket, :error, "Invalid role. Must be one of: #{Enum.join(@valid_roles, ", ")}")}
      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Failed to update role: #{inspect(reason)}")}
    end
  end

  @impl true
  def handle_event("update_theme", %{"theme" => theme}, socket) do
    with :ok <- validate_theme(theme),
         {:ok, socket} <- update_resource(socket, :theme, theme) do
      {:noreply, put_flash(socket, :info, "Theme updated successfully")}
    else
      {:error, :invalid_theme} ->
        {:noreply, put_flash(socket, :error, "Invalid theme. Must be one of: #{Enum.join(@valid_themes, ", ")}")}
      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Failed to update theme: #{inspect(reason)}")}
    end
  end

  @impl true
  def handle_event("toggle_notifications", _, socket) do
    current_setting = get_resource(socket, :settings).notifications
    case update_resource(socket, :settings, %{notifications: !current_setting}) do
      {:ok, socket} ->
        message = if !current_setting, do: "Notifications enabled", else: "Notifications disabled"
        {:noreply, put_flash(socket, :info, message)}
      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Failed to update notifications: #{inspect(reason)}")}
    end
  end

  @impl true
  def handle_event(_event, _params, socket), do: {:noreply, socket}

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

      {:error, reason, socket} ->
        # Log the error and return the socket
        require Logger
        Logger.error("Failed to load user resource: #{inspect(reason)}")
        socket
    end
  end

  # Validation functions
  defp validate_role(role) when role in @valid_roles, do: :ok
  defp validate_role(_), do: {:error, :invalid_role}

  defp validate_theme(theme) when theme in @valid_themes, do: :ok
  defp validate_theme(_), do: {:error, :invalid_theme}
end
