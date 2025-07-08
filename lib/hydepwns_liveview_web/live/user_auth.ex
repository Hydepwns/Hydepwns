defmodule HydepwnsLiveviewWeb.UserAuth do
  @moduledoc """
  Handles user authentication for LiveView.
  """

  use HydepwnsLiveviewWeb, :live_view

  import Plug.Conn

  alias HydepwnsLiveview.Accounts
  alias HydepwnsLiveviewWeb.Router.Helpers, as: Routes

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    default_theme = HydepwnsLiveview.ThemeSystem.ensure_default_theme()
    theme_class = "#{default_theme.mode}-theme"
    {:ok, assign(socket, theme_class: theme_class)}
  end

  @impl Phoenix.LiveView
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event(_event, _params, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class={@theme_class}>
      <%= @inner_content %>
    </div>
    """
  end

  def on_mount(:require_authenticated_user, _params, session, socket) do
    socket = assign_current_user(socket, session)

    if socket.assigns.current_user do
      {:cont, socket}
    else
      socket = socket
      |> Phoenix.LiveView.redirect(to: Routes.user_session_path(socket, :new))

      {:halt, socket}
    end
  end

  def on_mount(:mount_current_user, _params, session, socket) do
    socket = assign_current_user(socket, session)
    {:cont, socket}
  end

  def on_mount(:redirect_if_user_is_authenticated, _params, session, socket) do
    socket = assign_current_user(socket, session)

    if socket.assigns.current_user do
      {:halt,
       Phoenix.LiveView.redirect(socket,
         to: ~p"/users/#{socket.assigns.current_user}"
       )}
    else
      {:cont, socket}
    end
  end

  def on_mount(:require_admin_user, _params, session, socket) do
    socket = assign_current_user(socket, session)

    if socket.assigns.current_user && socket.assigns.current_user.role == "admin" do
      {:cont, socket}
    else
      socket = socket
      |> Phoenix.LiveView.redirect(to: Routes.user_session_path(socket, :new))

      {:halt, socket}
    end
  end

  defp assign_current_user(socket, session) do
    # Ensure socket has proper assigns structure with __changed__ key
    socket = ensure_socket_assigns(socket)

    assign_new(socket, :current_user, fn ->
      if user_token = session["user_token"], do: Accounts.get_user_by_session_token(user_token)
    end)
  end

  defp ensure_socket_assigns(socket) do
    assigns = socket.assigns

    assigns = if Map.has_key?(assigns, :__changed__) do
      assigns
    else
      Map.put(assigns, :__changed__, %{})
    end

    assigns = if Map.has_key?(assigns, :flash) do
      assigns
    else
      Map.put(assigns, :flash, %{})
    end

    %{socket | assigns: assigns}
  end

  def log_in_user(socket, user, params \\ %{}) do
    # Ensure socket has proper assigns structure
    socket = ensure_socket_assigns(socket)

    token = Accounts.generate_user_session_token(user)
    user_return_to = socket.assigns[:user_return_to] || signed_in_path(socket)

    socket
    |> Phoenix.Component.assign(:current_user, user)
    |> Phoenix.Component.assign(:user_token, token)
    |> Phoenix.LiveView.redirect(to: user_return_to)
  end

  def log_in_user_liveview(socket, user, params \\ %{}, opts \\ []) do
    token = Accounts.generate_user_session_token(user)
    user_return_to = opts[:redirect_to] || socket.assigns[:user_return_to] || signed_in_path_liveview(socket)

    socket
    |> Phoenix.Component.assign(:current_user, user)
    |> Phoenix.Component.assign(:user_token, token)
    |> maybe_write_remember_me_cookie_liveview(token, params)
    |> then(fn socket ->
      Phoenix.LiveView.push_navigate(socket, to: user_return_to)
    end)
  end

  defp maybe_write_remember_me_cookie(socket, token, %{"remember_me" => "true"}) do
    put_resp_cookie(socket, :remember_token, token, max_age: 60 * 60 * 24 * 30)
  end

  defp maybe_write_remember_me_cookie(socket, _token, _params) do
    socket
  end

  defp maybe_write_remember_me_cookie_liveview(socket, _token, _params) do
    # For LiveView, we don't set cookies directly
    socket
  end

  def log_out_user(socket) do
    # Ensure socket has proper assigns structure
    socket = ensure_socket_assigns(socket)

    # For LiveView sockets, we can't use Plug.Conn functions
    # The session token should be available in socket.assigns
    user_token = socket.assigns[:user_token]
    user_token && Accounts.delete_session_token(user_token)

    # For LiveView, we need to redirect without using Plug.Conn functions
    socket
    |> Phoenix.Component.assign(:current_user, nil)
    |> Phoenix.Component.assign(:user_token, nil)
    |> Phoenix.LiveView.redirect(to: ~p"/")
  end

  defp signed_in_path(_socket), do: ~p"/"

  defp signed_in_path_liveview(_socket), do: ~p"/"

  @doc """
  Updates a user's password.

  ## Parameters
  * `user` - The user to update
  * `attrs` - The password update attributes

  ## Returns
  * `{:ok, updated_user}` or `{:error, changeset}`
  """
  def update_user_password(user, attrs) do
    case HydepwnsLiveview.Accounts.change_password(user, attrs) do
      {:ok, updated_user} ->
        {:ok, updated_user}

      {:error, changeset} ->
        {:error, changeset}
    end
  end
end
