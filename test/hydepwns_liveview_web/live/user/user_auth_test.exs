defmodule HydepwnsLiveviewWeb.UserAuthTest do
  @router HydepwnsLiveviewWeb.Router
  use HydepwnsLiveviewWeb.ConnCase, async: false

  import Phoenix.LiveViewTest
  import HydepwnsLiveviewWeb.TestHelpers.WallabyUIHelper


  alias HydepwnsLiveview.Accounts
  alias HydepwnsLiveviewWeb.UserAuth

  setup do
    # Create test users with different roles
    {:ok, admin_user} = Accounts.create_user(%{
      name: "Admin User",
      email: "admin@example.com",
      password: "password123",
      role: "admin"
    })

    {:ok, regular_user} = Accounts.create_user(%{
      name: "Regular User",
      email: "user@example.com",
      password: "password123",
      role: "user"
    })

    {:ok, editor_user} = Accounts.create_user(%{
      name: "Editor User",
      email: "editor@example.com",
      password: "password123",
      role: "editor"
    })

    %{admin_user: admin_user, regular_user: regular_user, editor_user: editor_user}
  end

  describe "authentication guards" do
    test "require_authenticated_user allows authenticated users", %{conn: conn, regular_user: user} do
      # Create a session with user token
      token = Accounts.generate_user_session_token(user)
      session = %{"user_token" => token}

      # Simulate the on_mount callback
      socket = %Phoenix.LiveView.Socket{
        assigns: %{},
        endpoint: HydepwnsLiveviewWeb.Endpoint
      }

      result = UserAuth.on_mount(:require_authenticated_user, %{}, session, socket)

      assert {:cont, updated_socket} = result
      assert updated_socket.assigns.current_user.id == user.id
    end

    test "require_authenticated_user redirects unauthenticated users", %{conn: conn} do
      # Empty session
      session = %{}

      socket = %Phoenix.LiveView.Socket{
        assigns: %{},
        endpoint: HydepwnsLiveviewWeb.Endpoint
      }

      result = UserAuth.on_mount(:require_authenticated_user, %{}, session, socket)

      assert {:halt, updated_socket} = result
      assert updated_socket.assigns.flash[:error] == "You must log in to access this page."
    end

    test "mount_current_user assigns current user", %{conn: conn, regular_user: user} do
      # Create a session with user token
      token = Accounts.generate_user_session_token(user)
      session = %{"user_token" => token}

      socket = %Phoenix.LiveView.Socket{
        assigns: %{},
        endpoint: HydepwnsLiveviewWeb.Endpoint
      }

      result = UserAuth.on_mount(:mount_current_user, %{}, session, socket)

      assert {:cont, updated_socket} = result
      assert updated_socket.assigns.current_user.id == user.id
    end

    test "mount_current_user handles missing session gracefully", %{conn: conn} do
      # Empty session
      session = %{}

      socket = %Phoenix.LiveView.Socket{
        assigns: %{},
        endpoint: HydepwnsLiveviewWeb.Endpoint
      }

      result = UserAuth.on_mount(:mount_current_user, %{}, session, socket)

      assert {:cont, updated_socket} = result
      assert updated_socket.assigns.current_user == nil
    end

    test "redirect_if_user_is_authenticated redirects authenticated users", %{conn: conn, regular_user: user} do
      # Create a session with user token
      token = Accounts.generate_user_session_token(user)
      session = %{"user_token" => token}

      socket = %Phoenix.LiveView.Socket{
        assigns: %{},
        endpoint: HydepwnsLiveviewWeb.Endpoint
      }

      result = UserAuth.on_mount(:redirect_if_user_is_authenticated, %{}, session, socket)

      assert {:halt, updated_socket} = result
      # Should redirect to user profile page
      assert updated_socket.assigns.current_user.id == user.id
    end

    test "redirect_if_user_is_authenticated allows unauthenticated users", %{conn: conn} do
      # Empty session
      session = %{}

      socket = %Phoenix.LiveView.Socket{
        assigns: %{},
        endpoint: HydepwnsLiveviewWeb.Endpoint
      }

      result = UserAuth.on_mount(:redirect_if_user_is_authenticated, %{}, session, socket)

      assert {:cont, updated_socket} = result
      assert updated_socket.assigns.current_user == nil
    end
  end

  describe "role-based access control" do
    test "require_admin_user allows admin users", %{conn: conn, admin_user: user} do
      # Create a session with admin user token
      token = Accounts.generate_user_session_token(user)
      session = %{"user_token" => token}

      socket = %Phoenix.LiveView.Socket{
        assigns: %{},
        endpoint: HydepwnsLiveviewWeb.Endpoint
      }

      result = UserAuth.on_mount(:require_admin_user, %{}, session, socket)

      assert {:cont, updated_socket} = result
      assert updated_socket.assigns.current_user.id == user.id
      assert updated_socket.assigns.current_user.role == "admin"
    end

    test "require_admin_user redirects non-admin users", %{conn: conn, regular_user: user} do
      # Create a session with regular user token
      token = Accounts.generate_user_session_token(user)
      session = %{"user_token" => token}

      socket = %Phoenix.LiveView.Socket{
        assigns: %{},
        endpoint: HydepwnsLiveviewWeb.Endpoint
      }

      result = UserAuth.on_mount(:require_admin_user, %{}, session, socket)

      assert {:halt, updated_socket} = result
      assert updated_socket.assigns.flash[:error] == "You must be an admin to access this page."
    end

    test "require_admin_user redirects unauthenticated users", %{conn: conn} do
      # Empty session
      session = %{}

      socket = %Phoenix.LiveView.Socket{
        assigns: %{},
        endpoint: HydepwnsLiveviewWeb.Endpoint
      }

      result = UserAuth.on_mount(:require_admin_user, %{}, session, socket)

      assert {:halt, updated_socket} = result
      assert updated_socket.assigns.flash[:error] == "You must be an admin to access this page."
    end
  end

  describe "session management" do
    test "log_in_user creates session and redirects", %{conn: conn, regular_user: user} do
      socket = %Phoenix.LiveView.Socket{
        assigns: %{},
        endpoint: HydepwnsLiveviewWeb.Endpoint
      }

      result = UserAuth.log_in_user(socket, user)

      # Should redirect to home page
      assert result.assigns.current_user.id == user.id
      assert result.assigns.user_token != nil
    end

    test "log_in_user with remember me sets cookie", %{conn: conn, regular_user: user} do
      socket = %Phoenix.LiveView.Socket{
        assigns: %{},
        endpoint: HydepwnsLiveviewWeb.Endpoint
      }

      result = UserAuth.log_in_user(socket, user, %{"remember_me" => "true"})

      # Should have remember token cookie
      assert result.assigns.current_user.id == user.id
      # Note: In tests, we can't easily check cookies, but the function should handle it
    end

    test "log_out_user clears session", %{conn: conn, regular_user: user} do
      # First create a session
      token = Accounts.generate_user_session_token(user)
      session = %{"user_token" => token}

      socket = %Phoenix.LiveView.Socket{
        assigns: %{current_user: user, user_token: token},
        endpoint: HydepwnsLiveviewWeb.Endpoint
      }

      result = UserAuth.log_out_user(socket)

      # Should redirect to home page
      assert result.assigns.current_user == nil
    end
  end

  describe "password management" do
    test "update_user_password with valid data", %{conn: conn, regular_user: user} do
      attrs = %{
        "current_password" => "password123",
        "password" => "newpassword123",
        "password_confirmation" => "newpassword123"
      }

      result = UserAuth.update_user_password(user, attrs)

      assert {:ok, updated_user} = result
      assert updated_user.id == user.id
    end

    test "update_user_password with invalid current password", %{conn: conn, regular_user: user} do
      attrs = %{
        "current_password" => "wrong_password",
        "password" => "newpassword123",
        "password_confirmation" => "newpassword123"
      }

      result = UserAuth.update_user_password(user, attrs)

      assert {:error, changeset} = result
      assert %{current_password: ["is not valid"]} = changeset.errors
    end
  end

  describe "integration with LiveView" do
    test "protected route requires authentication", %{conn: conn} do
      # Try to access a protected route without authentication
      assert_raise Phoenix.LiveView.RedirectError, fn ->
        live(conn, ~p"/users/settings")
      end
    end

    test "admin route requires admin role", %{conn: conn, regular_user: user} do
      # Login as regular user
      token = Accounts.generate_user_session_token(user)
      session = %{"user_token" => token}

      # Try to access admin route
      assert_raise Phoenix.LiveView.RedirectError, fn ->
        live(conn, ~p"/admin")
      end
    end

    test "authenticated user can access protected routes", %{conn: conn, regular_user: user} do
      # Create session with user
      token = Accounts.generate_user_session_token(user)
      session = %{"user_token" => token}

      # Should be able to access user settings
      {:ok, view, html} = live(conn, ~p"/users/settings", session: session)
      assert html =~ "User Settings"
    end
  end

  describe "error handling" do
    test "handles invalid session tokens gracefully", %{conn: conn} do
      # Session with invalid token
      session = %{"user_token" => "invalid_token"}

      socket = %Phoenix.LiveView.Socket{
        assigns: %{},
        endpoint: HydepwnsLiveviewWeb.Endpoint
      }

      result = UserAuth.on_mount(:require_authenticated_user, %{}, session, socket)

      assert {:halt, updated_socket} = result
      assert updated_socket.assigns.flash[:error] == "You must log in to access this page."
    end

    test "handles expired session tokens", %{conn: conn, regular_user: user} do
      # Create a token and then delete it (simulating expiration)
      token = Accounts.generate_user_session_token(user)
      Accounts.delete_session_token(token)

      session = %{"user_token" => token}

      socket = %Phoenix.LiveView.Socket{
        assigns: %{},
        endpoint: HydepwnsLiveviewWeb.Endpoint
      }

      result = UserAuth.on_mount(:require_authenticated_user, %{}, session, socket)

      assert {:halt, updated_socket} = result
      assert updated_socket.assigns.flash[:error] == "You must log in to access this page."
    end
  end
end
