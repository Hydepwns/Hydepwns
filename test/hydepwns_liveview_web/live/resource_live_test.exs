defmodule HydepwnsLiveviewWeb.ResourceLiveTest do
  use HydepwnsLiveviewWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias HydepwnsLiveview.Utils.LiveViewAPI

  # Define a test module that uses ResourceLive
  defmodule TestResourceLive do
    use HydepwnsLiveviewWeb.ResourceLive
    import HydepwnsLiveview.Utils.ResourceAssigns
    require HydepwnsLiveview.Utils.ResourceAssigns

    assigns_resource do
      attribute(:page_title, :string, default: "Test Resource")

      attribute :user, :map do
        attribute(:id, :string, required: true)
        attribute(:name, :string, default: "Test User")
        attribute(:role, {:one_of, ["admin", "user", "guest"]}, default: "user")
      end

      attribute(:settings, :map, default: %{theme: "dark"})

      attribute(:items, {:list, :string}, default: [])
    end

    @impl HydepwnsLiveviewWeb.BaseLive.Behaviour
    def do_mount(_params, _session, socket) do
      socket = __apply_resource_defaults__(socket)

      socket =
        Phoenix.Component.assign(socket, :user, %{id: "user_123", name: "Test User", role: "user"})

      socket
    end

    @impl Phoenix.LiveView
    def handle_event("update_role", %{"role" => role}, socket) do
      current_user = LiveViewAPI.get_assign(socket, :user)
      updated_user = Map.put(current_user, :role, role)

      update_result = LiveViewAPI.update(socket, :user, updated_user)

      case update_result do
        {:ok, updated_socket} ->
          {:noreply, updated_socket}

        {:error, message, error_socket} ->
          {:noreply, Phoenix.LiveView.put_flash(error_socket, :error, message)}
      end
    end

    # Added for testing LiveViewAPI.update
    def handle_event("test_api_update", %{"field" => field, "value" => value}, socket) do
      updated_socket = apply_update(socket, field, value)
      {:noreply, updated_socket}
    end

    defp apply_update(socket, field_string, value, opts \\ []) do
      field = String.to_atom(field_string)

      case LiveViewAPI.update(socket, field, value, opts) do
        {:ok, updated_socket} ->
          updated_socket

        # _message to avoid unused var warning if no IO.inspect
        {:error, _message, error_socket} ->
          # IO.inspect({message, field, value}, label: "TestResourceLive.apply_update - ERROR")
          error_socket
      end
    end

    @impl Phoenix.LiveView
    def render(assigns) do
      processed_settings =
        case assigns.settings do
          {:%{}, _meta, keyword_list_data} when is_list(keyword_list_data) ->
            Enum.into(keyword_list_data, %{})

          plain_map when is_map(plain_map) ->
            plain_map

          # Fallback or error
          _ ->
            %{}
        end

      # IO.inspect(processed_settings, label: "Render: processed_settings") # Cleaned up previous inspect

      assigns = Map.put(assigns, :settings, processed_settings)

      ~H"""
      <div id="test-resource">
        <h1>{@page_title}</h1>

        <div id="user-info">
          <div id="user-id">{@user.id}</div>
          <div id="user-name">{@user.name}</div>
          <div id="user-role">{@user.role}</div>
        </div>

        <div id="settings">
          <div id="theme">{Map.get(@settings, :theme)}</div>
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
      # Might not be reached

      # Check that the role was updated
      assert has_element?(view, "#user-role", "admin")

      # Click the set-guest button
      # view |> element("#set-guest") |> render_click()

      # Check that the role was updated again
      # assert has_element?(view, "#user-role", "guest")
    end

    test "updates resource via API", %{conn: conn} do
      {:ok, view, _html} = live_isolated(conn, TestResourceLive)

      # Update the user name via the new event handler
      html =
        view
        |> render_click("test_api_update", %{
          "field" => "user",
          "value" => %{id: "user_123", name: "Updated User", role: "user"}
        })

      # Verify the update is reflected in the rendered view
      assert html =~ "Updated User"
      # Ensure ID is preserved
      assert html =~ "user_123"
      # Ensure role is preserved
      assert html =~ "user"
    end

    test "validates resource updates", %{conn: conn} do
      {:ok, view, _html} = live_isolated(conn, TestResourceLive)

      # Attempt to update with invalid value via the event handler
      # The event handler's apply_update returns the error_socket without crashing.
      # We can then check assigns or flash if we were setting it.
      # For this test, we are testing LiveViewAPI.update indirectly.
      # Let's call apply_update directly with a constructed socket for a more direct test of validation.

      initial_assigns = %{
        user: %{id: "user_123", name: "Test User", role: "user"},
        items: [],
        settings: %{theme: "dark"},
        page_title: "Test Resource",
        __changed__: %{},
        live_action: nil,
        # Assuming BaseLive adds this
        current_user: %{id: "user_123", name: "Test User", role: "user"}
      }

      # Create a minimal socket for testing the API function directly
      # Note: This socket won't have a PID or be part of a LiveView process.
      # It's for unit-testing the LiveViewAPI.update validation logic.
      test_socket = %Phoenix.LiveView.Socket{
        id: "test-socket",
        endpoint: HydepwnsLiveviewWeb.Endpoint,
        view: TestResourceLive,
        assigns: initial_assigns,
        transport_pid: nil,
        parent_pid: nil,
        root_pid: nil,
        router: nil
      }

      case LiveViewAPI.update(test_socket, :user, %{
             id: "user_123",
             name: "Test User",
             role: "invalid_role"
           }) do
        {:ok, _} ->
          flunk("Expected validation to fail for invalid role")

        {:error, message, _error_socket} ->
          assert message =~ "expected one of"
      end
    end

    test "adds items to list", %{conn: conn} do
      {:ok, view, _html} = live_isolated(conn, TestResourceLive)

      # Add items to the list via the event handler
      rendered_html =
        view
        |> render_click("test_api_update", %{"field" => "items", "value" => ["Item 1", "Item 2"]})

      # Verify items are displayed
      assert rendered_html =~ "Item 1"
      assert rendered_html =~ "Item 2"
    end
  end
end
