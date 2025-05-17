defmodule HydepwnsLiveview.EnhancedErrorReportingTest do
  use HydepwnsLiveviewWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  alias HydepwnsLiveview.Utils.SocketValidator

  # Create a test LiveView for testing context-aware errors
  defmodule TestErrorLive do
    use HydepwnsLiveviewWeb.BaseLive,
      required_assigns: [:user_id, :count, :settings],
      type_specs: %{
        user_id: :string,
        count: :integer,
        items: {:list, :string},
        settings: %{theme: {:one_of, ["dark", "light"]}, notifications: :boolean},
        status: {:one_of, ["active", "inactive", "pending"]},
        callback: :function
      }

    def render(assigns) do
      ~H"""
      <div id="test-error-live">
        <p>User ID: <span data-assign="user_id">{@user_id}</span></p>
        <p>Count: <span data-assign="count">{@count}</span></p>
        <p>Status: <span data-assign="status">{@status}</span></p>
        <p>Settings: <span data-assign="settings">{inspect(@settings)}</span></p>
        <%= if assigns[:items] do %>
          <ul>
            <%= for item <- @items do %>
              <li>{item}</li>
            <% end %>
          </ul>
        <% end %>
      </div>
      """
    end

    def do_mount(_params, session, socket) do
      socket
      |> Phoenix.Component.assign(:user_id, Map.get(session, "user_id", ""))
      |> Phoenix.Component.assign(:count, Map.get(session, "count", 0))
      |> Phoenix.Component.assign(:status, Map.get(session, "status", "active"))
      |> Phoenix.Component.assign(:settings, Map.get(session, "settings", %{theme: "dark", notifications: true}))
      |> Phoenix.Component.assign(:items, Map.get(session, "items", []))
    end

    # Add handler for updating count with wrong type
    def handle_event("update_count", %{"count" => count}, socket) do
      # Deliberately assign string instead of integer to trigger type error
      {:noreply, Phoenix.Component.assign(socket, :count, count)}
    end

    # Add handler for updating status with invalid value
    def handle_event("update_status", %{"status" => status}, socket) do
      # Deliberately assign invalid status to trigger one_of error
      {:noreply, Phoenix.Component.assign(socket, :status, status)}
    end

    # Add handler for updating settings with invalid structure
    def handle_event("update_settings", %{"theme" => theme}, socket) do
      # Deliberately create invalid settings to trigger nested error
      settings = %{theme: theme, notifications: "yes"}
      {:noreply, Phoenix.Component.assign(socket, :settings, settings)}
    end
  end

  describe "context_aware_error enhancements" do
    test "provides detailed suggestions for integer conversion", %{conn: conn} do
      # Mount LiveView with valid data
      {:ok, view, _html} = live(conn, "/test")

      # Create socket with wrong type for testing
      socket =
        %Phoenix.LiveView.Socket{}
        |> Phoenix.Component.assign(:user_id, "123")
        |> Phoenix.Component.assign(:count, "42")
        |> Phoenix.Component.assign(:view, TestErrorLive)

      # Generate error message
      {:error, message, _} =
        SocketValidator.type_validation(socket, :count, :integer)

      # Create context-aware error message
      context_message =
        SocketValidator.context_aware_error(message, :count, socket)

      # Verify the error message contains detailed suggestions
      assert context_message =~ "Convert the string to an integer"
      assert context_message =~ "# Using String.to_integer/1"
      assert context_message =~ "count = String.to_integer"
      assert context_message =~ "# In assign:"
      assert context_message =~ "assign(socket, :count, String.to_integer"
    end

    test "provides code examples for enum conversion", %{conn: conn} do
      # Mount LiveView with invalid data
      {:ok, view, _html} = live(conn, "/test", %{"status" => "deleted"})

      # Send event to update status with invalid value
      view
      |> element("div")
      |> render_click(%{
        "status" => "cancelled"
      })

      # Get the socket
      socket =
        %Phoenix.LiveView.Socket{}
        |> Phoenix.Component.assign(:status, "cancelled")
        |> Phoenix.Component.assign(:view, TestErrorLive)

      # Generate error message
      {:error, message, _} =
        SocketValidator.type_validation(
          socket,
          :status,
          {:one_of, ["active", "inactive", "pending"]}
        )

      # Create context-aware error message
      context_message =
        SocketValidator.context_aware_error(message, :status, socket)

      # Verify the error message contains best practices and code examples
      assert context_message =~ "Value must be one of the allowed values:"
      assert context_message =~ "active"
      assert context_message =~ "inactive"
      assert context_message =~ "pending"
      assert context_message =~ "# Ensure the value is one of the allowed values:"
      assert context_message =~ "if status in"
    end

    test "detects lifecycle context for better suggestions", %{conn: conn} do
      # Mount LiveView with valid data
      {:ok, view, _html} = live(conn, "/test")

      # Create socket with lifecycle context
      socket =
        %Phoenix.LiveView.Socket{}
        |> Phoenix.Component.assign(:user_id, "123")
        |> Phoenix.Component.assign(:view, TestErrorLive)
        |> Phoenix.Component.assign(:__lifecycle_phase__, :handle_event)

      # Generate error message for missing assign
      {:error, message, _} =
        SocketValidator.type_validation(socket, :missing_key, :string)

      # Create context-aware error message
      context_message =
        SocketValidator.context_aware_error(message, :missing_key, socket)

      # Verify the error message contains lifecycle-specific suggestions
      assert context_message =~ "LiveView Context:"
      assert context_message =~ "Current lifecycle phase: handle_event"
    end

    test "provides debug grid information in development", %{conn: conn} do
      # Only run this test in development mode
      if Mix.env() == :dev do
        # Mount LiveView with invalid data
        {:ok, view, _html} = live(conn, "/test", %{"count" => "not-a-number"})

        # Create socket for testing
        socket =
          %Phoenix.LiveView.Socket{}
          |> Phoenix.Component.assign(:count, "not-a-number")
          |> Phoenix.Component.assign(:view, TestErrorLive)

        # Generate error message
        {:error, message, _} =
          SocketValidator.type_validation(socket, :count, :integer)

        # Create context-aware error message
        context_message =
          SocketValidator.context_aware_error(message, :count, socket)

        # Verify debug grid information is included
        assert context_message =~ "Debug Grid Integration:"
        assert context_message =~ "Grid location: count validation"
        assert context_message =~ "Error type: type_error"
      end
    end

    test "handles complex nested validation errors with specific suggestions", %{conn: conn} do
      # Mount LiveView with invalid settings
      {:ok, view, _html} =
        live(conn, "/test", %{
          "settings" => %{
            "theme" => "blue",
            "notifications" => "maybe"
          }
        })

      # Create test socket
      socket =
        %Phoenix.LiveView.Socket{}
        |> Phoenix.Component.assign(
          :settings,
          %{theme: "blue", notifications: "maybe"}
        )
        |> Phoenix.Component.assign(:view, TestErrorLive)

      # Define schema
      settings_schema = %{
        theme: {:one_of, ["dark", "light"]},
        notifications: :boolean
      }

      # Generate error message
      {:error, message, _} =
        SocketValidator.type_validation(socket, :settings, settings_schema)

      # Create context-aware error message
      context_message =
        SocketValidator.context_aware_error(message, :settings, socket)

      # Verify field-specific suggestions
      assert context_message =~ "Map structure doesn't match the required schema"
      assert context_message =~ "theme: expected one of"
      assert context_message =~ "notifications: expected boolean"
      assert context_message =~ "Example of valid map structure:"
      assert context_message =~ "theme: "
      assert context_message =~ "notifications: true"
    end
  end

  describe "Debug Grid integration" do
    # These tests can only be fully tested with a running server
    # We'll do basic checks to ensure the code doesn't error

    test "SocketValidationDebugGrid module functions without errors", %{conn: conn} do
      import HydepwnsLiveview.Utils.SocketValidationDebugGrid

      socket =
        %Phoenix.LiveView.Socket{}
        |> Phoenix.Component.assign(:user_id, "123")
        |> Phoenix.Component.assign(:count, 42)
        |> Phoenix.Component.assign(:view, TestErrorLive)

      # Validate these don't raise errors
      socket =
        inject_validation_data(
          socket,
          %{user_id: :string, count: :integer},
          [:user_id, :count]
        )

      socket =
        update_validation_data(
          socket,
          %{user_id: :string, count: :integer},
          [:user_id, :count]
        )

      socket = highlight_validation_errors(socket)

      # If we get here with no exceptions, the test passes
      assert true
    end

    test "BaseLive integrates with SocketValidationDebugGrid in development", %{conn: conn} do
      # Only test this in development mode
      if Mix.env() == :dev do
        # Mount LiveView with valid data
        {:ok, view, html} = live(conn, "/test")

        # Verify the socket validation debug data is set
        assert view.assigns.__debug_grid_data__
        assert view.assigns.__debug_grid_data__.socket_validation
      end
    end
  end
end
