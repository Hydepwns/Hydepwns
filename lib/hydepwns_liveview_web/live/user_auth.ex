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
      {:halt,
       socket
       |> Phoenix.LiveView.put_flash(:error, "You must log in to access this page.")
       |> Phoenix.LiveView.redirect(to: Routes.user_session_path(socket, :new))}
    end
  end

  def on_mount(:redirect_if_user_is_authenticated, _params, session, socket) do
    socket = assign_current_user(socket, session)

    if socket.assigns.current_user do
      {:halt,
       Phoenix.LiveView.redirect(socket,
         to: Routes.user_path(socket, :show, socket.assigns.current_user)
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
      {:halt,
       socket
       |> Phoenix.LiveView.put_flash(:error, "You must be an admin to access this page.")
       |> Phoenix.LiveView.redirect(to: Routes.user_session_path(socket, :new))}
    end
  end

  defp assign_current_user(socket, session) do
    assign_new(socket, :current_user, fn ->
      if user_token = session["user_token"], do: Accounts.get_user_by_session_token(user_token)
    end)
  end

  def log_in_user(socket, user, params \\ %{}) do
    token = Accounts.generate_user_session_token(user)
    user_return_to = get_session(socket, :user_return_to)

    socket
    |> Plug.Conn.assign(:current_user, user)
    |> Plug.Conn.assign(:user_token, token)
    |> put_session(:user_token, token)
    |> put_session(:live_socket_id, "users_sessions:#{Base.url_encode64(token)}")
    |> maybe_write_remember_me_cookie(token, params)
    |> Phoenix.LiveView.redirect(to: user_return_to || signed_in_path(socket))
  end

  defp maybe_write_remember_me_cookie(socket, token, %{"remember_me" => "true"}) do
    put_resp_cookie(socket, :remember_token, token, max_age: 60 * 60 * 24 * 30)
  end

  defp maybe_write_remember_me_cookie(socket, _token, _params) do
    socket
  end

  def log_out_user(socket) do
    user_token = get_session(socket, :user_token)
    user_token && Accounts.delete_session_token(user_token)

    socket
    |> clear_session()
    |> delete_resp_cookie(:remember_token)
    |> Phoenix.LiveView.redirect(to: ~p"/")
  end

  defp signed_in_path(_socket), do: ~p"/"

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
