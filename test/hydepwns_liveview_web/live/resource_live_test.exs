defmodule HydepwnsLiveviewWeb.ResourceLiveTest do
  use HydepwnsLiveviewWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias HydepwnsLiveview.Utils.LiveViewAPI

  # Define a test module that uses ResourceLive
  defmodule TestResourceLive do
    use HydepwnsLiveviewWeb.ResourceLive

    assigns do
      attribute(:page_title, :string, default: "Test Resource")

      attribute :user, :map do
        attribute(:id, :string, required: true)
        attribute(:name, :string, default: "Test User")
        attribute(:role, {:one_of, ["admin", "user", "guest"]}, default: "user")
      end

      attribute :settings, :map do
        attribute(:theme, {:one_of, ["dark", "light"]}, default: "dark")
      end

      attribute(:items, {:list, :string}, default: [])
    end

    def do_mount(_params, _session, socket) do
      socket =
        Phoenix.Component.assign(socket, :user, %{id: "user_123", name: "Test User", role: "user"})

      socket
    end

    def handle_event("update_role", %{"role" => role}, socket) do
      current_user = LiveViewAPI.get_all(socket, :user)
      updated_user = Map.put(current_user, :role, role)

      case LiveViewAPI.update(socket, :user, updated_user) do
        {:ok, updated_socket} ->
          {:noreply, updated_socket}

        {:error, message, socket} ->
          {:noreply, Phoenix.LiveView.put_flash(socket, :error, message)}
      end
    end

    def render(assigns) do
      ~H"""
      <div id="test-resource">
        <h1>{@page_title}</h1>

        <div id="user-info">
          <div id="user-id">{@user.id}</div>
          <div id="user-name">{@user.name}</div>
          <div id="user-role">{@user.role}</div>
        </div>

        <div id="settings">
          <div id="theme">{@settings.theme}</div>
        </div>

        <div id="items">
          <%= for item <- @items do %>
            <div class="item">{item}</div>
          <% end %>
        </div>

        <button id="set-admin" phx-click="update_role" phx-value-role="admin">Set Admin</button>
        <button id="set-guest" phx-click="update_role" phx-value-role="guest">Set Guest</button>
      </div>
      """
    end
  end

  describe "ResourceLive with assigns_resource" do
    test "mounts with default values", %{conn: conn} do
      {:ok, view, html} = live_isolated(conn, TestResourceLive)

      # Check that default values are set
      assert html =~ "Test Resource"
      assert html =~ "user_123"
      assert html =~ "Test User"
      # default role
      assert html =~ "user"
      # default theme
      assert html =~ "dark"
    end

    test "updates resource values via event", %{conn: conn} do
      {:ok, view, _html} = live_isolated(conn, TestResourceLive)

      # Click the set-admin button
      view |> element("#set-admin") |> render_click()

      # Check that the role was updated
      assert has_element?(view, "#user-role", "admin")

      # Click the set-guest button
      view |> element("#set-guest") |> render_click()

      # Check that the role was updated again
      assert has_element?(view, "#user-role", "guest")
    end

    test "updates resource via API", %{conn: conn} do
      {:ok, view, _html} = live_isolated(conn, TestResourceLive)

      # Get the socket
      socket = view.module.__struct__.socket

      # Update the user name via LiveViewAPI
      {:ok, _updated_socket} = LiveViewAPI.update(socket, :user, %{name: "Updated User"})

      # This would normally happen in the LiveView process, but for testing we need to use render
      view = render(view)

      # Verify the update is reflected in the rendered view (would show in live update)
      assert view =~ "Updated User"
    end

    test "validates resource updates", %{conn: conn} do
      {:ok, view, _html} = live_isolated(conn, TestResourceLive)

      # Get the socket
      socket = view.module.__struct__.socket

      # Update with invalid value should fail validation
      case LiveViewAPI.update(socket, :user, %{role: "invalid_role"}) do
        {:ok, _} ->
          flunk("Expected validation to fail for invalid role")

        {:error, message, _} ->
          assert message =~ "expected one of"
      end
    end

    test "adds items to list", %{conn: conn} do
      {:ok, view, _html} = live_isolated(conn, TestResourceLive)

      # Get the socket
      socket = view.module.__struct__.socket

      # Add items to the list
      {:ok, updated_socket} = LiveViewAPI.update(socket, :items, ["Item 1", "Item 2"])

      # This is just for testing. In a real LiveView, the socket updates automatically
      view = render(view)

      # Verify items are displayed
      assert view =~ "Item 1"
      assert view =~ "Item 2"
    end
  end
end
